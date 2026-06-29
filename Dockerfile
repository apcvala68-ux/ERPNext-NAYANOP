# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install ALL dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    mariadb-server \
    mariadb-client \
    redis-server \
    curl \
    wkhtmltopdf \
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

# Setup MariaDB
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

# Install frappe-bench
RUN pip3 install frappe-bench

# Create bench directory
RUN mkdir -p /home/frappe/frappe-bench
WORKDIR /home/frappe/frappe-bench

# Clone Frappe + ERPNext + HRMS
RUN bench init --skip-redis-config-generation --frappe-branch version-15 . \
    && bench get-app erpnext --branch version-15 \
    && bench get-app hrms --branch version-15

# Clone custom app
RUN bench get-app automotive_crm https://github.com/apcvala68-ux/ERPNext-NAYANOP.git --branch main

# Copy configs from repo root
COPY Procfile /home/frappe/frappe-bench/Procfile
COPY common_site_config.json /home/frappe/frappe-bench/sites/common_site_config.json

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000 9000

ENTRYPOINT ["/entrypoint.sh"]
