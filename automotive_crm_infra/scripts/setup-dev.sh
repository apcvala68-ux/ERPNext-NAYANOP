#!/bin/bash
# =============================================================================
# Automotive CRM - Local Development Setup Script
# =============================================================================
set -e

echo "🔧 Automotive CRM - Development Setup"
echo "======================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check prerequisites
check_prerequisites() {
    echo -e "\n${YELLOW}Checking prerequisites...${NC}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Docker is installed${NC}"
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose is not installed. Please install Docker Compose first.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Docker Compose is installed${NC}"
    
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git is not installed. Please install Git first.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Git is installed${NC}"
}

# Clone repositories
clone_repos() {
    echo -e "\n${YELLOW}Cloning repositories...${NC}"
    
    WORKSPACE_DIR="$(pwd)/workspace"
    mkdir -p "$WORKSPACE_DIR"
    cd "$WORKSPACE_DIR"
    
    # Fork repos if not exists
    if [ ! -d "frappe" ]; then
        echo "Cloning frappe..."
        git clone --branch version-15 https://github.com/frappe/frappe.git
    fi
    
    if [ ! -d "erpnext" ]; then
        echo "Cloning erpnext..."
        git clone --branch version-15 https://github.com/frappe/erpnext.git
    fi
    
    if [ ! -d "crm" ]; then
        echo "Cloning crm..."
        git clone --branch main https://github.com/frappe/crm.git
    fi
    
    if [ ! -d "hrms" ]; then
        echo "Cloning hrms..."
        git clone --branch version-15 https://github.com/frappe/hrms.git
    fi
    
    if [ ! -d "automotive_crm" ]; then
        echo "Cloning automotive_crm..."
        git clone https://github.com/YOUR_ORG/automotive_crm.git
    fi
    
    cd ..
}

# Start development environment
start_dev() {
    echo -e "\n${YELLOW}Starting development environment...${NC}"
    
    docker-compose -f docker/docker-compose.yml up -d
    
    echo -e "${GREEN}✓ Development environment started${NC}"
    echo -e "${GREEN}  - Application: http://localhost:8080${NC}"
    echo -e "${GREEN}  - MariaDB: localhost:3307${NC}"
    echo -e "${GREEN}  - Redis Cache: localhost:6380${NC}"
    echo -e "${GREEN}  - Redis Queue: localhost:6381${NC}"
}

# Initialize bench
init_bench() {
    echo -e "\n${YELLOW}Initializing bench...${NC}"
    
    docker-compose -f docker/docker-compose.yml exec backend bench init --skip-redis-config-generation frappe-bench || true
    
    echo -e "${GREEN}✓ Bench initialized${NC}"
}

# Main
main() {
    check_prerequisites
    clone_repos
    start_dev
    init_bench
    
    echo -e "\n${GREEN}✅ Development setup complete!${NC}"
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo "1. Wait for services to start (about 2 minutes)"
    echo "2. Open http://localhost:8080 in your browser"
    echo "3. Login with Administrator / admin"
    echo "4. Start developing!"
}

main "$@"
