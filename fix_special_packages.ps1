# ============================================================
#  MLBB - Fix Special Packages (Docker DB + Frontend)
#  Run from: D:\MLBB>  .\fix_special_packages.ps1
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Fix: Special Packages for Docker + UI" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ── PART 1: Seed into Docker DB via docker exec ─────────────
Write-Host "[1/2] Seeding special packages into Docker DB..." -ForegroundColor Yellow

$seedCmd = @'
require('/app/node_modules/@prisma/client');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const specials = [
  { name: 'Weekly Pass 1x',  diamonds: 0, bonus: 0, price: 272.31 },
  { name: 'Weekly Pass 2x',  diamonds: 0, bonus: 0, price: 600.00 },
  { name: 'Weekly Pass 3x',  diamonds: 0, bonus: 0, price: 900.48 },
  { name: 'Weekly Pass 4x',  diamonds: 0, bonus: 0, price: 1200.00 },
  { name: 'Twilight Pass',   diamonds: 0, bonus: 0, price: 1588.80 },
];
async function main() {
  for (const pkg of specials) {
    const existing = await prisma.package.findFirst({ where: { name: pkg.name } });
    if (existing) {
      await prisma.package.update({ where: { id: existing.id }, data: pkg });
      console.log('Updated:', pkg.name);
    } else {
      await prisma.package.create({ data: pkg });
      console.log('Created:', pkg.name);
    }
  }
  console.log('Done!');
  await prisma.$disconnect();
}
main().catch(async (e) => { console.error(e); await prisma.$disconnect(); process.exit(1); });
'@

# Write seed file locally first
$seedFile = Join-Path (Get-Location).Path "backend\_docker_seed_temp.js"
[System.IO.File]::WriteAllText($seedFile, $seedCmd, (New-Object System.Text.UTF8Encoding $false))

# Copy into running Docker container and execute
docker cp "backend\_docker_seed_temp.js" mlbb_api:/app/_docker_seed_temp.js
docker exec mlbb_api node /app/_docker_seed_temp.js

# Cleanup
Remove-Item $seedFile -Force 2>$null
docker exec mlbb_api rm /app/_docker_seed_temp.js 2>$null

Write-Host "      Docker DB seeded." -ForegroundColor Green

# ── PART 2: Rebuild frontend HTML with special sections ──────
Write-Host "[2/2] Rebuilding mlbb-topup.html with special sections..." -ForegroundColor Yellow

$filePath = Join-Path (Get-Location).Path "mlbb-topup.html"

# Read current file
$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

# Check if already injected
if ($content -match "weeklySection") {
    Write-Host "      Special sections already in HTML - skipping injection." -ForegroundColor DarkGray
} else {
    # ── Inject CSS ──────────────────────────────────────────
    $newCSS = "
/* SPECIAL OFFER SECTIONS */
.special-section{margin-top:32px;}
.special-section-label{display:flex;align-items:center;gap:10px;margin-bottom:16px;}
.special-section-label .fire{font-size:20px;}
.special-section-label h3{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1.1rem;letter-spacing:1px;color:#fff;text-transform:uppercase;}
.weekly-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px;}
.special-card{background:var(--bg-card);border:1.5px solid rgba(255,215,0,0.1);border-radius:14px;padding:14px;cursor:pointer;transition:all 0.25s;position:relative;overflow:hidden;}
.special-card::after{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,215,0,0.06),transparent);opacity:0;transition:opacity 0.25s;}
.special-card:hover{border-color:rgba(255,215,0,0.5);transform:translateY(-3px);box-shadow:0 8px 30px rgba(255,215,0,0.15);}
.special-card:hover::after,.special-card.selected::after{opacity:1;}
.special-card.selected{border-color:var(--gold);box-shadow:0 0 0 2px rgba(255,215,0,0.3),0 8px 30px rgba(255,215,0,0.2);background:rgba(255,215,0,0.06);}
.special-card .sel-check{position:absolute;top:10px;right:10px;width:22px;height:22px;border-radius:50%;background:var(--gold);display:none;align-items:center;justify-content:center;font-size:11px;color:#000;font-weight:900;z-index:2;}
.special-card.selected .sel-check{display:flex;}
.special-img-wrap{position:relative;margin-bottom:10px;}
.special-img-wrap img{width:100%;height:80px;object-fit:cover;border-radius:8px;display:block;}
.special-badge{position:absolute;top:6px;left:6px;background:linear-gradient(135deg,#FF2D55,#FF6B00);border-radius:5px;padding:2px 8px;font-size:0.65rem;font-weight:700;color:#fff;font-family:'Rajdhani',sans-serif;letter-spacing:1px;text-transform:uppercase;}
.special-name{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:0.95rem;color:#fff;margin-bottom:8px;line-height:1.3;}
.special-label-from{font-size:0.68rem;color:var(--text-muted);font-family:'Rajdhani',sans-serif;letter-spacing:1px;text-transform:uppercase;margin-bottom:2px;}
.special-pricing{display:flex;align-items:center;justify-content:space-between;}
.special-price{font-family:'Orbitron',sans-serif;font-size:0.95rem;font-weight:700;color:var(--gold);}
.special-discount{background:rgba(255,45,85,0.15);border:1px solid rgba(255,45,85,0.3);border-radius:5px;padding:1px 6px;font-size:0.7rem;font-weight:700;color:var(--red);font-family:'Rajdhani',sans-serif;}
.twilight-card{background:var(--bg-card);border:1.5px solid rgba(255,215,0,0.1);border-radius:14px;padding:16px;cursor:pointer;transition:all 0.25s;position:relative;overflow:hidden;display:flex;align-items:center;gap:16px;max-width:420px;}
.twilight-card::after{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,215,0,0.06),transparent);opacity:0;transition:opacity 0.25s;}
.twilight-card:hover{border-color:rgba(255,215,0,0.5);transform:translateY(-3px);box-shadow:0 8px 30px rgba(255,215,0,0.15);}
.twilight-card:hover::after,.twilight-card.selected::after{opacity:1;}
.twilight-card.selected{border-color:var(--gold);box-shadow:0 0 0 2px rgba(255,215,0,0.3),0 8px 30px rgba(255,215,0,0.2);background:rgba(255,215,0,0.06);}
.twilight-card .sel-check{position:absolute;top:10px;right:10px;width:22px;height:22px;border-radius:50%;background:var(--gold);display:none;align-items:center;justify-content:center;font-size:11px;color:#000;font-weight:900;z-index:2;}
.twilight-card.selected .sel-check{display:flex;}
.twilight-img{width:72px;height:72px;border-radius:10px;object-fit:cover;flex-shrink:0;}
.twilight-info{flex:1;}
.twilight-name{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1rem;color:#fff;margin-bottom:6px;}
.twilight-from{font-size:0.68rem;color:var(--text-muted);font-family:'Rajdhani',sans-serif;letter-spacing:1px;text-transform:uppercase;margin-bottom:2px;}
.twilight-pricing{display:flex;align-items:center;gap:10px;}
.twilight-price{font-family:'Orbitron',sans-serif;font-size:1rem;font-weight:700;color:var(--gold);}
.twilight-discount{background:rgba(255,45,85,0.15);border:1px solid rgba(255,45,85,0.3);border-radius:5px;padding:1px 7px;font-size:0.72rem;font-weight:700;color:var(--red);font-family:'Rajdhani',sans-serif;}
"
    $content = $content.Replace("</style>", $newCSS + "</style>")

    # ── Inject HTML after diamondGrid ───────────────────────
    $newHTML = "
  <!-- WEEKLY DIAMOND PASS -->
  <div id=""weeklySection"" style=""display:none;"">
    <div class=""special-section"">
      <div class=""special-section-label""><span class=""fire"">&#x1F525;</span><h3>Weekly Diamond Pass</h3></div>
      <div class=""weekly-grid"" id=""weeklyGrid""></div>
    </div>
  </div>

  <!-- TWILIGHT PASS -->
  <div id=""twilightSection"" style=""display:none;"">
    <div class=""special-section"">
      <div class=""special-section-label""><span class=""fire"">&#x2728;</span><h3>Twilight Pass</h3></div>
      <div id=""twilightGrid""></div>
    </div>
  </div>
"
    # Find the diamondGrid div end and insert after it
    # We look for the closing of diamondGrid's loading text div
    $marker = '<div class="loading-grid">Loading packages...</div>'
    $markerClose = $marker + "
  </div>"
    $insertAfter = $marker + "
  </div>" + $newHTML

    if ($content -match [regex]::Escape('<div class="loading-grid">Loading packages...</div>')) {
        $content = $content.Replace(
            '<div class="loading-grid">Loading packages...</div>
  </div>',
            '<div class="loading-grid">Loading packages...</div>
  </div>' + $newHTML
        )
        Write-Host "      HTML sections injected after diamond grid." -ForegroundColor Green
    } else {
        Write-Host "      WARNING: Could not find injection point. Inserting before Step 3..." -ForegroundColor Yellow
        $content = $content.Replace(
            '<!-- STEP 3 -->',
            $newHTML + '<!-- STEP 3 -->'
        )
    }

    # ── Inject JS - add special package logic ───────────────
    $newJSVars = "
var WEEKLY_IMG   = 'https://i.imgur.com/wpjoOwV.jpeg';
var TWILIGHT_IMG = 'https://i.imgur.com/Lhj3x20.jpeg';

function getPackageType(name) {
  var n = name.toLowerCase();
  if (n.indexOf('weekly pass') > -1) return 'weekly';
  if (n.indexOf('twilight pass') > -1) return 'twilight';
  return 'diamond';
}
function weeklyLabel(name) {
  var m = name.match(/(\d+)x/i);
  return m ? m[1] + 'x Weekly Diamond Pass' : 'Weekly Diamond Pass';
}
function selectAnyPkg(p) {
  document.querySelectorAll('.diamond-card,.special-card,.twilight-card').forEach(function(c){ c.classList.remove('selected'); });
  selectedPackage = p;
  var el = document.getElementById('pkgcard-' + p.id);
  if (el) el.classList.add('selected');
  document.getElementById('selectedPackage').textContent = p.name;
  document.getElementById('selectedPrice').textContent   = 'Rs' + p.price;
}
"

    # Insert new JS vars right before the existing loadPackages function
    $content = $content.Replace("function loadPackages() {", $newJSVars + "function loadPackages() {")

    # Now patch the inside of loadPackages to handle special packages
    # Find the fetch success handler and replace the simple forEach with the categorized version
    $oldRender = "    grid.innerHTML = '';
    pkgs.forEach(function(p) {
      var card = document.createElement('div');
      card.className = 'diamond-card';
      card.id = 'dc-' + p.id;
      card.innerHTML =
        '<div class=""selected-check"">&#x2713;</div>' +
        '<div class=""card-top"">' + getDiamondSVG() +
        '<div><div class=""diamond-name"">' + p.name + '</div>' +
        '<div class=""diamond-bonus"">+' + p.bonus + ' Bonus</div></div></div>' +
        '<div class=""card-bottom""><div class=""price-new"">Rs' + p.price + '</div>' +
        '<div class=""discount-tag"">BEST</div></div>';
      card.addEventListener('click', function(){ selectPackage(p); });
      grid.appendChild(card);
    });"

    $newRender = "    grid.innerHTML = '';
    var diamonds  = pkgs.filter(function(p){ return getPackageType(p.name)==='diamond'; });
    var weeklies  = pkgs.filter(function(p){ return getPackageType(p.name)==='weekly'; });
    var twilights = pkgs.filter(function(p){ return getPackageType(p.name)==='twilight'; });

    diamonds.forEach(function(p) {
      var card = document.createElement('div');
      card.className = 'diamond-card';
      card.id = 'pkgcard-' + p.id;
      card.innerHTML =
        '<div class=""selected-check"">&#x2713;</div>' +
        '<div class=""card-top"">' + getDiamondSVG() +
        '<div><div class=""diamond-name"">' + p.name + '</div>' +
        '<div class=""diamond-bonus"">+' + p.bonus + ' Bonus</div></div></div>' +
        '<div class=""card-bottom""><div class=""price-new"">Rs' + p.price + '</div>' +
        '<div class=""discount-tag"">BEST</div></div>';
      card.addEventListener('click', function(){ selectAnyPkg(p); });
      grid.appendChild(card);
    });

    if (weeklies.length) {
      document.getElementById('weeklySection').style.display = 'block';
      var wgrid = document.getElementById('weeklyGrid');
      wgrid.innerHTML = '';
      weeklies.sort(function(a,b){ var am=a.name.match(/(\d+)x/i),bm=b.name.match(/(\d+)x/i); return (am?parseInt(am[1]):0)-(bm?parseInt(bm[1]):0); });
      weeklies.forEach(function(p) {
        var card = document.createElement('div');
        card.className = 'special-card';
        card.id = 'pkgcard-' + p.id;
        card.innerHTML =
          '<div class=""sel-check"">&#x2713;</div>' +
          '<div class=""special-img-wrap""><img src=""' + WEEKLY_IMG + '"" alt=""Weekly Pass"" /><span class=""special-badge"">Special</span></div>' +
          '<div class=""special-name"">' + weeklyLabel(p.name) + '</div>' +
          '<div class=""special-label-from"">From</div>' +
          '<div class=""special-pricing""><div class=""special-price"">Rs' + p.price + '</div><div class=""special-discount"">-4%</div></div>';
        card.addEventListener('click', function(){ selectAnyPkg(p); });
        wgrid.appendChild(card);
      });
    }

    if (twilights.length) {
      document.getElementById('twilightSection').style.display = 'block';
      var tgrid = document.getElementById('twilightGrid');
      tgrid.innerHTML = '';
      twilights.forEach(function(p) {
        var card = document.createElement('div');
        card.className = 'twilight-card';
        card.id = 'pkgcard-' + p.id;
        card.innerHTML =
          '<div class=""sel-check"">&#x2713;</div>' +
          '<img class=""twilight-img"" src=""' + TWILIGHT_IMG + '"" alt=""Twilight Pass"" />' +
          '<div class=""twilight-info""><div class=""twilight-name"">Twilight Pass</div><div class=""twilight-from"">From</div>' +
          '<div class=""twilight-pricing""><div class=""twilight-price"">Rs' + p.price + '</div><div class=""twilight-discount"">-4%</div></div></div>';
        card.addEventListener('click', function(){ selectAnyPkg(p); });
        tgrid.appendChild(card);
      });
    }"

    if ($content -match "card\.addEventListener\('click', function\(\)\{ selectPackage\(p\); \}\);") {
        $content = $content.Replace(
            "    grid.innerHTML = '';
    pkgs.forEach(function(p) {
      var card = document.createElement('div');
      card.className = 'diamond-card';
      card.id = 'dc-' + p.id;
      card.innerHTML =
        '<div class=""selected-check"">&#x2713;</div>' +
        '<div class=""card-top"">' + getDiamondSVG() +
        '<div><div class=""diamond-name"">' + p.name + '</div>' +
        '<div class=""diamond-bonus"">+' + p.bonus + ' Bonus</div></div></div>' +
        '<div class=""card-bottom""><div class=""price-new"">Rs' + p.price + '</div>' +
        '<div class=""discount-tag"">BEST</div></div>';
      card.addEventListener('click', function(){ selectPackage(p); });
      grid.appendChild(card);
    });",
            $newRender
        )
        Write-Host "      JS render patched." -ForegroundColor Green
    } else {
        Write-Host "      JS already patched or pattern not found - check manually." -ForegroundColor Yellow
    }

    # Also patch reset in placeOrder to clear special cards
    $content = $content.Replace(
        "document.querySelectorAll('.diamond-card').forEach(function(c){ c.classList.remove('selected'); });",
        "document.querySelectorAll('.diamond-card,.special-card,.twilight-card').forEach(function(c){ c.classList.remove('selected'); });"
    )

    [System.IO.File]::WriteAllText($filePath, $content, (New-Object System.Text.UTF8Encoding $false))
    Write-Host "      mlbb-topup.html saved." -ForegroundColor Green
}

# ── PART 3: Rebuild Docker nginx to pick up new HTML ─────────
Write-Host ""
Write-Host "Restarting nginx container to serve updated HTML..." -ForegroundColor Yellow
docker compose restart nginx
Write-Host "      nginx restarted." -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  All Fixed!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Open http://localhost - scroll below diamonds" -ForegroundColor White
Write-Host "  Weekly Pass + Twilight Pass should now appear" -ForegroundColor Gray
Write-Host ""
Write-Host "  Admin panel > Packages - all 5 special" -ForegroundColor White
Write-Host "  packages should now be visible there too" -ForegroundColor Gray
Write-Host ""
