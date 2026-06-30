# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ARG SITE_NAME=localhost

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/usr/local/nodejs/bin:${PATH}"

# Install curl first, then Node.js 20
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fsSL https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-x64.tar.gz -o /tmp/node.tar.gz \
    && mkdir -p /usr/local/nodejs \
    && tar -xzf /tmp/node.tar.gz -C /usr/local/nodejs --strip-components=1 \
    && rm /tmp/node.tar.gz \
    && ln -sf /usr/local/nodejs/bin/node /usr/local/bin/node \
    && ln -sf /usr/local/nodejs/bin/npm /usr/local/bin/npm \
    && ln -sf /usr/local/nodejs/bin/npx /usr/local/bin/npx \
    && ln -sf /usr/local/nodejs/bin/yarn /usr/local/bin/yarn \
    && rm -rf /var/lib/apt/lists/*

# Install ALL system dependencies
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

# Verify node/yarn
RUN node --version && yarn --version

# Write BOTH .bash_profile and .bashrc so su - frappe -c finds node/yarn
RUN echo 'export PATH="/usr/local/nodejs/bin:$PATH"' > /home/frappe/.bash_profile \
    && echo 'export PATH="/usr/local/nodejs/bin:$PATH"' >> /home/frappe/.bashrc

# Switch to frappe user
USER frappe
WORKDIR /home/frappe

# Clone Frappe + ERPNext + HRMS
RUN bench init --skip-redis-config-generation --frappe-branch version-15 frappe-bench \
    && cd frappe-bench \
    && bench get-app erpnext --branch version-15 \
    && bench get-app hrms --branch version-15

# Clone custom app manually (repo has app nested in automotive_crm/ subdir)
# pip install -e IS required — bench new-site imports the app to read modules.txt
# Outer __init__.py and hooks.py were deleted, so no namespace conflict
RUN git clone https://github.com/apcvala68-ux/ERPNext-NAYANOP.git --branch main --depth 1 /tmp/repo \
    && cp -r /tmp/repo/automotive_crm /home/frappe/frappe-bench/apps/automotive_crm \
    && rm -rf /tmp/repo \
    && cd /home/frappe/frappe-bench/apps/automotive_crm && /home/frappe/frappe-bench/env/bin/pip install -e . --no-deps \
    && printf 'frappe\nerpnext\nhrms\nautomotive_crm\n' > /home/frappe/frappe-bench/sites/apps.txt \
    && echo "--- apps.txt content ---" && cat /home/frappe/frappe-bench/sites/apps.txt && echo "--- end ---" \
    && chown -R frappe:frappe /home/frappe/frappe-bench

# === SWITCH TO ROOT FOR SITE CREATION ===
USER root

# Copy configs BEFORE site creation
COPY Procfile /home/frappe/frappe-bench/Procfile
COPY common_site_config.json /home/frappe/frappe-bench/sites/common_site_config.json
RUN chown -R frappe:frappe /home/frappe/frappe-bench

# Set default_site using Python (sed breaks on URLs with ://)
RUN python3 -c "\
import json;\
f='/home/frappe/frappe-bench/sites/common_site_config.json';\
d=json.load(open(f));\
d['default_site']='${SITE_NAME}';\
json.dump(d,open(f,'w'),indent=1)\
"

# === CREATE SITE DURING BUILD ===
COPY setup-site.sh /tmp/setup-site.sh
RUN chmod +x /tmp/setup-site.sh && /tmp/setup-site.sh '${SITE_NAME}'

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000 9000

ENTRYPOINT ["/entrypoint.sh"]
