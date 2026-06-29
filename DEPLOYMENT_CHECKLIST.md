# Deployment Checklist

## Pre-Deployment

### 1. GitHub Setup
- [ ] Create GitHub organization (`yourorg`)
- [ ] Fork `frappe/frappe` → `yourorg/frappe` (branch: `version-15`)
- [ ] Fork `frappe/erpnext` → `yourorg/erpnext` (branch: `version-15`)
- [ ] Fork `frappe/crm` → `yourorg/crm` (branch: `main`)
- [ ] Fork `frappe/hrms` → `yourorg/hrms` (branch: `version-15`)
- [ ] Create `yourorg/automotive_crm` repository
- [ ] Push code to `automotive_crm` repository
- [ ] Add `upstream` remote to all forks

### 2. Railway Setup
- [ ] Create Railway account
- [ ] Create new project
- [ ] Add MariaDB service
- [ ] Add Redis service
- [ ] Configure environment variables:
  ```
  DB_HOST=mariadb
  DB_PORT=3306
  DB_PASSWORD=<secure-password>
  ADMIN_PASSWORD=<secure-password>
  REDIS_CACHE=redis-cache:6379
  REDIS_QUEUE=redis-queue:6379
  SITES=<your-domain.com>
  ```

### 3. Domain Setup
- [ ] Purchase domain (if needed)
- [ ] Configure DNS to point to Railway
- [ ] Add custom domain in Railway
- [ ] Enable SSL/TLS

### 4. Code Preparation
- [ ] Update `apps.json` with your fork URLs
- [ ] Update `Dockerfile` with correct repository URLs
- [ ] Update `docker-compose.yml` with correct image names
- [ ] Update CI/CD workflows with correct repository names
- [ ] Update environment variables in scripts

---

## Deployment Steps

### Step 1: Build Docker Image
```bash
# Clone the repository
git clone https://github.com/yourorg/automotive-crm.git
cd automotive-crm

# Build the image
docker build -f automotive_crm_infra/docker/Dockerfile \
  --build-arg FRAPPE_BRANCH=version-15 \
  --build-arg ERPNEXT_BRANCH=version-15 \
  --build-arg HRMS_BRANCH=version-15 \
  --build-arg CRM_BRANCH=main \
  --build-arg APP_NAME=automotive_crm \
  --build-arg APP_BRANCH=main \
  --build-arg SITE_NAME=<your-domain.com> \
  --build-arg DB_HOST=<db-host> \
  --build-arg DB_PORT=3306 \
  --build-arg DB_PASSWORD=<db-password> \
  --build-arg ADMIN_PASSWORD=<admin-password> \
  -t automotive-crm:latest .
```

### Step 2: Push to Registry
```bash
# Tag the image
docker tag automotive-crm:latest ghcr.io/yourorg/automotive-crm:latest

# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# Push the image
docker push ghcr.io/yourorg/automotive-crm:latest
```

### Step 3: Deploy to Railway
```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Link to project
railway link

# Deploy
railway up --dockerfile automotive_crm_infra/docker/Dockerfile
```

### Step 4: Initialize Site
```bash
# Connect to the container
railway run bash

# Create site (if not created during build)
bench new-site <your-domain.com> \
  --mariadb-root-password <db-password> \
  --admin-password <admin-password>

# Install apps
bench --site <your-domain.com> install-app erpnext
bench --site <your-domain.com> install-app hrms
bench --site <your-domain.com> install-app crm
bench --site <your-domain.com> install-app automotive_crm

# Setup production
bench setup production frappe

# Restart
bench restart
```

### Step 5: Verify Deployment
```bash
# Check health
curl -f https://<your-domain.com>/api/method/ping

# Check site
bench --site <your-domain.com> console

# Check workers
bench --site <your-domain.com> doctor
```

---

## Post-Deployment

### 6. Initial Configuration
- [ ] Login to the application
- [ ] Complete setup wizard
- [ ] Create first OEM Customer
- [ ] Create first Part Master
- [ ] Configure email settings
- [ ] Configure notification settings

### 7. User Setup
- [ ] Create user accounts
- [ ] Assign roles (Sales Manager, Sales User)
- [ ] Configure user permissions
- [ ] Setup email signatures

### 8. Data Migration
- [ ] Import existing customer data
- [ ] Import existing part data
- [ ] Import historical quotations
- [ ] Import price lists

### 9. Testing
- [ ] Test RFQ workflow
- [ ] Test Quotation generation
- [ ] Test Cost Sheet calculation
- [ ] Test Quality Complaint flow
- [ ] Test 8D Report flow
- [ ] Test reports and dashboards

### 10. Monitoring Setup
- [ ] Configure health checks
- [ ] Setup alerting
- [ ] Configure logging
- [ ] Setup backups

---

## Maintenance

### Daily
- [ ] Check service health
- [ ] Review error logs
- [ ] Verify backups

### Weekly
- [ ] Review performance metrics
- [ ] Check security updates
- [ ] Cleanup old logs

### Monthly
- [ ] Merge upstream updates
- [ ] Review dependencies
- [ ] Performance optimization

### Quarterly
- [ ] Disaster recovery drill
- [ ] Security audit
- [ ] Architecture review

---

## Rollback Procedure

### If deployment fails:

1. **Check logs**
   ```bash
   railway logs
   ```

2. **Rollback to previous version**
   ```bash
   railway rollback
   ```

3. **Restore database backup**
   ```bash
   railway run bench --site <site-name> restore /path/to/backup.sql.gz
   ```

4. **Restart services**
   ```bash
   railway run bench restart
   ```

---

## Emergency Contacts

| Role | Name | Contact |
|------|------|---------|
| System Admin | TBD | admin@yourorg.com |
| Database Admin | TBD | dba@yourorg.com |
| Security | TBD | security@yourorg.com |

---

## Success Criteria

- [ ] Application accessible at https://<your-domain.com>
- [ ] All DocTypes visible in the menu
- [ ] Can create OEM Customer
- [ ] Can create RFQ
- [ ] Can create Quotation
- [ ] Reports are generating data
- [ ] Dashboards are displaying charts
- [ ] Email notifications working
- [ ] Backups running successfully
- [ ] Health checks passing
