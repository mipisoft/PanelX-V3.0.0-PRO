# 🎉 VPS Deployment Ready!

## ✅ **Traditional IPTV Panel Deployment - Complete**

Your PanelX V3.0.0 PRO is now ready for deployment to a VPS server, just like traditional IPTV panels (XUI-ONE, Xtream Codes, etc.)

---

## 📦 **What Was Created**

### **1. Automated Installation Script** (`install-vps.sh`)
One-command installer that sets up everything:
- ✅ Node.js 20
- ✅ PostgreSQL 15
- ✅ PM2 process manager
- ✅ Nginx web server
- ✅ FFmpeg for streaming
- ✅ Database creation
- ✅ Application deployment
- ✅ Firewall configuration
- ✅ Auto-start on boot

### **2. PM2 Production Config** (`ecosystem.production.cjs`)
Professional process management:
- ✅ Cluster mode (uses all CPU cores)
- ✅ Auto-restart on crash
- ✅ Memory limit monitoring
- ✅ Log rotation
- ✅ Health checks

### **3. Nginx Configuration** (`nginx.conf`)
Production-ready reverse proxy:
- ✅ Load balancing
- ✅ WebSocket support
- ✅ Static file serving
- ✅ HLS streaming support
- ✅ SSL/TLS ready
- ✅ Security headers
- ✅ Gzip compression

### **4. Systemd Service** (`panelx.service`)
System integration:
- ✅ Auto-start on boot
- ✅ Automatic restart
- ✅ Resource limits
- ✅ Security sandboxing

### **5. Complete Documentation** (`VPS_DEPLOYMENT.md`)
Everything you need to know:
- ✅ Server requirements
- ✅ Installation steps
- ✅ Configuration guide
- ✅ SSL setup
- ✅ Management commands
- ✅ Troubleshooting

---

## 🚀 **How to Deploy**

### **Option 1: Automated Installation (Recommended)**

```bash
# 1. Get a VPS (Ubuntu 22.04)
#    Providers: Hetzner, DigitalOcean, Vultr, AWS EC2

# 2. SSH into your server
ssh root@your-server-ip

# 3. Run the installer
git clone https://github.com/mipisoft/PanelX-V3.0.0-PRO.git
cd PanelX-V3.0.0-PRO
chmod +x install-vps.sh
sudo ./install-vps.sh

# 4. Configure (edit database password)
nano /home/panelx/webapp/.env

# 5. Restart
sudo -u panelx pm2 restart all

# 6. Access your panel
# http://your-server-ip/admin
```

### **Option 2: Manual Installation**

Follow the detailed steps in `VPS_DEPLOYMENT.md`

---

## 🖥️ **Server Requirements**

### **Minimum:**
- **OS**: Ubuntu 20.04/22.04 or Debian 11/12
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 50GB SSD
- **Network**: 100 Mbps

### **Recommended:**
- **OS**: Ubuntu 22.04 LTS
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Storage**: 100GB+ SSD
- **Network**: 1 Gbps

---

## 🎯 **VPS Providers**

### **Recommended Providers:**

1. **Hetzner** (Best Value)
   - URL: https://www.hetzner.com/cloud
   - Price: ~€4.51/month (CX21: 2 vCPU, 4GB RAM)
   - Location: Germany, Finland, USA
   - Best for: European IPTV

2. **DigitalOcean**
   - URL: https://www.digitalocean.com/
   - Price: $12/month (Basic: 2 vCPU, 4GB RAM)
   - Location: Worldwide
   - Best for: Ease of use

3. **Vultr**
   - URL: https://www.vultr.com/
   - Price: $12/month (Regular Performance)
   - Location: Worldwide
   - Best for: Global reach

4. **AWS EC2** (Enterprise)
   - URL: https://aws.amazon.com/ec2/
   - Price: ~$15-30/month (t3.medium)
   - Location: Worldwide
   - Best for: Enterprise scale

5. **Linode**
   - URL: https://www.linode.com/
   - Price: $12/month (Dedicated 4GB)
   - Location: Worldwide
   - Best for: Reliability

---

## 📋 **After Installation**

### **Access Your Panel:**
```
Admin Dashboard: http://your-server-ip/admin
API Documentation: http://your-server-ip/
API Endpoints: http://your-server-ip/api/*
```

### **Management Commands:**
```bash
# Check status
pm2 status

# View logs
pm2 logs panelx-production

# Restart application
pm2 restart panelx-production

# Monitor in real-time
pm2 monit

# Check Nginx
sudo systemctl status nginx

# View Nginx logs
sudo tail -f /var/log/nginx/panelx_access.log
```

---

## 🔒 **Security Setup**

### **1. Change Database Password**
```bash
nano /home/panelx/webapp/.env
# Update: DATABASE_URL=postgresql://panelx:NEW_PASSWORD@localhost:5432/panelx
```

### **2. Update Session Secret**
```bash
# Generate new secret
openssl rand -hex 32

# Add to .env
SESSION_SECRET=your-new-secret
```

### **3. Setup SSL Certificate (HTTPS)**
```bash
# Install Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Get certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Enable secure cookies in .env
COOKIE_SECURE=true
```

### **4. Configure Firewall**
```bash
# Already done by installer, but verify:
sudo ufw status

# Should show:
# 22/tcp (SSH) - ALLOW
# 80/tcp (HTTP) - ALLOW
# 443/tcp (HTTPS) - ALLOW
```

---

## 📊 **Architecture**

```
Internet
    ↓
Nginx (Port 80/443)
    ↓
PM2 Cluster (Multiple Node.js instances)
    ↓
Express.js Server (Port 5000)
    ↓
PostgreSQL Database
    ↓
File Storage (Recordings, Media)
```

### **Components:**
- **Nginx**: Reverse proxy, load balancer, SSL termination
- **PM2**: Process manager, clustering, auto-restart
- **Node.js**: Application runtime (Express.js)
- **PostgreSQL**: Database for users, streams, settings
- **FFmpeg**: Video transcoding and streaming

---

## 🎨 **Dashboard Features**

Once deployed, your admin dashboard includes:
- ✅ Real-time statistics
- ✅ User management
- ✅ Stream management
- ✅ Bandwidth monitoring
- ✅ GeoIP analytics
- ✅ Multi-server support
- ✅ TMDB integration
- ✅ Subtitle management
- ✅ Invoice/payment tracking
- ✅ API key management
- ✅ Commission system
- ✅ DVR/Recording manager
- ✅ EPG (Electronic Program Guide)

---

## 📖 **Documentation Files**

- **VPS_DEPLOYMENT.md** - Complete deployment guide
- **install-vps.sh** - Automated installer script
- **ecosystem.production.cjs** - PM2 configuration
- **nginx.conf** - Nginx configuration
- **panelx.service** - Systemd service file

---

## 🆘 **Common Issues & Solutions**

### **Application won't start:**
```bash
# Check logs
pm2 logs panelx-production --lines 100

# Common fixes:
- Wrong database password in .env
- Port 5000 already in use
- Missing dependencies: npm install
```

### **502 Bad Gateway:**
```bash
# Check if app is running
pm2 status

# Restart everything
pm2 restart all
sudo systemctl restart nginx
```

### **Can't connect to database:**
```bash
# Test PostgreSQL
sudo -u postgres psql -d panelx -c "SELECT 1;"

# Check credentials in .env
cat /home/panelx/webapp/.env | grep DATABASE_URL
```

---

## 🎯 **Next Steps**

1. ✅ **Deploy to VPS** - Follow the installation steps above
2. ✅ **Configure domain** - Point your domain to server IP
3. ✅ **Setup SSL** - Get free certificate with Let's Encrypt
4. ✅ **Create admin user** - Set up your first admin account
5. ✅ **Add streams** - Configure your IPTV streams
6. ✅ **Test streaming** - Verify everything works
7. ✅ **Setup backups** - Configure automated backups

---

## 📞 **Support**

- **GitHub**: https://github.com/mipisoft/PanelX-V3.0.0-PRO
- **Issues**: https://github.com/mipisoft/PanelX-V3.0.0-PRO/issues
- **Documentation**: Check `/docs` folder in repository

---

## ✅ **Deployment Checklist**

Before going live:
- [ ] VPS server provisioned
- [ ] SSH access configured
- [ ] Installation script executed
- [ ] Database password changed
- [ ] SESSION_SECRET updated
- [ ] Domain name configured
- [ ] SSL certificate installed
- [ ] Firewall enabled
- [ ] Backup system configured
- [ ] Admin user created
- [ ] Test streaming works
- [ ] Monitoring setup

---

**🎉 Your PanelX V3.0.0 PRO is ready for traditional VPS deployment!**

Just like XUI-ONE, Xtream Codes, and other professional IPTV panels.

*Generated: 2026-01-25*  
*Status: ✅ VPS Deployment Ready*  
*Version: 3.0.0 PRO*
