# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ARG SITE_NAME=localhost

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/usr/local/nodejs/bin:${PATH}"

# Install curl first (not in base ubuntu image), then Node.js 20
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fsSL https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-x64.tar.gz -o /tmp/node.tar.gz \
    && mkdir -p /usr/local/nodejs \
    && tar -xzf /tmp/node.tar.gz -C /usr/local/nodejs --strip-components=1 \
    && rm /tmp/node.tar.gz \
    && ln -sf /usr/local/nodejs/bin/node /usr/local/bin/node \
    && ln -sf /usr/local/nodejs/bin/npm /usr/local/bin/npm \
    && ln -sf /usr/local/nodejs/bin/npx /usr/local/bin/npx \
    && rm -rf /var/lib/apt/lists/*

# Install ALL system dependencies (no ubuntu nodejs/npm - we have our own)
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    python3-venv \
    cron \
    mariadb-server \
    mariadb-client \
    redis-server \
    curl \
    wkhtmltopdf \
    pkg-config \
    libmariadb-dev \
    libssl-dev \
    libffi-dev \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    && rm -rf /var/lib/apt/lists/*

# Setup MariaDB + frappe user
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld \
    && useradd -m -s /bin/bash frappe

# Install frappe-bench + yarn
RUN pip3 install frappe-bench && npm install -g yarn

# Verify node version
RUN node --version && yarn --version

# Switch to frappe user, let bench init create the directory
USER frappe
WORKDIR /home/frappe

# Clone Frappe + ERPNext + HRMS
RUN bench init --skip-redis-config-generation --frappe-branch version-15 frappe-bench \
    && cd frappe-bench \
    && bench get-app erpnext --branch version-15 \
    && bench get-app hrms --branch version-15

# Clone custom app directly into bench apps + pip install it
RUN git clone https://github.com/apcvala68-ux/ERPNext-NAYANOP.git --branch main --depth 1 /tmp/repo \
    && cp -r /tmp/repo/automotive_crm /home/frappe/frappe-bench/apps/automotive_crm \
    && rm -rf /tmp/repo \
    && cd /home/frappe/frappe-bench \
    && env/bin/pip install -e apps/automotive_crm \
    && printf 'frappe\nerpnext\nhrms\nautomotive_crm\n' > sites/apps.txt \
    && echo "--- apps.txt content ---" && cat sites/apps.txt && echo "--- end ---" \
    && chown -R frappe:frappe /home/frappe/frappe-bench

# === CREATE SITE DURING BUILD (bakes site into image for instant restarts) ===
# Switch to root to start MariaDB, create site as frappe user, stop MariaDB
USER root

RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld \
    && mysqld_safe --datadir=/var/lib/mysql --no-watch & \
    && sleep 5 \
    && for i in $(seq 1 30); do mariadb-admin ping -h localhost --silent 2>/dev/null && break || sleep 1; done \
    && su - frappe -c "cd /home/frappe/frappe-bench && yes '' | bench new-site '${SITE_NAME}' --mariadb-root-password admin --admin-password admin --force" \
    && su - frappe -c "cd /home/frappe/frappe-bench && bench --site '${SITE_NAME}' install-app erpnext" \
    && su - frappe -c "cd /home/frappe/frappe-bench && bench --site '${SITE_NAME}' install-app hrms" \
    && su - frappe -c "cd /home/frappe/frappe-bench && bench --site '${SITE_NAME}' install-app automotive_crm" \
    && su - frappe -c "cd /home/frappe/frappe-bench && bench config -g set default_site '${SITE_NAME}'" \
    && su - frappe -c "cd /home/frappe/frappe-bench && bench build --app automotive_crm" || true \
    && su - frappe -c "cd /home/frappe/frappe-bench && bench --site '${SITE_NAME}' clear-cache" || true \
    && mysqladmin -u root -padmin shutdown 2>/dev/null || true \
    && rm -rf /tmp/* /var/tmp/*

# Copy configs
COPY Procfile /home/frappe/frappe-bench/Procfile
COPY common_site_config.json /home/frappe/frappe-bench/sites/common_site_config.json
RUN chown -R frappe:frappe /home/frappe/frappe-bench

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000 9000

ENTRYPOINT ["/entrypoint.sh"]
