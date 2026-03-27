# ============================================================
#  MLBB - Fix Admin Panel for Special Packages
#  Run from: D:\MLBB>  .\fix_admin_packages.ps1
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Fix Admin Panel - Special Package Groups" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/2] Patching admin/index.html..." -ForegroundColor Yellow

$filePath = Join-Path (Get-Location).Path "admin\index.html"
$content  = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

# Inject CSS
$css = ".pkg-section-title{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:0.85rem;letter-spacing:2px;text-transform:uppercase;color:var(--muted);padding:18px 20px 8px;display:flex;align-items:center;gap:8px;}.pkg-divider{height:1px;background:var(--border);margin:8px 20px 4px;}.pkg-special-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:14px;padding:0 20px 20px;}.pkg-special-card{background:var(--bg3);border:1px solid var(--border);border-radius:12px;padding:18px;}.pkg-special-card.inactive{opacity:0.45;}.pkg-special-img{width:100%;height:70px;object-fit:cover;border-radius:8px;margin-bottom:10px;display:block;}.pkg-special-name{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1rem;color:#fff;margin-bottom:4px;}.pkg-special-price{font-family:'Orbitron',sans-serif;font-size:1rem;color:var(--gold);font-weight:700;margin-bottom:12px;}.pkg-special-badge{display:inline-block;background:linear-gradient(135deg,#FF2D55,#FF6B00);border-radius:5px;padding:1px 8px;font-size:0.65rem;font-weight:700;color:#fff;font-family:'Rajdhani',sans-serif;letter-spacing:1px;text-transform:uppercase;margin-bottom:8px;}"
$content = $content.Replace("</style>", $css + "`n</style>")

# Write the new JS to a temp file to avoid PowerShell parsing
$jsContent = 'var WEEKLY_IMG_ADMIN="https://i.imgur.com/wpjoOwV.jpeg";var TWILIGHT_IMG_ADMIN="https://i.imgur.com/Lhj3x20.jpeg";function getPkgType(name){var n=name.toLowerCase();if(n.indexOf("weekly pass")>-1)return"weekly";if(n.indexOf("twilight pass")>-1)return"twilight";return"diamond";}function loadPackages(){fetch(API+"/packages").then(function(r){return r.json();}).then(function(pkgs){var diamonds=pkgs.filter(function(p){return getPkgType(p.name)==="diamond";});var weeklies=pkgs.filter(function(p){return getPkgType(p.name)==="weekly";});var twilights=pkgs.filter(function(p){return getPkgType(p.name)==="twilight";});var html="";html+="<div class=\"pkg-section-title\">&#x25C6; Diamond Packages</div>";html+="<div class=\"pkg-grid\">";html+=diamonds.map(function(p){return"<div class=\"pkg-card "+(p.active?"":"inactive")+"\" id=\"pkg-"+p.id+"\"><div class=\"pkg-name\">"+p.name+"</div><div class=\"pkg-diamonds\">"+p.diamonds+" + "+p.bonus+" bonus</div><div class=\"pkg-price\">Rs"+p.price+"</div><div class=\"pkg-actions\"><button class=\"btn-edit\" data-pkgid=\""+p.id+"\" data-name=\""+p.name+"\" data-diamonds=\""+p.diamonds+"\" data-bonus=\""+p.bonus+"\" data-price=\""+p.price+"\">Edit</button><button class=\"btn-toggle "+(p.active?"":"activate")+"\" data-pkgid=\""+p.id+"\" data-active=\""+p.active+"\">"+(p.active?"Deactivate":"Activate")+"</button></div></div>";}).join("");html+="</div>";if(weeklies.length){html+="<div class=\"pkg-divider\"></div>";html+="<div class=\"pkg-section-title\">&#x25B6; Weekly Diamond Pass</div>";html+="<div class=\"pkg-special-grid\">";weeklies.sort(function(a,b){var am=a.name.match(/(\d+)x/i),bm=b.name.match(/(\d+)x/i);return(am?parseInt(am[1]):0)-(bm?parseInt(bm[1]):0);});html+=weeklies.map(function(p){var m=p.name.match(/(\d+)x/i);var label=m?m[1]+"x Weekly Diamond Pass":"Weekly Diamond Pass";return"<div class=\"pkg-special-card "+(p.active?"":"inactive")+"\" id=\"pkg-"+p.id+"\"><img class=\"pkg-special-img\" src=\""+WEEKLY_IMG_ADMIN+"\" alt=\"Weekly Pass\" /><div class=\"pkg-special-badge\">Special</div><div class=\"pkg-special-name\">"+label+"</div><div class=\"pkg-special-price\">Rs"+p.price+"</div><div class=\"pkg-actions\"><button class=\"btn-edit\" data-pkgid=\""+p.id+"\" data-name=\""+p.name+"\" data-diamonds=\""+p.diamonds+"\" data-bonus=\""+p.bonus+"\" data-price=\""+p.price+"\">Edit Price</button><button class=\"btn-toggle "+(p.active?"":"activate")+"\" data-pkgid=\""+p.id+"\" data-active=\""+p.active+"\">"+(p.active?"Deactivate":"Activate")+"</button></div></div>";}).join("");html+="</div>";}if(twilights.length){html+="<div class=\"pkg-divider\"></div>";html+="<div class=\"pkg-section-title\">&#x2605; Twilight Pass</div>";html+="<div class=\"pkg-special-grid\">";html+=twilights.map(function(p){return"<div class=\"pkg-special-card "+(p.active?"":"inactive")+"\" id=\"pkg-"+p.id+"\"><img class=\"pkg-special-img\" src=\""+TWILIGHT_IMG_ADMIN+"\" alt=\"Twilight Pass\" /><div class=\"pkg-special-badge\">Limited</div><div class=\"pkg-special-name\">Twilight Pass</div><div class=\"pkg-special-price\">Rs"+p.price+"</div><div class=\"pkg-actions\"><button class=\"btn-edit\" data-pkgid=\""+p.id+"\" data-name=\""+p.name+"\" data-diamonds=\""+p.diamonds+"\" data-bonus=\""+p.bonus+"\" data-price=\""+p.price+"\">Edit Price</button><button class=\"btn-toggle "+(p.active?"":"activate")+"\" data-pkgid=\""+p.id+"\" data-active=\""+p.active+"\">"+(p.active?"Deactivate":"Activate")+"</button></div></div>";}).join("");html+="</div>";}document.getElementById("pkgGrid").innerHTML=html;}).catch(function(){showToast("Failed to load packages",true);});}'

# Use regex to replace the entire old loadPackages function
$content = [regex]::Replace(
    $content,
    '(?s)function loadPackages\(\).*?\.catch\(function\(\)\{ showToast\(''Failed to load packages'', true\); \}\);\s*\}',
    $jsContent
)

# Patch openEditPackage to show price-only modal for special packages
$newEdit = "function openEditPackage(id,name,diamonds,bonus,price) {
  editingPkgId = id;
  var isSpecial = name.toLowerCase().indexOf('weekly pass') > -1 || name.toLowerCase().indexOf('twilight pass') > -1;
  document.getElementById('modalTitle').textContent = isSpecial ? 'Edit Price' : 'Edit Package';
  document.getElementById('pkgName').value     = name;
  document.getElementById('pkgDiamonds').value = diamonds;
  document.getElementById('pkgBonus').value    = bonus;
  document.getElementById('pkgPrice').value    = price;
  document.getElementById('modalMsg').textContent = '';
  var df = document.getElementById('pkgDiamonds').closest('.field');
  var bf = document.getElementById('pkgBonus').closest('.field');
  var nf = document.getElementById('pkgName').closest('.field');
  if (df) df.style.display = isSpecial ? 'none' : '';
  if (bf) bf.style.display = isSpecial ? 'none' : '';
  if (nf) nf.style.display = isSpecial ? 'none' : '';
  document.getElementById('pkgModal').classList.add('open');
}"

$content = [regex]::Replace(
    $content,
    '(?s)function openEditPackage\(id,name,diamonds,bonus,price\) \{.*?document\.getElementById\(''pkgModal''\)\.classList\.add\(''open''\);\s*\}',
    $newEdit
)

[System.IO.File]::WriteAllText(
    $filePath,
    $content,
    (New-Object System.Text.UTF8Encoding $false)
)

Write-Host "      admin/index.html patched." -ForegroundColor Green

Write-Host "[2/2] Restarting nginx..." -ForegroundColor Yellow
docker compose restart nginx
Write-Host "      Done." -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Admin Panel Fixed!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Open: http://localhost/admin/ > Packages" -ForegroundColor White
Write-Host ""
Write-Host "  Sections:" -ForegroundColor White
Write-Host "  Diamond Packages - all your normal packs" -ForegroundColor Gray
Write-Host "  Weekly Pass      - grouped with images, sorted 1x-4x" -ForegroundColor Gray
Write-Host "  Twilight Pass    - own section with image" -ForegroundColor Gray
Write-Host ""
Write-Host "  Edit Price on special = price field only (clean)" -ForegroundColor Gray
Write-Host ""
