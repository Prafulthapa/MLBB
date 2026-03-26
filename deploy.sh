#!/bin/bash
# ============================================================
#  MLBB TopUp Nepal - VPS Deploy Script
#  Run this on your VPS after uploading files
#  Usage: chmod +x deploy.sh && ./deploy.sh yourdomain.com
# ============================================================

DOMAIN=${1:-yourdomain.com}

echo ""
echo "============================================"
echo "  MLBB TopUp Nepal - VPS Deploy"
echo "  Domain: $DOMAIN"
echo "============================================"
echo ""

# â”€â”€ Install Docker if not present â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if ! command -v docker &> /dev/null; then
    echo "[1/5] Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo "      Docker installed."
else
    echo "[1/5] Docker already installed."
fi

# â”€â”€ Install Docker Compose if not present â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if ! command -v docker compose &> /dev/null; then
    echo "[2/5] Installing Docker Compose plugin..."
    sudo apt-get update -qq
    sudo apt-get install -y docker-compose-plugin
else
    echo "[2/5] Docker Compose already installed."
fi

# â”€â”€ Install Certbot for SSL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo "[3/5] Installing Certbot..."
sudo apt-get install -y certbot

# â”€â”€ Update nginx.conf with real domain â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo "[4/5] Updating nginx config with domain: $DOMAIN"
sed -i "s/server_name _;/server_name $DOMAIN www.$DOMAIN;/" nginx/nginx.conf

# â”€â”€ Start containers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo "[5/5] Starting Docker containers..."
docker compose down --remove-orphans 2>/dev/null || true
docker compose up -d --build

echo ""
echo "============================================"
echo "  Containers are up!"
echo "============================================"
echo ""
echo "  Site running at: http://$DOMAIN"
echo "  Admin panel:     http://$DOMAIN/admin"
echo "  API health:      http://$DOMAIN/api/health"
echo ""
echo "  TO ADD HTTPS (run after DNS is pointed):"
echo "  sudo certbot certonly --standalone -d $DOMAIN -d www.$DOMAIN"
echo "  Then run: docker compose restart nginx"
echo ""
echo "  USEFUL COMMANDS:"
echo "  View logs:      docker compose logs -f"
echo "  Restart all:    docker compose restart"
echo "  Stop all:       docker compose down"
echo "  Rebuild API:    docker compose up -d --build api"
echo ""