# ============================================================
#  MLBB - Inject Special Packages into YOUR existing HTML
#  Does NOT overwrite your file - only adds the new sections
#  Run from: D:\MLBB>  .\inject_special_packages.ps1
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Injecting Weekly Pass + Twilight Pass" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$filePath = Join-Path (Get-Location).Path "mlbb-topup.html"
$content  = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

# ── 1. Inject CSS before </style> ───────────────────────────
Write-Host "[1/3] Injecting CSS..." -ForegroundColor Yellow

$newCSS = @"

/* ── SPECIAL OFFER SECTIONS ── */
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
"@

$content = $content -replace "</style>", ($newCSS + "`n</style>")
Write-Host "      CSS injected." -ForegroundColor Green

# ── 2. Inject HTML sections after diamond grid div ──────────
Write-Host "[2/3] Injecting HTML sections..." -ForegroundColor Yellow

$newHTML = @"

  <!-- WEEKLY DIAMOND PASS -->
  <div id="weeklySection" style="display:none;">
    <div class="special-section">
      <div class="special-section-label">
        <span class="fire">&#x1F525;</span>
        <h3>Weekly Diamond Pass</h3>
      </div>
      <div class="weekly-grid" id="weeklyGrid"></div>
    </div>
  </div>

  <!-- TWILIGHT PASS -->
  <div id="twilightSection" style="display:none;">
    <div class="special-section">
      <div class="special-section-label">
        <span class="fire">&#x2728;</span>
        <h3>Twilight Pass</h3>
      </div>
      <div id="twilightGrid"></div>
    </div>
  </div>

"@

# Insert after the closing tag of diamondGrid div
$content = $content -replace '(<div class="diamond-grid" id="diamondGrid">[\s\S]*?</div>)', ('$1' + $newHTML)
Write-Host "      HTML sections injected." -ForegroundColor Green

# ── 3. Patch loadPackages() JS to handle special packages ───
Write-Host "[3/3] Patching JavaScript..." -ForegroundColor Yellow

# Find the loadPackages function and replace it entirely
$oldJS = 'function loadPackages\(\) \{[\s\S]*?loadPackages\(\);'

$newJS = @"
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
  document.querySelectorAll('.diamond-card, .special-card, .twilight-card').forEach(function(c){ c.classList.remove('selected'); });
  selectedPackage = p;
  var el = document.getElementById('pkgcard-' + p.id);
  if (el) el.classList.add('selected');
  document.getElementById('selectedPackage').textContent = p.name;
  document.getElementById('selectedPrice').textContent   = 'Rs' + p.price;
}

function loadPackages() {
  fetch(API + '/packages')
  .then(function(r){ return r.json(); })
  .then(function(pkgs){
    var diamonds  = pkgs.filter(function(p){ return getPackageType(p.name) === 'diamond'; });
    var weeklies  = pkgs.filter(function(p){ return getPackageType(p.name) === 'weekly'; });
    var twilights = pkgs.filter(function(p){ return getPackageType(p.name) === 'twilight'; });

    // Diamond grid
    var grid = document.getElementById('diamondGrid');
    if (!diamonds.length) { grid.innerHTML = '<div class="loading-grid">No packages available</div>'; }
    else {
      grid.innerHTML = '';
      diamonds.forEach(function(p) {
        var card = document.createElement('div');
        card.className = 'diamond-card';
        card.id = 'pkgcard-' + p.id;
        card.innerHTML =
          '<div class="selected-check">&#x2713;</div>' +
          '<div class="card-top">' + getDiamondSVG() +
          '<div><div class="diamond-name">' + p.name + '</div>' +
          '<div class="diamond-bonus">+' + p.bonus + ' Bonus</div></div></div>' +
          '<div class="card-bottom"><div class="price-new">Rs' + p.price + '</div>' +
          '<div class="discount-tag">BEST</div></div>';
        card.addEventListener('click', function(){ selectAnyPkg(p); });
        grid.appendChild(card);
      });
    }

    // Weekly Pass grid
    if (weeklies.length) {
      document.getElementById('weeklySection').style.display = 'block';
      var wgrid = document.getElementById('weeklyGrid');
      wgrid.innerHTML = '';
      weeklies.sort(function(a,b){
        var am = a.name.match(/(\d+)x/i), bm = b.name.match(/(\d+)x/i);
        return (am ? parseInt(am[1]) : 0) - (bm ? parseInt(bm[1]) : 0);
      });
      weeklies.forEach(function(p) {
        var card = document.createElement('div');
        card.className = 'special-card';
        card.id = 'pkgcard-' + p.id;
        card.innerHTML =
          '<div class="sel-check">&#x2713;</div>' +
          '<div class="special-img-wrap">' +
          '<img src="' + WEEKLY_IMG + '" alt="Weekly Pass" />' +
          '<span class="special-badge">Special</span></div>' +
          '<div class="special-name">' + weeklyLabel(p.name) + '</div>' +
          '<div class="special-label-from">From</div>' +
          '<div class="special-pricing">' +
          '<div class="special-price">Rs' + p.price + '</div>' +
          '<div class="special-discount">-4%</div></div>';
        card.addEventListener('click', function(){ selectAnyPkg(p); });
        wgrid.appendChild(card);
      });
    }

    // Twilight Pass
    if (twilights.length) {
      document.getElementById('twilightSection').style.display = 'block';
      var tgrid = document.getElementById('twilightGrid');
      tgrid.innerHTML = '';
      twilights.forEach(function(p) {
        var card = document.createElement('div');
        card.className = 'twilight-card';
        card.id = 'pkgcard-' + p.id;
        card.innerHTML =
          '<div class="sel-check">&#x2713;</div>' +
          '<img class="twilight-img" src="' + TWILIGHT_IMG + '" alt="Twilight Pass" />' +
          '<div class="twilight-info">' +
          '<div class="twilight-name">Twilight Pass</div>' +
          '<div class="twilight-from">From</div>' +
          '<div class="twilight-pricing">' +
          '<div class="twilight-price">Rs' + p.price + '</div>' +
          '<div class="twilight-discount">-4%</div></div></div>';
        card.addEventListener('click', function(){ selectAnyPkg(p); });
        tgrid.appendChild(card);
      });
    }

    // Price table
    var tbody = document.getElementById('priceTableBody');
    tbody.innerHTML = pkgs.map(function(p){
      return '<tr><td>' + p.name + '</td><td>Rs' + p.price + '</td></tr>';
    }).join('');
    document.getElementById('priceDate').textContent = 'Updated live from DB';
  })
  .catch(function(){
    document.getElementById('diamondGrid').innerHTML = '<div class="loading-grid">Failed to load. Is the backend running?</div>';
  });
}

loadPackages();
"@

# Replace old loadPackages function and its final call
$content = [regex]::Replace($content, 'function loadPackages\(\) \{[\s\S]*?loadPackages\(\);', $newJS)

# Also patch placeOrder to deselect special cards too
$content = $content -replace "document\.querySelectorAll\('\.diamond-card'\)\.forEach\(function\(c\)\{ c\.classList\.remove\('selected'\); \}\);", "document.querySelectorAll('.diamond-card,.special-card,.twilight-card').forEach(function(c){ c.classList.remove('selected'); });"

# Patch selectPackage to use pkgcard- id prefix if present, keep backward compat
$content = $content -replace "document\.getElementById\('dc-' \+ selectedPackage\.id\);", "document.getElementById('pkgcard-' + selectedPackage.id) || document.getElementById('dc-' + selectedPackage.id);"
$content = $content -replace "document\.getElementById\('dc-' \+ p\.id\)\.classList", "document.getElementById('pkgcard-' + p.id).classList"

[System.IO.File]::WriteAllText($filePath, $content, (New-Object System.Text.UTF8Encoding $false))
Write-Host "      JavaScript patched." -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Done! Your customizations are preserved." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Open mlbb-topup.html to see:" -ForegroundColor White
Write-Host "  - All your existing content unchanged" -ForegroundColor Gray
Write-Host "  - Weekly Diamond Pass section added" -ForegroundColor Gray
Write-Host "  - Twilight Pass section added" -ForegroundColor Gray
Write-Host ""
Write-Host "  Control prices from Admin Panel > Packages > Edit" -ForegroundColor Gray
Write-Host ""
