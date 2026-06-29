#!/bin/bash
# =============================================================================
# Automotive CRM - Deploy Script
# =============================================================================
set -e

echo "🚀 Automotive CRM - Deploy"
echo "==========================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse arguments
ENVIRONMENT="${1:-staging}"
SITE="${2:-site1.localhost}"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
    echo -e "${RED}❌ Invalid environment: $ENVIRONMENT${NC}"
    echo "Usage: $0 <staging|production> [site-name]"
    exit 1
fi

# Check Railway CLI
check_railway() {
    if ! command -v railway &> /dev/null; then
        echo -e "${RED}❌ Railway CLI is not installed.${NC}"
        echo "Install with: npm i -g @railway/cli"
        exit 1
    fi
    echo -e "${GREEN}✓ Railway CLI is installed${NC}"
}

# Login to Railway
login_railway() {
    echo -e "\n${YELLOW}Logging in to Railway...${NC}"
    
    if [ -z "$RAILWAY_TOKEN" ]; then
        railway login
    else
        echo "Using RAILWAY_TOKEN from environment"
    fi
    
    echo -e "${GREEN}✓ Logged in to Railway${NC}"
}

# Deploy
deploy() {
    echo -e "\n${YELLOW}Deploying to $ENVIRONMENT...${NC}"
    
    railway service set "automotive-crm-$ENVIRONMENT"
    railway up --dockerfile docker/Dockerfile
    
    echo -e "${GREEN}✓ Deployment started${NC}"
}

# Run migrations
run_migrations() {
    echo -e "\n${YELLOW}Running migrations...${NC}"
    
    railway run bench --site "$SITE" migrate
    railway run bench --site "$SITE" clear-cache
    
    echo -e "${GREEN}✓ Migrations completed${NC}"
}

# Health check
health_check() {
    echo -e "\n${YELLOW}Running health check...${NC}"
    
    sleep 60
    
    for i in {1..15}; do
        if curl -sf "https://$SITE/api/method/ping"; then
            echo -e "\n${GREEN}✓ Health check passed${NC}"
            return 0
        fi
        echo "Attempt $i failed, retrying in 30s..."
        sleep 30
    done
    
    echo -e "\n${RED}❌ Health check failed${NC}"
    return 1
}

# Notify
notify() {
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        if [ $1 -eq 0 ]; then
            curl -X POST -H 'Content-type: application/json' \
                --data "{\"text\":\"✅ $ENVIRONMENT deployment successful for $(git rev-parse --short HEAD)\"}" \
                "$SLACK_WEBHOOK_URL"
        else
            curl -X POST -H 'Content-type: application/json' \
                --data "{\"text\":\"❌ $ENVIRONMENT deployment FAILED for $(git rev-parse --short HEAD)\"}" \
                "$SLACK_WEBHOOK_URL"
        fi
    fi
}

# Main
main() {
    check_railway
    login_railway
    deploy
    run_migrations
    
    if health_check; then
        notify 0
        echo -e "\n${GREEN}✅ Deployment successful!${NC}"
    else
        notify 1
        echo -e "\n${RED}❌ Deployment failed${NC}"
        exit 1
    fi
}

main "$@"
