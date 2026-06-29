# Operations Runbook

## Overview

This runbook provides operational procedures for the Automotive CRM system.

## Table of Contents

1. [Service Management](#service-management)
2. [Monitoring](#monitoring)
3. [Backup and Recovery](#backup-and-recovery)
4. [Troubleshooting](#troubleshooting)
5. [Maintenance](#maintenance)
6. [Security](#security)

---

## Service Management

### Starting Services

```bash
# Start all services
docker-compose -f automotive_crm_infra/docker/docker-compose.yml up -d

# Start specific service
docker-compose -f automotive_crm_infra/docker/docker-compose.yml up -d backend

# Check service status
docker-compose -f automotive_crm_infra/docker/docker-compose.yml ps
```

### Stopping Services

```bash
# Stop all services
docker-compose -f automotive_crm_infra/docker/docker-compose.yml down

# Stop specific service
docker-compose -f automotive_crm_infra/docker/docker-compose.yml stop backend
```

### Restarting Services

```bash
# Restart all services
docker-compose -f automotive_crm_infra/docker/docker-compose.yml restart

# Restart specific service
docker-compose -f automotive_crm_infra/docker/docker-compose.yml restart backend
```

### Viewing Logs

```bash
# View all logs
docker-compose -f automotive_crm_infra/docker/docker-compose.yml logs -f

# View specific service logs
docker-compose -f automotive_crm_infra/docker/docker-compose.yml logs -f backend

# View last 100 lines
docker-compose -f automotive_crm_infra/docker/docker-compose.yml logs --tail 100 backend
```

---

## Monitoring

### Health Checks

```bash
# Check application health
curl -f https://yourdomain.com/api/method/ping

# Check database health
mysqladmin ping -h localhost -u root -p

# Check Redis health
redis-cli ping
```

### Key Metrics

| Metric | Threshold | Action |
|--------|-----------|--------|
| CPU Usage | > 80% | Investigate processes |
| Memory Usage | > 85% | Scale up or optimize |
| Disk Usage | > 80% | Cleanup or expand |
| Response Time | > 2s | Check performance |
| Error Rate | > 1% | Investigate errors |

### Monitoring Commands

```bash
# Check container stats
docker stats

# Check disk usage
df -h

# Check memory usage
free -m

# Check processes
ps aux | grep bench
```

---

## Backup and Recovery

### Automated Backups

```bash
# Run backup script
./automotive_crm_infra/scripts/backup.sh

# Backup specific site
./automotive_crm_infra/scripts/backup.sh site1.localhost
```

### Manual Backup

```bash
# Backup database
docker-compose -f automotive_crm_infra/docker/docker-compose.yml exec backend \
    bench --site site1.localhost backup --with-files

# Backup files
docker-compose -f automotive_crm_infra/docker/docker-compose.yml exec backend \
    tar -czf /tmp/backup_files.tar.gz \
    -C /home/frappe/frappe-bench/sites/site1.localhost \
    public files private
```

### Recovery

```bash
# Restore database
docker-compose -f automotive_crm_infra/docker/docker-compose.yml exec backend \
    bench --site site1.localhost restore /path/to/backup.sql.gz

# Restore files
docker-compose -f automotive_crm_infra/docker/docker-compose.yml exec backend \
    tar -xzf /path/to/backup_files.tar.gz \
    -C /home/frappe/frappe-bench/sites/site1.localhost
```

---

## Troubleshooting

### Common Issues

#### Issue: Application not starting

```bash
# Check logs
docker-compose -f automotive_crm_infra/docker/docker-compose.yml logs backend

# Check if ports are in use
netstat -tulpn | grep -E '8080|3306|6379'

# Restart services
docker-compose -f automotive_crm_infra/docker/docker-compose.yml restart
```

#### Issue: Database connection failed

```bash
# Check MariaDB status
docker-compose -f automotive_crm_infra/docker/docker-compose.yml logs mariadb

# Check if MariaDB is running
docker-compose -f automotive_crm_infra/docker/docker-compose.yml ps mariadb

# Restart MariaDB
docker-compose -f automotive_crm_infra/docker/docker-compose.yml restart mariadb
```

#### Issue: Redis connection failed

```bash
# Check Redis status
docker-compose -f automotive_crm_infra/docker/docker-compose.yml logs redis-cache

# Check if Redis is running
docker-compose -f automotive_crm_infra/docker/docker-compose.yml ps redis-cache

# Restart Redis
docker-compose -f automotive_crm_infra/docker/docker-compose.yml restart redis-cache
```

#### Issue: High memory usage

```bash
# Check container stats
docker stats

# Restart heavy containers
docker-compose -f automotive_crm_infra/docker/docker-compose.yml restart backend

# Clear cache
docker-compose -f automotive_crm_infra/docker/docker-compose.yml exec backend \
    bench --site site1.localhost clear-cache
```

#### Issue: Slow performance

```bash
# Check slow queries
docker-compose -f automotive_crm_infra/docker/docker-compose.yml exec mariadb \
    mysql -u root -p -e "SHOW PROCESSLIST;"

# Check cache hit rate
docker-compose -f automotive_crm_infra/docker/docker-compose.yml exec redis-cache \
    redis-cli INFO stats

# Optimize tables
docker-compose -f automotive_crm_infra/docker/docker-compose.yml exec mariadb \
    mysqlcheck -u root -p --optimize --all-databases
```

### Emergency Procedures

#### Service Down

1. Check service status
2. Review logs for errors
3. Restart affected service
4. Verify health check
5. Notify team

#### Database Corruption

1. Stop application
2. Take backup of current state
3. Restore from last known good backup
4. Apply any missing transactions
5. Verify data integrity
6. Restart application

#### Security Incident

1. Isolate affected systems
2. Preserve logs and evidence
3. Assess impact
4. Notify security team
5. Implement fixes
6. Document incident

---

## Maintenance

### Daily Tasks

- [ ] Check service health
- [ ] Review error logs
- [ ] Verify backups completed
- [ ] Monitor resource usage

### Weekly Tasks

- [ ] Review performance metrics
- [ ] Check security updates
- [ ] Cleanup old logs
- [ ] Verify backup integrity

### Monthly Tasks

- [ ] Merge upstream updates
- [ ] Review dependencies
- [ ] Performance optimization
- [ ] Security audit

### Quarterly Tasks

- [ ] Disaster recovery drill
- [ ] Capacity planning
- [ ] Architecture review
- [ ] Documentation update

---

## Security

### Security Checklist

- [ ] Strong admin password
- [ ] 2FA enabled for admin
- [ ] HTTPS only
- [ ] Firewall configured
- [ ] Regular security updates
- [ ] Audit logging enabled
- [ ] Backup encryption
- [ ] Access controls reviewed

### Security Commands

```bash
# Check for security updates
apt list --upgradable

# Run security scan
bandit -r automotive_crm/ -c pyproject.toml

# Check open ports
netstat -tulpn

# Review authentication logs
tail -f /var/log/auth.log
```

---

## Contact Information

| Role | Name | Contact |
|------|------|---------|
| System Admin | TBD | admin@yourorg.com |
| Database Admin | TBD | dba@yourorg.com |
| Security | TBD | security@yourorg.com |
| Support | TBD | support@yourorg.com |

---

## Emergency Contacts

| Service | Provider | Contact |
|---------|----------|---------|
| Railway | Railway Support | support@railway.app |
| DNS | Cloudflare | support@cloudflare.com |
| Email | Gmail | support@google.com |

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-06-29 | Initial runbook |
