#!/bin/bash
# =============================================================================
# Automotive CRM - Backup Script
# =============================================================================
set -e

echo "💾 Automotive CRM - Backup"
echo "=========================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
SITE="${1:-site1.localhost}"
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="automotive_crm_${DATE}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup database
backup_database() {
    echo -e "\n${YELLOW}Backing up database...${NC}"
    
    docker-compose -f docker/docker-compose.yml exec backend \
        bench --site "$SITE" backup --with-files
    
    echo -e "${GREEN}✓ Database backup completed${NC}"
}

# Backup files
backup_files() {
    echo -e "\n${YELLOW}Backing up files...${NC}"
    
    docker-compose -f docker/docker-compose.yml exec backend \
        tar -czf "/tmp/${BACKUP_NAME}_files.tar.gz" \
        -C /home/frappe/frappe-bench/sites/"$SITE" \
        public files private
    
    docker-compose -f docker/docker-compose.yml cp \
        backend:/tmp/${BACKUP_NAME}_files.tar.gz \
        "$BACKUP_DIR/"
    
    echo -e "${GREEN}✓ Files backup completed${NC}"
}

# Cleanup old backups
cleanup_old_backups() {
    echo -e "\n${YELLOW}Cleaning up old backups...${NC}"
    
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete
    
    echo -e "${GREEN}✓ Old backups cleaned up${NC}"
}

# Main
main() {
    echo "Site: $SITE"
    echo "Backup directory: $BACKUP_DIR"
    
    backup_database
    backup_files
    cleanup_old_backups
    
    echo -e "\n${GREEN}✅ Backup completed!${NC}"
    echo -e "Backup location: $BACKUP_DIR"
}

main "$@"
