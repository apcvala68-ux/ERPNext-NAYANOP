#!/bin/bash
# =============================================================================
# Automotive CRM - Run Tests Script
# =============================================================================
set -e

echo "🧪 Automotive CRM - Run Tests"
echo "=============================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default site
SITE="${1:-site1.localhost}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --site)
            SITE="$2"
            shift 2
            ;;
        --app)
            APP="$2"
            shift 2
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --verbose)
            VERBOSE="-v"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Run unit tests
run_unit_tests() {
    echo -e "\n${YELLOW}Running unit tests...${NC}"
    
    if [ "$COVERAGE" = true ]; then
        docker-compose -f docker/docker-compose.yml exec backend \
            bench --site "$SITE" run-tests \
            --app "${APP:-automotive_crm}" \
            --coverage \
            $VERBOSE
    else
        docker-compose -f docker/docker-compose.yml exec backend \
            bench --site "$SITE" run-tests \
            --app "${APP:-automotive_crm}" \
            $VERBOSE
    fi
    
    echo -e "${GREEN}✓ Unit tests passed${NC}"
}

# Run integration tests
run_integration_tests() {
    echo -e "\n${YELLOW}Running integration tests...${NC}"
    
    docker-compose -f docker/docker-compose.yml exec backend \
        pytest automotive_crm/tests/integration/ \
        -v \
        --tb=short
    
    echo -e "${GREEN}✓ Integration tests passed${NC}"
}

# Run E2E tests
run_e2e_tests() {
    echo -e "\n${YELLOW}Running E2E tests...${NC}"
    
    docker-compose -f docker/docker-compose.yml exec backend \
        pytest automotive_crm/tests/e2e/ \
        -v \
        --tb=short
    
    echo -e "${GREEN}✓ E2E tests passed${NC}"
}

# Run linting
run_linting() {
    echo -e "\n${YELLOW}Running linting...${NC}"
    
    docker-compose -f docker/docker-compose.yml exec backend \
        ruff check .
    
    docker-compose -f docker/docker-compose.yml exec backend \
        ruff format --check .
    
    echo -e "${GREEN}✓ Linting passed${NC}"
}

# Run security scan
run_security_scan() {
    echo -e "\n${YELLOW}Running security scan...${NC}"
    
    docker-compose -f docker/docker-compose.yml exec backend \
        bandit -r automotive_crm/ -c pyproject.toml
    
    echo -e "${GREEN}✓ Security scan passed${NC}"
}

# Main
main() {
    echo "Site: $SITE"
    echo "App: ${APP:-automotive_crm}"
    
    run_linting
    run_unit_tests
    run_integration_tests
    run_e2e_tests
    run_security_scan
    
    echo -e "\n${GREEN}✅ All tests passed!${NC}"
}

main "$@"
