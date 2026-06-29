#!/bin/bash
# =============================================================================
# Automotive CRM - Local Development Setup (No Docker)
# =============================================================================
set -e

echo "🔧 Automotive CRM - Local Development Setup"
echo "============================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check prerequisites
check_prerequisites() {
    echo -e "\n${YELLOW}Checking prerequisites...${NC}"
    
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}❌ Python3 is not installed.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Python3 is installed${NC}"
    
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js is not installed.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Node.js is installed${NC}"
    
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}❌ npm is not installed.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ npm is installed${NC}"
    
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git is not installed.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Git is installed${NC}"
    
    # Check for MariaDB or MySQL
    if ! command -v mysql &> /dev/null; then
        echo -e "${YELLOW}⚠️  MariaDB/MySQL not found. Will attempt to install.${NC}"
    else
        echo -e "${GREEN}✓ MariaDB/MySQL is installed${NC}"
    fi
    
    # Check for Redis
    if ! command -v redis-cli &> /dev/null; then
        echo -e "${YELLOW}⚠️  Redis not found. Will attempt to install.${NC}"
    else
        echo -e "${GREEN}✓ Redis is installed${NC}"
    fi
}

# Install system dependencies
install_dependencies() {
    echo -e "\n${YELLOW}Installing system dependencies...${NC}"
    
    # Install MariaDB
    if ! command -v mysql &> /dev/null; then
        echo "Installing MariaDB..."
        sudo apt-get update
        sudo apt-get install -y mariadb-server mariadb-client
        sudo systemctl start mariadb
        sudo systemctl enable mariadb
    fi
    
    # Install Redis
    if ! command -v redis-cli &> /dev/null; then
        echo "Installing Redis..."
        sudo apt-get install -y redis-server
        sudo systemctl start redis-server
        sudo systemctl enable redis-server
    fi
    
    # Install other dependencies
    sudo apt-get install -y \
        python3-dev \
        python3-pip \
        python3-venv \
        libmysqlclient-dev \
        wkhtmltopdf \
        xvfb
    
    echo -e "${GREEN}✓ Dependencies installed${NC}"
}

# Setup Frappe Bench
setup_bench() {
    echo -e "\n${YELLOW}Setting up Frappe Bench...${NC}"
    
    WORKSPACE_DIR="$(pwd)/workspace"
    mkdir -p "$WORKSPACE_DIR"
    cd "$WORKSPACE_DIR"
    
    # Install frappe-bench
    pip3 install frappe-bench
    
    # Initialize bench
    if [ ! -d "frappe-bench" ]; then
        echo "Initializing Frappe Bench..."
        bench init --skip-redis-config-generation --frappe-branch version-15 frappe-bench
    fi
    
    cd frappe-bench
    
    # Get apps
    echo "Cloning ERPNext..."
    bench get-app erpnext --branch version-15 || true
    
    echo "Cloning HRMS..."
    bench get-app hrms --branch version-15 || true
    
    echo "Cloning Frappe CRM..."
    bench get-app crm --branch main || true
    
    echo "Cloning Automotive CRM..."
    if [ ! -d "apps/automotive_crm" ]; then
        git clone https://github.com/apcvala68-ux/ERPNext-NAYANOP.git apps/automotive_crm
    fi
    
    echo -e "${GREEN}✓ Frappe Bench setup complete${NC}"
}

# Create site
create_site() {
    echo -e "\n${YELLOW}Creating site...${NC}"
    
    cd frappe-bench
    
    # Create site
    if [ ! -d "sites/localhost" ]; then
        bench new-site localhost \
            --mariadb-root-password "" \
            --admin-password admin
    fi
    
    # Install apps
    bench --site localhost install-app erpnext
    bench --site localhost install-app hrms
    bench --site localhost install-app crm
    bench --site localhost install-app automotive_crm
    
    echo -e "${GREEN}✓ Site created and apps installed${NC}"
}

# Start development server
start_server() {
    echo -e "\n${YELLOW}Starting development server...${NC}"
    
    cd frappe-bench
    
    # Start bench
    bench start &
    
    echo -e "${GREEN}✓ Development server started${NC}"
    echo -e "${GREEN}  - Application: http://localhost:8000${NC}"
    echo -e "${GREEN}  - Login: Administrator / admin${NC}"
}

# Main
main() {
    check_prerequisites
    install_dependencies
    setup_bench
    create_site
    start_server
    
    echo -e "\n${GREEN}✅ Local development setup complete!${NC}"
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo "1. Open http://localhost:8000 in your browser"
    echo "2. Login with Administrator / admin"
    echo "3. Start developing!"
    echo -e "\n${YELLOW}Useful commands:${NC}"
    echo "cd workspace/frappe-bench"
    echo "bench start              # Start the server"
    echo "bench --site localhost console  # Open console"
    echo "bench migrate            # Run migrations"
    echo "bench clear-cache        # Clear cache"
}

main "$@"
