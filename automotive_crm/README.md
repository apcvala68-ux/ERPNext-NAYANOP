# Automotive CRM

Enterprise-grade CRM for automotive parts manufacturers, built on Frappe Framework v15.

## Features

- **OEM Customer Management** - Track Tier 1/2/3 customers, plants, contacts
- **RFQ Management** - Automated RFQ processing with workflow
- **Cost Sheet Generation** - Material, labor, overhead, tooling, quality costs
- **Quotation Management** - Quick quotes and detailed quotations
- **PPAP Management** - Production Part Approval Process tracking
- **Quality Complaints** - 8D reports and corrective actions
- **Sales Forecasting** - AI-powered forecasting with accuracy tracking
- **OEM Visit Management** - Track customer visits and action items
- **Price List Management** - Part-specific pricing with validity periods
- **Multi-Currency Support** - International OEM sales support
- **Mobile PWA** - Progressive Web App for mobile access
- **Real-time Dashboards** - OEM, sales, and quality dashboards
- **Custom Reports** - 7 specialized automotive reports

## Architecture

```
automotive_crm/
├── automotive_crm/
│   ├── hooks.py                    # App configuration
│   ├── api/                        # Custom API endpoints
│   ├── doctype/                    # 15+ custom DocTypes
│   ├── report/                     # 7 custom reports
│   ├── dashboard/                  # 3 dashboards
│   ├── public/                     # CSS/JS assets
│   ├── templates/                  # Jinja templates
│   └── tests/                      # Unit/integration tests
└── automotive_crm_infra/
    ├── docker/                     # Docker configuration
    ├── ci/                         # CI/CD pipelines
    ├── scripts/                    # Development scripts
    ├── monitoring/                 # Health checks
    └── docs/                       # Documentation
```

## Quick Start

### Prerequisites

- Docker 24.0+
- Docker Compose 2.20+
- Git

### Local Development

```bash
# Clone the repository
git clone https://github.com/YOUR_ORG/automotive-crm.git
cd automotive-crm

# Run setup script
./automotive_crm_infra/scripts/setup-dev.sh

# Wait for services to start (about 2 minutes)
# Open http://localhost:8080
# Login: Administrator / admin
```

### Manual Setup

```bash
# Start services
docker-compose -f automotive_crm_infra/docker/docker-compose.yml up -d

# Wait for services to start
sleep 60

# Access the application
open http://localhost:8080
```

## Testing

```bash
# Run all tests
./automotive_crm_infra/scripts/run-tests.sh

# Run specific test suite
./automotive_crm_infra/scripts/run-tests.sh --site site1.localhost --app automotive_crm

# Run with coverage
./automotive_crm_infra/scripts/run-tests.sh --coverage
```

## Deployment

### Railway (Recommended)

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Deploy to staging
./automotive_crm_infra/scripts/deploy.sh staging

# Deploy to production
./automotive_crm_infra/scripts/deploy.sh production
```

### Docker

```bash
# Build image
docker build -f automotive_crm_infra/docker/Dockerfile -t automotive-crm .

# Run
docker run -p 8080:8000 automotive-crm
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_HOST` | MariaDB host | `mariadb` |
| `DB_PORT` | MariaDB port | `3306` |
| `DB_PASSWORD` | MariaDB password | `change-me` |
| `ADMIN_PASSWORD` | Frappe admin password | `admin` |
| `REDIS_CACHE` | Redis cache URL | `redis-cache:6379` |
| `REDIS_QUEUE` | Redis queue URL | `redis-queue:6379` |

### Railway Configuration

```bash
# Set environment variables
railway variables set DB_PASSWORD=your-secure-password
railway variables set ADMIN_PASSWORD=your-admin-password
railway variables set SITES=your-domain.com
```

## Documentation

- [Architecture](automotive_crm_infra/docs/architecture.md)
- [Runbook](automotive_crm_infra/docs/runbook.md)
- [API Documentation](automotive_crm_infra/docs/api-docs.md)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Proprietary - All rights reserved.

## Support

- Email: support@yourorg.com
- Documentation: https://docs.yourorg.com
- Issues: GitHub Issues
