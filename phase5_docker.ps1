# ============================================================
#  MLBB TopUp Nepal - Phase 5: Docker + nginx
#  Run from: D:\MLBB>  .\phase5_docker.ps1
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  MLBB TopUp Nepal - Phase 5: Docker + nginx" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/7] Creating nginx folder..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "nginx" | Out-Null
Write-Host "      Done." -ForegroundColor Green

# ============================================================
Write-Host "[2/7] Writing nginx/nginx.conf..." -ForegroundColor Yellow
# ============================================================

$nginxConf = @"
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile      on;
    gzip          on;
    gzip_types    text/plain text/css application/json application/javascript text/xml application/xml;

    upstream api {
        server api:4000;
    }

    server {
        listen 80;
        server_name _;

        # ── Serve frontend (mlbb-topup.html as index) ──────
        location / {
            root   /usr/share/nginx/html;
            index  mlbb-topup.html index.html;
            try_files `$uri `$uri/ /mlbb-topup.html;
        }

        # ── Serve admin panel ──────────────────────────────
        location /admin {
            alias  /usr/share/nginx/html/admin;
            index  index.html;
            try_files `$uri `$uri/ /admin/index.html;
        }

        # ── Proxy all /api/* to Node backend ──────────────
        location /api/ {
            proxy_pass         http://api/api/;
            proxy_http_version 1.1;
            proxy_set_header   Upgrade `$http_upgrade;
            proxy_set_header   Connection 'upgrade';
            proxy_set_header   Host `$host;
            proxy_set_header   X-Real-IP `$remote_addr;
            proxy_set_header   X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_cache_bypass `$http_upgrade;
        }

        # ── Serve uploaded receipts ────────────────────────
        location /uploads/ {
            proxy_pass http://api/uploads/;
        }

        # ── Health check ──────────────────────────────────
        location /health {
            return 200 'OK';
            add_header Content-Type text/plain;
        }
    }
}
"@

[System.IO.File]::WriteAllText(
    (Join-Path (Get-Location).Path "nginx\nginx.conf"),
    $nginxConf,
    [System.Text.Encoding]::UTF8
)
Write-Host "      nginx/nginx.conf written." -ForegroundColor Green

# ============================================================
Write-Host "[3/7] Writing backend/Dockerfile..." -ForegroundColor Yellow
# ============================================================

$backendDockerfile = @"
FROM node:20-alpine

WORKDIR /app

# Install dependencies first (layer cache)
COPY package*.json ./
RUN npm install --production

# Copy source
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Create uploads directory
RUN mkdir -p uploads

EXPOSE 4000

# Start with db push then server
CMD ["sh", "-c", "npx prisma db push --accept-data-loss && node seed.js || true && node server.js"]
"@

[System.IO.File]::WriteAllText(
    (Join-Path (Get-Location).Path "backend\Dockerfile"),
    $backendDockerfile,
    [System.Text.Encoding]::UTF8
)
Write-Host "      backend/Dockerfile written." -ForegroundColor Green

# ============================================================
Write-Host "[4/7] Writing backend/.dockerignore..." -ForegroundColor Yellow
# ============================================================

$dockerignore = @"
node_modules
.env
uploads
*.log
"@

[System.IO.File]::WriteAllText(
    (Join-Path (Get-Location).Path "backend\.dockerignore"),
    $dockerignore,
    [System.Text.Encoding]::UTF8
)
Write-Host "      backend/.dockerignore written." -ForegroundColor Green

# ============================================================
Write-Host "[5/7] Writing docker-compose.yml..." -ForegroundColor Yellow
# ============================================================

$dockerCompose = @"
version: '3.9'

services:

  # ── PostgreSQL Database ───────────────────────────────────
  db:
    image: postgres:16-alpine
    container_name: mlbb_db
    restart: always
    environment:
      POSTGRES_USER: mlbbuser
      POSTGRES_PASSWORD: mlbbpassword
      POSTGRES_DB: mlbb_topup
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - mlbb_net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U mlbbuser -d mlbb_topup"]
      interval: 10s
      timeout: 5s
      retries: 5

  # ── Node.js API ───────────────────────────────────────────
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: mlbb_api
    restart: always
    environment:
      DATABASE_URL: postgresql://mlbbuser:mlbbpassword@db:5432/mlbb_topup
      JWT_SECRET: change_this_to_a_long_secret_before_deploy_xyz789
      PORT: 4000
      ADMIN_EMAIL: admin@mlbbtopup.com
      ADMIN_PASSWORD: Admin@1234
    volumes:
      - uploads_data:/app/uploads
    networks:
      - mlbb_net
    depends_on:
      db:
        condition: service_healthy

  # ── nginx (serves frontend + proxies API) ─────────────────
  nginx:
    image: nginx:alpine
    container_name: mlbb_nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./mlbb-topup.html:/usr/share/nginx/html/mlbb-topup.html:ro
      - ./admin:/usr/share/nginx/html/admin:ro
      - ssl_certs:/etc/letsencrypt:ro
    networks:
      - mlbb_net
    depends_on:
      - api

networks:
  mlbb_net:
    driver: bridge

volumes:
  db_data:
  uploads_data:
  ssl_certs:
"@

[System.IO.File]::WriteAllText(
    (Join-Path (Get-Location).Path "docker-compose.yml"),
    $dockerCompose,
    [System.Text.Encoding]::UTF8
)
Write-Host "      docker-compose.yml written." -ForegroundColor Green

# ============================================================
Write-Host "[6/7] Writing .dockerignore (root)..." -ForegroundColor Yellow
# ============================================================

$rootDockerignore = @"
backend/node_modules
backend/.env
backend/uploads
.git
*.ps1
*.log
"@

[System.IO.File]::WriteAllText(
    (Join-Path (Get-Location).Path ".dockerignore"),
    $rootDockerignore,
    [System.Text.Encoding]::UTF8
)
Write-Host "      .dockerignore written." -ForegroundColor Green

# ============================================================
Write-Host "[7/7] Writing deploy.sh (for VPS use later)..." -ForegroundColor Yellow
# ============================================================

$deployScript = @"
#!/bin/bash
# ============================================================
#  MLBB TopUp Nepal - VPS Deploy Script
#  Run this on your VPS after uploading files
#  Usage: chmod +x deploy.sh && ./deploy.sh yourdomain.com
# ============================================================

DOMAIN=`${1:-yourdomain.com}

echo ""
echo "============================================"
echo "  MLBB TopUp Nepal - VPS Deploy"
echo "  Domain: `$DOMAIN"
echo "============================================"
echo ""

# ── Install Docker if not present ────────────────────────
if ! command -v docker &> /dev/null; then
    echo "[1/5] Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker `$USER
    echo "      Docker installed."
else
    echo "[1/5] Docker already installed."
fi

# ── Install Docker Compose if not present ────────────────
if ! command -v docker compose &> /dev/null; then
    echo "[2/5] Installing Docker Compose plugin..."
    sudo apt-get update -qq
    sudo apt-get install -y docker-compose-plugin
else
    echo "[2/5] Docker Compose already installed."
fi

# ── Install Certbot for SSL ──────────────────────────────
echo "[3/5] Installing Certbot..."
sudo apt-get install -y certbot

# ── Update nginx.conf with real domain ──────────────────
echo "[4/5] Updating nginx config with domain: `$DOMAIN"
sed -i "s/server_name _;/server_name `$DOMAIN www.`$DOMAIN;/" nginx/nginx.conf

# ── Start containers ─────────────────────────────────────
echo "[5/5] Starting Docker containers..."
docker compose down --remove-orphans 2>/dev/null || true
docker compose up -d --build

echo ""
echo "============================================"
echo "  Containers are up!"
echo "============================================"
echo ""
echo "  Site running at: http://`$DOMAIN"
echo "  Admin panel:     http://`$DOMAIN/admin"
echo "  API health:      http://`$DOMAIN/api/health"
echo ""
echo "  TO ADD HTTPS (run after DNS is pointed):"
echo "  sudo certbot certonly --standalone -d `$DOMAIN -d www.`$DOMAIN"
echo "  Then run: docker compose restart nginx"
echo ""
echo "  USEFUL COMMANDS:"
echo "  View logs:      docker compose logs -f"
echo "  Restart all:    docker compose restart"
echo "  Stop all:       docker compose down"
echo "  Rebuild API:    docker compose up -d --build api"
echo ""
"@

[System.IO.File]::WriteAllText(
    (Join-Path (Get-Location).Path "deploy.sh"),
    $deployScript,
    [System.Text.Encoding]::UTF8
)
Write-Host "      deploy.sh written." -ForegroundColor Green

# ============================================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Phase 5 Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Files created:" -ForegroundColor White
Write-Host "  D:\MLBB\" -ForegroundColor Gray
Write-Host "  |-- docker-compose.yml        (orchestrates everything)" -ForegroundColor Gray
Write-Host "  |-- .dockerignore" -ForegroundColor Gray
Write-Host "  |-- deploy.sh                 (run this on VPS)" -ForegroundColor Gray
Write-Host "  |-- nginx\" -ForegroundColor Gray
Write-Host "  |   +-- nginx.conf            (serves frontend + proxies API)" -ForegroundColor Gray
Write-Host "  +-- backend\" -ForegroundColor Gray
Write-Host "      |-- Dockerfile" -ForegroundColor Gray
Write-Host "      +-- .dockerignore" -ForegroundColor Gray
Write-Host ""
Write-Host "  TEST LOCALLY (needs Docker Desktop installed):" -ForegroundColor Cyan
Write-Host ""
Write-Host "  cd D:\MLBB" -ForegroundColor DarkGray
Write-Host "  docker compose up --build" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Then open:" -ForegroundColor White
Write-Host "  Frontend:  http://localhost" -ForegroundColor DarkGray
Write-Host "  Admin:     http://localhost/admin" -ForegroundColor DarkGray
Write-Host "  API:       http://localhost/api/health" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  NOTE: When running via Docker, the API URL" -ForegroundColor Yellow
Write-Host "  changes from localhost:4000 to just /api" -ForegroundColor Yellow
Write-Host "  Run phase5b_fix_api_urls.ps1 next to fix this!" -ForegroundColor Yellow
Write-Host ""
