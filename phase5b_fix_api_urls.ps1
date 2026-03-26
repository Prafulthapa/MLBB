# ============================================================
#  MLBB TopUp Nepal - Phase 5b: Fix API URLs for Production
#  Run from: D:\MLBB>  .\phase5b_fix_api_urls.ps1
#  This switches frontend + admin from localhost:4000 to /api
#  so they work correctly when served through nginx + Docker
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Phase 5b: Fix API URLs for Production" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ── FIX mlbb-topup.html ──────────────────────────────────────
Write-Host "[1/2] Fixing API URL in mlbb-topup.html..." -ForegroundColor Yellow

$frontendPath = Join-Path (Get-Location).Path "mlbb-topup.html"
$frontend = [System.IO.File]::ReadAllText($frontendPath, [System.Text.Encoding]::UTF8)

# Replace hardcoded localhost:4000/api with relative /api
$frontend = $frontend -replace "var API = 'http://localhost:4000/api'", "var API = window.location.hostname === 'localhost' && window.location.port === '' ? '/api' : (window.location.port === '4000' ? 'http://localhost:4000/api' : '/api')"

# Also fix the receipt link in admin that points to localhost:4000/uploads
$frontend = $frontend -replace "http://localhost:4000/uploads/", "/uploads/"

[System.IO.File]::WriteAllText($frontendPath, $frontend, [System.Text.Encoding]::UTF8)
Write-Host "      mlbb-topup.html updated." -ForegroundColor Green

# ── FIX admin/index.html ─────────────────────────────────────
Write-Host "[2/2] Fixing API URL in admin/index.html..." -ForegroundColor Yellow

$adminPath = Join-Path (Get-Location).Path "admin\index.html"
$admin = [System.IO.File]::ReadAllText($adminPath, [System.Text.Encoding]::UTF8)

$admin = $admin -replace "var API = 'http://localhost:4000/api'", "var API = window.location.hostname === 'localhost' && window.location.port === '' ? '/api' : (window.location.port === '4000' ? 'http://localhost:4000/api' : '/api')"
$admin = $admin -replace "http://localhost:4000/uploads/", "/uploads/"

[System.IO.File]::WriteAllText($adminPath, $admin, [System.Text.Encoding]::UTF8)
Write-Host "      admin/index.html updated." -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Phase 5b Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Both files now auto-detect environment:" -ForegroundColor White
Write-Host "  - Opened as file://    -> uses localhost:4000 (dev)" -ForegroundColor Gray
Write-Host "  - Served via nginx     -> uses /api  (Docker/VPS)" -ForegroundColor Gray
Write-Host ""
Write-Host "  YOUR FULL FOLDER STRUCTURE IS NOW:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  D:\MLBB\" -ForegroundColor White
Write-Host "  |-- mlbb-topup.html        (customer page)" -ForegroundColor Gray
Write-Host "  |-- docker-compose.yml     (run everything)" -ForegroundColor Gray
Write-Host "  |-- deploy.sh              (VPS deploy script)" -ForegroundColor Gray
Write-Host "  |-- .dockerignore" -ForegroundColor Gray
Write-Host "  |-- nginx\" -ForegroundColor Gray
Write-Host "  |   +-- nginx.conf" -ForegroundColor Gray
Write-Host "  |-- admin\" -ForegroundColor Gray
Write-Host "  |   +-- index.html         (admin panel)" -ForegroundColor Gray
Write-Host "  +-- backend\" -ForegroundColor Gray
Write-Host "      |-- server.js" -ForegroundColor Gray
Write-Host "      |-- seed.js" -ForegroundColor Gray
Write-Host "      |-- Dockerfile" -ForegroundColor Gray
Write-Host "      |-- .env               (local dev only)" -ForegroundColor Gray
Write-Host "      |-- prisma\" -ForegroundColor Gray
Write-Host "      |   +-- schema.prisma" -ForegroundColor Gray
Write-Host "      +-- routes\" -ForegroundColor Gray
Write-Host "          |-- auth.js" -ForegroundColor Gray
Write-Host "          |-- orders.js" -ForegroundColor Gray
Write-Host "          +-- packages.js" -ForegroundColor Gray
Write-Host ""
Write-Host "  TEST WITH DOCKER NOW:" -ForegroundColor Cyan
Write-Host "  (Make sure Docker Desktop is running)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  cd D:\MLBB" -ForegroundColor DarkGray
Write-Host "  docker compose up --build" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Wait ~30 seconds then open:" -ForegroundColor White
Write-Host "  http://localhost        (customer page)" -ForegroundColor DarkGray
Write-Host "  http://localhost/admin  (admin panel)" -ForegroundColor DarkGray
Write-Host "  http://localhost/api/health" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host "  READY FOR PHASE 6 = VPS + Domain + SSL" -ForegroundColor Cyan
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  For Phase 6 you will need:" -ForegroundColor White
Write-Host "  1. A VPS (DigitalOcean / Hetzner / Contabo)" -ForegroundColor Gray
Write-Host "     Recommended: Hetzner CX22 = ~3 USD/month" -ForegroundColor Gray
Write-Host "  2. A domain name (Namecheap / Cloudflare)" -ForegroundColor Gray
Write-Host "  3. Point domain A record to VPS IP" -ForegroundColor Gray
Write-Host "  Then upload your D:\MLBB folder to VPS and" -ForegroundColor Gray
Write-Host "  run:  ./deploy.sh yourdomain.com" -ForegroundColor Gray
Write-Host ""
