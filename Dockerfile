# syntax=docker/dockerfile:1
FROM ubuntu:22.04

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

# Clone Frappe + ERPNext + HRMS + custom app
RUN bench init --skip-redis-config-generation --frappe-branch version-15 frappe-bench \
    && cd frappe-bench \
    && bench get-app erpnext --branch version-15 \
    && bench get-app hrms --branch version-15 \
    && bench get-app automotive_crm https://github.com/apcvala68-ux/ERPNext-NAYANOP.git --branch main

# Switch back to root for entrypoint
USER root

# Copy configs
COPY Procfile /home/frappe/frappe-bench/Procfile
COPY common_site_config.json /home/frappe/frappe-bench/sites/common_site_config.json
RUN chown -R frappe:frappe /home/frappe/frappe-bench

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000 9000

ENTRYPOINT ["/entrypoint.sh"]
