# ============================================================
#  MLBB - Add Login / Register System
#  Run from: D:\MLBB>  .\add_auth_frontend.ps1
# ============================================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Adding Login / Register to Customer Page" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: This script requires _auth_patch.js" -ForegroundColor Yellow
Write-Host "Make sure both files are in D:\MLBB\" -ForegroundColor Yellow
Write-Host ""

$patchSrc = Join-Path (Get-Location).Path "_auth_patch.js"
$patchDst = Join-Path (Get-Location).Path "backend\_auth_patch.js"

if (-not (Test-Path $patchSrc)) {
    Write-Host "ERROR: _auth_patch.js not found in D:\MLBB\" -ForegroundColor Red
    Write-Host "Please download both files and place them in D:\MLBB\" -ForegroundColor Red
    exit 1
}

Copy-Item $patchSrc $patchDst -Force
Write-Host "[1/3] Copied patch file to backend folder." -ForegroundColor Green

Write-Host "[2/3] Running patch via Node..." -ForegroundColor Yellow
Push-Location "backend"
node _auth_patch.js
$result = $LASTEXITCODE
Pop-Location
Remove-Item $patchDst -Force 2>$null

if ($result -ne 0) {
    Write-Host "ERROR: Patch failed. Check output above." -ForegroundColor Red
    exit 1
}
Write-Host "      Patch applied." -ForegroundColor Green

Write-Host "[3/3] Restarting nginx..." -ForegroundColor Yellow
docker compose restart nginx
Write-Host "      Done." -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Login / Register Added!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Open http://localhost" -ForegroundColor White
Write-Host "  - Top navbar: Login + Register buttons" -ForegroundColor Gray
Write-Host "  - Register: first/last name, username, email," -ForegroundColor Gray
Write-Host "    Nepal +977 phone, password x2" -ForegroundColor Gray
Write-Host "  - Login: email + password + remember me" -ForegroundColor Gray
Write-Host "  - Click Place Order without login = shows gate" -ForegroundColor Gray
Write-Host "  - After login: purchase works immediately" -ForegroundColor Gray
Write-Host ""
