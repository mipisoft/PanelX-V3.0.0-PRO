# 🚀 Quick Update Reference - PanelX

## 📋 Option 1: Automatic Update (EASIEST)

```bash
# On your server, run:
cd /opt/panelx
wget https://raw.githubusercontent.com/mipisoft/PanelX-V3.0.0-PRO/main/update-server.sh
chmod +x update-server.sh
sudo ./update-server.sh
```

**That's it!** The script will:
- ✅ Stop service
- ✅ Pull latest changes
- ✅ Install dependencies
- ✅ Restart service
- ✅ Verify it's working

---

## 📋 Option 2: Manual Update (5 minutes)

```bash
# 1. SSH to server
ssh user@your-server-ip

# 2. Navigate to project
cd /opt/panelx

# 3. Stop service
sudo systemctl stop panelx
# OR: pm2 stop panelx
# OR: fuser -k 5000/tcp

# 4. Pull changes
git pull origin main

# 5. Install packages (if needed)
npm install

# 6. Start service
sudo systemctl start panelx
# OR: pm2 restart panelx

# 7. Verify
curl http://localhost:5000/api/stats

# 8. Clear browser cache
# Press: Ctrl+Shift+R
```

---

## 🎯 What's New (Test These)

### 1. Stream Control Buttons ✨ NEW
**Location**: Streams page  
**What**: Hover over any stream  
**See**: 5 buttons (Play, **Start**, **Stop**, **Restart**, Edit, Delete)  
**Test**: Click Start/Stop/Restart  
**Expected**: Success message, stream status changes

### 2. Export Buttons ✨ NEW

**Lines Page** (3 buttons):
- 📄 CSV → `lines_export_[timestamp].csv`
- 📊 Excel → `lines_export_[timestamp].xlsx`
- 📺 M3U → `lines_playlist_[timestamp].m3u`

**Streams Page** (2 buttons):
- 📄 CSV → `streams_export_[timestamp].csv`
- 📊 Excel → `streams_export_[timestamp].xlsx`

**Test**: Click each button → File downloads automatically

---

## 🔧 Quick Troubleshooting

### Service won't start
```bash
# Check logs
sudo journalctl -u panelx -n 50
# OR: pm2 logs panelx
# OR: tail -50 /opt/panelx/server.log

# Check port
lsof -i :5000

# Kill port if stuck
fuser -k 5000/tcp

# Restart
sudo systemctl restart panelx
```

### Git pull fails
```bash
cd /opt/panelx
git config credential.helper store
git pull origin main
# Enter GitHub username + token
```

### Old UI showing
```bash
# Clear browser cache!
# Press: Ctrl+Shift+R (hard refresh)
# OR: Ctrl+Shift+Delete (clear cache)
# OR: Try incognito window
```

### Database connection error
```bash
# Check PostgreSQL
sudo systemctl status postgresql
sudo systemctl restart postgresql

# Test connection
psql -h localhost -U panelx -d panelx -c "SELECT 1;"

# Check .env file
cat /opt/panelx/.env
```

---

## 📊 Verification Checklist

After update, verify:

- [ ] Server responding: `curl http://localhost:5000/api/stats`
- [ ] Dashboard loads
- [ ] Streams page loads
- [ ] Lines page loads
- [ ] Stream control buttons appear on hover
- [ ] Export buttons visible (Lines: 3, Streams: 2)
- [ ] Click Start → Success message
- [ ] Click Export CSV → File downloads
- [ ] File contains correct data

---

## 🎯 Access Panel

**URL**: `http://your-server-ip:5000`  
**Admin**: `admin` / `admin123`  
**Reseller**: `reseller1` / `reseller123`

---

## 📞 Useful Commands

```bash
# One-line update
cd /opt/panelx && git pull origin main && npm install && sudo systemctl restart panelx

# Check status
sudo systemctl status panelx
curl http://localhost:5000/api/stats

# View logs
sudo journalctl -u panelx -f

# Restart
sudo systemctl restart panelx

# Check port
lsof -i :5000

# Kill port
fuser -k 5000/tcp
```

---

## 📖 Full Documentation

**Repository**: https://github.com/mipisoft/PanelX-V3.0.0-PRO

**Guides**:
- `SERVER_UPDATE_GUIDE.md` - Complete update guide
- `DEPLOYMENT_GUIDE.md` - Full deployment
- `ENTERPRISE_PROGRESS.md` - Current status
- `MISSING_FEATURES_ANALYSIS.md` - All features

---

## 🚨 Need Help?

If issues occur, send me:

1. **Error messages** from logs
2. **Screenshots** of errors
3. **Output** of: `sudo systemctl status panelx`
4. **Output** of: `curl http://localhost:5000/api/stats`

---

## ✅ Latest Changes

**Commit**: `707cfa7` (2026-01-24)

**Phase 1.1** - Stream Control:
- ✨ Start/Stop/Restart buttons
- ✨ Real-time status tracking
- ✨ Viewer count tracking

**Phase 1.2** - Export:
- ✨ Lines: CSV/Excel/M3U export
- ✨ Streams: CSV/Excel export
- ✨ Users: CSV export (admin)

**Total**: 11 new endpoints, 5 new features

---

**Status**: ✅ Ready to update  
**Time**: ~5 minutes  
**Difficulty**: Easy  

**Remember**: Always clear browser cache after update! (Ctrl+Shift+R)
