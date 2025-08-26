# 📊 Dashboard Upload - Simple Steps

Your dashboards are ready! Here's exactly what to do:

## 🚀 Quick Upload (2 minutes)

### Step 1: Get API Token
1. **Open Grafana**: http://localhost:3000
2. **Login**: Use `admin/admin` (default) or `admin/nestory123`
3. **Go to API Keys**: http://localhost:3000/admin/api-keys
4. **Create New Key**:
   - Name: `Dashboard Upload`
   - Role: `Admin`
   - Click `Add`
5. **Copy the token** (starts with `eyJrIjoiXXXX...`)

### Step 2: Upload Dashboards
Run this command with your token:

```bash
./upload-dashboard.sh 'paste-your-token-here'
```

**Example**:
```bash
./upload-dashboard.sh 'eyJrIjoiXXXXXXXXXXXXXXXX'
```

## ✅ What You'll Get

**Comprehensive Dashboard** (15 panels):
- Executive Overview: System health, build success, error rates
- Infrastructure: CPU, memory, disk usage
- CI/CD Performance: Build timelines, duration heatmaps  
- Application Performance: Response times, cache ratios

**Production Dashboard** (10 panels):
- Service Level Objectives
- Critical infrastructure metrics
- Key performance indicators

## 🔗 Direct Links (after upload)
- **All Dashboards**: http://localhost:3000/dashboards
- **Comprehensive**: http://localhost:3000/d/nry-comprehensive-dev
- **Production**: http://localhost:3000/d/nry-production-prod

---

**That's it!** Your professional monitoring dashboards will be live in Grafana.