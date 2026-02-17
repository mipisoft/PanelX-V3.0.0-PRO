#!/bin/bash

# PanelX Complete Installation Script for Ubuntu 24.04
# This script installs PanelX with all dependencies and proper configuration

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DB_NAME="panelx"
DB_USER="panelx"
DB_PASS="panelx123"
INSTALL_DIR="/opt/panelx"
SERVICE_NAME="panelx"
PORT="5000"

echo -e "${BLUE}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "           🚀 PanelX Installation Script v3.0.0                  "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"

# Check if running as root and set variables accordingly
if [[ $EUID -eq 0 ]]; then
   print_info "Running as root user"
   RUN_USER="root"
   SUDO_CMD=""
else
   print_info "Running as regular user with sudo"
   RUN_USER="$USER"
   SUDO_CMD="sudo"
fi

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Step 1: Update system
echo ""
echo -e "${BLUE}━━━ Step 1/12: Updating System ━━━${NC}"
$SUDO_CMD apt update
$SUDO_CMD apt upgrade -y
print_status "System updated"

# Step 2: Install Node.js 20.x
echo ""
echo -e "${BLUE}━━━ Step 2/12: Installing Node.js 20.x ━━━${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    print_info "Node.js already installed: $NODE_VERSION"
else
    curl -fsSL https://deb.nodesource.com/setup_20.x | $SUDO_CMD -E bash -
    $SUDO_CMD apt install -y nodejs
    print_status "Node.js installed: $(node -v)"
fi

# Step 3: Install required packages
echo ""
echo -e "${BLUE}━━━ Step 3/12: Installing Dependencies ━━━${NC}"
$SUDO_CMD apt install -y git build-essential postgresql postgresql-contrib ffmpeg curl
print_status "Dependencies installed"

# Step 4: Configure PostgreSQL
echo ""
echo -e "${BLUE}━━━ Step 4/12: Configuring PostgreSQL ━━━${NC}"

# Find PostgreSQL version and config path
PG_VERSION=$(psql --version | grep -oP '\d+' | head -1)
PG_HBA_CONF="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

print_info "PostgreSQL version: $PG_VERSION"

# Backup original pg_hba.conf
if [ ! -f "${PG_HBA_CONF}.backup" ]; then
    $SUDO_CMD cp "$PG_HBA_CONF" "${PG_HBA_CONF}.backup"
    print_status "PostgreSQL config backed up"
fi

# Configure authentication to use md5 instead of peer
$SUDO_CMD sed -i 's/local   all             all                                     peer/local   all             all                                     md5/' "$PG_HBA_CONF"
$SUDO_CMD sed -i 's/local   all             all                                     scram-sha-256/local   all             all                                     md5/' "$PG_HBA_CONF"

# Restart PostgreSQL
$SUDO_CMD systemctl restart postgresql
print_status "PostgreSQL configured and restarted"

# Step 5: Create database and user
echo ""
echo -e "${BLUE}━━━ Step 5/12: Creating Database ━━━${NC}"

# Drop existing database/user if exists
$SUDO_CMD -u postgres psql << EOF
DROP DATABASE IF EXISTS $DB_NAME;
DROP USER IF EXISTS $DB_USER;
EOF

# Create new user and database
$SUDO_CMD -u postgres psql << EOF
CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
CREATE DATABASE $DB_NAME OWNER $DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
ALTER USER $DB_USER WITH SUPERUSER;
\c $DB_NAME
GRANT ALL ON SCHEMA public TO $DB_USER;
EOF

print_status "Database '$DB_NAME' created with user '$DB_USER'"

# Test database connection
print_info "Testing database connection..."
PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d $DB_NAME -c "SELECT 'Connection successful!' as status;" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_status "Database connection test passed"
else
    print_error "Database connection test failed"
    exit 1
fi

# Step 6: Clone repository
echo ""
echo -e "${BLUE}━━━ Step 6/12: Cloning PanelX Repository ━━━${NC}"

# Remove old installation if exists
if [ -d "$INSTALL_DIR" ]; then
    print_warning "Existing installation found at $INSTALL_DIR"
    read -p "Remove and reinstall? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        $SUDO_CMD rm -rf "$INSTALL_DIR"
        print_status "Old installation removed"
    else
        print_error "Installation cancelled"
        exit 1
    fi
fi

# Clone repository
$SUDO_CMD git clone https://github.com/mipisoft/PanelX-V3.0.0-PRO.git "$INSTALL_DIR"
if [[ $EUID -ne 0 ]]; then
    $SUDO_CMD chown -R $USER:$USER "$INSTALL_DIR"
fi
print_status "Repository cloned to $INSTALL_DIR"

# Step 7: Install npm packages
echo ""
echo -e "${BLUE}━━━ Step 7/12: Installing NPM Packages ━━━${NC}"
cd "$INSTALL_DIR"
npm install --silent
print_status "NPM packages installed"

# Step 8: Create environment file
echo ""
echo -e "${BLUE}━━━ Step 8/12: Creating Environment File ━━━${NC}"
cat > "$INSTALL_DIR/.env" << EOF
DATABASE_URL=postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME
PORT=$PORT
NODE_ENV=production
SESSION_SECRET=$(openssl rand -hex 32)
EOF

print_status "Environment file created"
print_info "Database URL: postgresql://$DB_USER:****@localhost:5432/$DB_NAME"

# Step 9: Initialize database schema
echo ""
echo -e "${BLUE}━━━ Step 9/12: Initializing Database Schema ━━━${NC}"
cd "$INSTALL_DIR"
npm run db:push
print_status "Database schema created"

# Verify tables were created
print_info "Verifying database tables..."
PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d $DB_NAME -c "\dt" | grep -q "users"
if [ $? -eq 0 ]; then
    print_status "Database tables verified"
else
    print_error "Database tables not found!"
    exit 1
fi

# Step 10: Create systemd service
echo ""
echo -e "${BLUE}━━━ Step 10/12: Creating Systemd Service ━━━${NC}"
$SUDO_CMD tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null << EOF
[Unit]
Description=PanelX IPTV Management Panel
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=$RUN_USER
WorkingDirectory=$INSTALL_DIR
EnvironmentFile=$INSTALL_DIR/.env
ExecStart=/usr/bin/npx tsx server/index.ts
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

print_status "Systemd service created"

# Step 11: Configure firewall
echo ""
echo -e "${BLUE}━━━ Step 11/12: Configuring Firewall ━━━${NC}"
$SUDO_CMD ufw allow $PORT/tcp > /dev/null 2>&1 || true
$SUDO_CMD ufw allow 22/tcp > /dev/null 2>&1 || true
$SUDO_CMD ufw --force enable > /dev/null 2>&1 || true
print_status "Firewall configured (Port $PORT allowed)"

# Step 12: Start service
echo ""
echo -e "${BLUE}━━━ Step 12/12: Starting PanelX Service ━━━${NC}"
$SUDO_CMD systemctl daemon-reload
$SUDO_CMD systemctl enable $SERVICE_NAME
$SUDO_CMD systemctl start $SERVICE_NAME

# Wait for service to start
sleep 5

# Check service status
if $SUDO_CMD systemctl is-active --quiet $SERVICE_NAME; then
    print_status "PanelX service started successfully"
else
    print_error "PanelX service failed to start"
    echo ""
    echo -e "${YELLOW}Check logs with: $SUDO_CMD journalctl -u $SERVICE_NAME -n 50${NC}"
    exit 1
fi

# Test API
echo ""
print_info "Testing API endpoint..."
sleep 2
if curl -s http://localhost:$PORT/api/stats > /dev/null 2>&1; then
    print_status "API is responding"
    API_RESPONSE=$(curl -s http://localhost:$PORT/api/stats | head -c 200)
    echo -e "${GREEN}$API_RESPONSE...${NC}"
else
    print_warning "API not responding yet (might need more time to start)"
fi

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Installation complete
echo ""
echo -e "${GREEN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "                    ✅ Installation Complete!                    "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"
echo ""
echo -e "${BLUE}📊 Installation Summary:${NC}"
echo "   • PanelX installed to: $INSTALL_DIR"
echo "   • Database: $DB_NAME"
echo "   • Database User: $DB_USER"
echo "   • Service: $SERVICE_NAME"
echo "   • Port: $PORT"
echo ""
echo -e "${GREEN}🌐 Access Your Panel:${NC}"
echo "   • URL: http://$SERVER_IP:$PORT"
echo "   • Local: http://localhost:$PORT"
echo ""
echo -e "${GREEN}👤 Default Login Credentials:${NC}"
echo "   • Username: admin"
echo "   • Password: admin123"
echo ""
echo -e "${BLUE}📋 Useful Commands:${NC}"
echo "   • Check status:  $SUDO_CMD systemctl status $SERVICE_NAME"
echo "   • View logs:     $SUDO_CMD journalctl -u $SERVICE_NAME -f"
echo "   • Restart:       $SUDO_CMD systemctl restart $SERVICE_NAME"
echo "   • Stop:          $SUDO_CMD systemctl stop $SERVICE_NAME"
echo "   • Start:         $SUDO_CMD systemctl start $SERVICE_NAME"
echo ""
echo -e "${YELLOW}⚠️  Important:${NC}"
echo "   • Change admin password after first login!"
echo "   • Clear browser cache: Ctrl+Shift+R"
echo "   • Keep your system updated: $SUDO_CMD apt update && $SUDO_CMD apt upgrade"
echo ""
echo -e "${GREEN}🎉 Enjoy your PanelX panel!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
