# ============================================================
#  MLBB TopUp Nepal - Phase 5 Hotfix
#  Fixes: 1) nginx BOM error  2) Prisma libssl error
#  Run from: D:\MLBB>  .\phase5_hotfix.ps1
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Phase 5 Hotfix - Fixing nginx + Prisma" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ── FIX 1: nginx.conf (write WITHOUT BOM) ───────────────────
Write-Host "[1/3] Fixing nginx/nginx.conf (removing BOM)..." -ForegroundColor Yellow

$nginxConf = "events {`n    worker_connections 1024;`n}`n`nhttp {`n    include       /etc/nginx/mime.types;`n    default_type  application/octet-stream;`n    sendfile      on;`n    gzip          on;`n    gzip_types    text/plain text/css application/json application/javascript text/xml application/xml;`n`n    upstream api {`n        server api:4000;`n    }`n`n    server {`n        listen 80;`n        server_name _;`n`n        # Serve frontend`n        location / {`n            root   /usr/share/nginx/html;`n            index  mlbb-topup.html index.html;`n            try_files `$uri `$uri/ /mlbb-topup.html;`n        }`n`n        # Serve admin panel`n        location /admin/ {`n            alias  /usr/share/nginx/html/admin/;`n            index  index.html;`n            try_files `$uri `$uri/ /admin/index.html;`n        }`n`n        # Proxy API to Node backend`n        location /api/ {`n            proxy_pass         http://api/api/;`n            proxy_http_version 1.1;`n            proxy_set_header   Upgrade `$http_upgrade;`n            proxy_set_header   Connection 'upgrade';`n            proxy_set_header   Host `$host;`n            proxy_set_header   X-Real-IP `$remote_addr;`n            proxy_set_header   X-Forwarded-For `$proxy_add_x_forwarded_for;`n            proxy_cache_bypass `$http_upgrade;`n        }`n`n        # Serve uploaded receipts`n        location /uploads/ {`n            proxy_pass http://api/uploads/;`n        }`n`n        # Health check`n        location /health {`n            return 200 'OK';`n            add_header Content-Type text/plain;`n        }`n    }`n}`n"

# Write with NO BOM using StreamWriter
$stream = [System.IO.StreamWriter]::new(
    (Join-Path (Get-Location).Path "nginx\nginx.conf"),
    $false,
    (New-Object System.Text.UTF8Encoding $false)
)
$stream.Write($nginxConf)
$stream.Close()

Write-Host "      nginx.conf fixed (no BOM)." -ForegroundColor Green

# ── FIX 2: backend/Dockerfile (use Debian slim, not Alpine) ─
Write-Host "[2/3] Fixing backend/Dockerfile (Prisma libssl fix)..." -ForegroundColor Yellow

$dockerfile = "FROM node:20-bookworm-slim`n`n# Install OpenSSL for Prisma`nRUN apt-get update -qq && apt-get install -y openssl ca-certificates && rm -rf /var/lib/apt/lists/*`n`nWORKDIR /app`n`n# Install dependencies first (layer cache)`nCOPY package*.json ./`nRUN npm install --production`n`n# Copy source`nCOPY . .`n`n# Generate Prisma client`nRUN npx prisma generate`n`n# Create uploads directory`nRUN mkdir -p uploads`n`nEXPOSE 4000`n`n# Wait for DB, push schema, seed once, then start server`nCMD [""sh"", ""-c"", ""npx prisma db push --accept-data-loss && node seed.js || true && node server.js""]`n"

$stream2 = [System.IO.StreamWriter]::new(
    (Join-Path (Get-Location).Path "backend\Dockerfile"),
    $false,
    (New-Object System.Text.UTF8Encoding $false)
)
$stream2.Write($dockerfile)
$stream2.Close()

Write-Host "      backend/Dockerfile fixed (Debian slim + OpenSSL)." -ForegroundColor Green

# ── FIX 3: Rebuild and restart ──────────────────────────────
Write-Host "[3/3] Stopping old containers..." -ForegroundColor Yellow
docker compose down 2>&1 | Out-Null
Write-Host "      Stopped." -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Hotfix Applied!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Now rebuild and start:" -ForegroundColor White
Write-Host ""
Write-Host "  docker compose up --build" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Wait ~40 seconds then open:" -ForegroundColor White
Write-Host "  http://localhost           (customer page)" -ForegroundColor DarkGray
Write-Host "  http://localhost/admin/    (admin panel)" -ForegroundColor DarkGray
Write-Host "  http://localhost/api/health" -ForegroundColor DarkGray
Write-Host ""
