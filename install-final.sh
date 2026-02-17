#!/bin/bash

# PanelX Complete Installation Script
# Tested and working version for Ubuntu 24.04

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DB_NAME="panelx"
DB_USER="panelx"
DB_PASS="panelx123"
INSTALL_DIR="/opt/panelx"
PORT="5000"

echo -e "${BLUE}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "           🚀 PanelX Installation Script v3.0.1                  "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"
echo ""

# Step 1: Update system
echo -e "${BLUE}━━━ Step 1/12: Updating System ━━━${NC}"
apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y > /dev/null 2>&1
echo -e "${GREEN}✅ System updated${NC}"
echo ""

# Step 2: Install Node.js
echo -e "${BLUE}━━━ Step 2/12: Installing Node.js 20.x ━━━${NC}"
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs > /dev/null 2>&1
fi

# Ensure node and npm are in PATH
export PATH="/usr/bin:/usr/local/bin:$PATH"
source /etc/profile 2>/dev/null || true

# Verify installations
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    echo -e "${GREEN}✅ Node.js $(node -v) installed${NC}"
    echo -e "${GREEN}✅ npm $(npm -v) installed${NC}"
else
    echo -e "${RED}❌ Node.js installation failed${NC}"
    exit 1
fi
echo ""

# Step 3: Install dependencies
echo -e "${BLUE}━━━ Step 3/12: Installing Dependencies ━━━${NC}"
DEBIAN_FRONTEND=noninteractive apt-get install -y git build-essential postgresql postgresql-contrib ffmpeg curl > /dev/null 2>&1
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Step 4: Configure PostgreSQL
echo -e "${BLUE}━━━ Step 4/12: Configuring PostgreSQL ━━━${NC}"
PG_VERSION=$(ls /etc/postgresql/ | head -1)
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

if [ -f "$PG_HBA" ]; then
    cp "$PG_HBA" "${PG_HBA}.backup" 2>/dev/null || true
    sed -i 's/local   all             all                                     peer/local   all             all                                     md5/g' "$PG_HBA"
    sed -i 's/local   all             all                                     scram-sha-256/local   all             all                                     md5/g' "$PG_HBA"
    systemctl restart postgresql
    echo -e "${GREEN}✅ PostgreSQL configured${NC}"
else
    echo -e "${YELLOW}⚠️  PostgreSQL config not found at expected location${NC}"
fi
echo ""

# Step 5: Create database
echo -e "${BLUE}━━━ Step 5/12: Creating Database ━━━${NC}"
sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;" 2>/dev/null || true
sudo -u postgres psql -c "DROP USER IF EXISTS $DB_USER;" 2>/dev/null || true
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
sudo -u postgres psql -c "ALTER USER $DB_USER WITH SUPERUSER;"
sudo -u postgres psql -d $DB_NAME -c "GRANT ALL ON SCHEMA public TO $DB_USER;"

# Test connection
if PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d $DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Database created and tested${NC}"
else
    echo -e "${RED}❌ Database connection failed${NC}"
    exit 1
fi
echo ""

# Step 6: Clone repository
echo -e "${BLUE}━━━ Step 6/12: Cloning PanelX Repository ━━━${NC}"
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  Removing existing installation...${NC}"
    rm -rf "$INSTALL_DIR"
fi
git clone https://github.com/mipisoft/PanelX-V3.0.0-PRO.git "$INSTALL_DIR" > /dev/null 2>&1
echo -e "${GREEN}✅ Repository cloned to $INSTALL_DIR${NC}"
echo ""

# Step 7: Install npm packages
echo -e "${BLUE}━━━ Step 7/12: Installing NPM Packages ━━━${NC}"
cd "$INSTALL_DIR"

# Double-check npm is available
if ! command -v npm &> /dev/null; then
    echo -e "${YELLOW}⚠️  npm not found, installing...${NC}"
    DEBIAN_FRONTEND=noninteractive apt-get install -y npm > /dev/null 2>&1
    export PATH="/usr/bin:$PATH"
fi

npm install > /dev/null 2>&1
echo -e "${GREEN}✅ NPM packages installed${NC}"
echo ""

# Step 8: Create environment file
echo -e "${BLUE}━━━ Step 8/12: Creating Environment File ━━━${NC}"
cat > "$INSTALL_DIR/.env" << EOF
DATABASE_URL=postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME
PORT=$PORT
NODE_ENV=production
SESSION_SECRET=$(openssl rand -hex 32)
EOF
echo -e "${GREEN}✅ Environment file created${NC}"
echo ""

# Step 9: Initialize database schema
echo -e "${BLUE}━━━ Step 9/12: Initializing Database Schema ━━━${NC}"
cd "$INSTALL_DIR"
npm run db:push > /dev/null 2>&1
echo -e "${GREEN}✅ Database schema created${NC}"
echo ""

# Step 10: Create systemd service
echo -e "${BLUE}━━━ Step 10/12: Creating Systemd Service ━━━${NC}"
cat > /etc/systemd/system/panelx.service << 'EOF'
[Unit]
Description=PanelX IPTV Management Panel
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/panelx
EnvironmentFile=/opt/panelx/.env
ExecStart=/usr/bin/npx tsx server/index.ts
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
echo -e "${GREEN}✅ Systemd service created${NC}"
echo ""

# Step 11: Configure firewall
echo -e "${BLUE}━━━ Step 11/12: Configuring Firewall ━━━${NC}"
if command -v ufw &> /dev/null; then
    ufw allow $PORT/tcp > /dev/null 2>&1 || true
    ufw allow 22/tcp > /dev/null 2>&1 || true
    echo -e "${GREEN}✅ Firewall configured${NC}"
else
    echo -e "${YELLOW}⚠️  UFW not installed, skipping firewall config${NC}"
fi
echo ""

# Step 12: Start service
echo -e "${BLUE}━━━ Step 12/12: Starting PanelX Service ━━━${NC}"
systemctl daemon-reload
systemctl enable panelx > /dev/null 2>&1
systemctl start panelx

# Wait for service to start
sleep 5

if systemctl is-active --quiet panelx; then
    echo -e "${GREEN}✅ PanelX service started successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Service may need more time to start${NC}"
fi
echo ""

# Test API
sleep 2
if curl -s http://localhost:$PORT/api/stats > /dev/null 2>&1; then
    echo -e "${GREEN}✅ API is responding${NC}"
else
    echo -e "${YELLOW}⚠️  API not responding yet (may need more time)${NC}"
fi
echo ""

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Final message
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
echo "   • Service: panelx"
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
echo "   • Check status:  systemctl status panelx"
echo "   • View logs:     journalctl -u panelx -f"
echo "   • Restart:       systemctl restart panelx"
echo "   • Stop:          systemctl stop panelx"
echo "   • Test API:      curl http://localhost:$PORT/api/stats"
echo ""
echo -e "${YELLOW}⚠️  Important:${NC}"
echo "   • Change admin password after first login!"
echo "   • Clear browser cache: Ctrl+Shift+R"
echo ""
echo -e "${GREEN}🎉 Enjoy your PanelX panel!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
