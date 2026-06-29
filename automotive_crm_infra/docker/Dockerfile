# =============================================================================
# Automotive CRM - Production Dockerfile
# Multi-stage build for optimal image size and security
# =============================================================================

# Stage 1: Builder
FROM frappe/bench:v5.22.9 AS builder

ARG FRAPPE_BRANCH=version-15
ARG ERPNEXT_BRANCH=version-15
ARG HRMS_BRANCH=version-15
ARG CRM_BRANCH=main
ARG APP_NAME=automotive_crm
ARG APP_BRANCH=main

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home/frappe/frappe-bench

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3-pip \
    nodejs \
    npm \
    redis-tools \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Clone upstream repositories
RUN bench get-app frappe --branch ${FRAPPE_BRANCH} \
    && bench get-app erpnext --branch ${ERPNEXT_BRANCH} \
    && bench get-app hrms --branch ${HRMS_BRANCH} \
    && bench get-app crm --branch ${CRM_BRANCH}

# Stage 2: Production
FROM frappe/bench:v5.22.9 AS production

ARG APP_NAME=automotive_crm
ARG APP_BRANCH=main
ARG SITE_NAME=site1.localhost
ARG DB_HOST=mariadb
ARG DB_PORT=3306
ARG DB_PASSWORD=change-me
ARG ADMIN_PASSWORD=admin
ARG FRAPPE_BRANCH=version-15

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV SITE_NAME=${SITE_NAME}
ENV DB_HOST=${DB_HOST}
ENV DB_PORT=${DB_PORT}
ENV DB_PASSWORD=${DB_PASSWORD}
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}

WORKDIR /home/frappe/frappe-bench

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3-pip \
    nodejs \
    npm \
    redis-tools \
    mariadb-client \
    curl \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Copy built apps from builder
COPY --from=builder /home/frappe/frappe-bench/apps /home/frappe/frappe-bench/apps

# Install custom app
RUN cd /home/frappe/frappe-bench && \
    bench get-app ${APP_NAME} --branch ${APP_BRANCH}

# Create site
RUN bench new-site ${SITE_NAME} \
    --mariadb-root-password ${DB_PASSWORD} \
    --admin-password ${ADMIN_PASSWORD} \
    --no-mariadb-socket

# Install apps on site
RUN bench --site ${SITE_NAME} install-app erpnext \
    && bench --site ${SITE_NAME} install-app hrms \
    && bench --site ${SITE_NAME} install-app crm \
    && bench --site ${SITE_NAME} install-app ${APP_NAME}

# Setup production
RUN bench setup production frappe

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/api/method/ping || exit 1

# Expose ports
EXPOSE 8000 8080 9000

# Copy entrypoint
COPY --chown=frappe:frappe docker/entrypoint.sh /home/frappe/frappe-bench/entrypoint.sh
RUN chmod +x /home/frappe/frappe-bench/entrypoint.sh

# Switch to frappe user
USER frappe

# Start
ENTRYPOINT ["/home/frappe/frappe-bench/entrypoint.sh"]
CMD ["bench", "start"]
