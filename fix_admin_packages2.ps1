# ============================================================
#  MLBB - Fix Admin Packages: Save + Clean Layout
#  Run from: D:\MLBB>  .\fix_admin_packages2.ps1
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Fix Admin Packages - Save + Layout" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$filePath = Join-Path (Get-Location).Path "admin\index.html"
$original = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

# We will do a full targeted replacement of key sections only

# ============================================================
# FIX 1: savePackage() validation - don't require name/diamonds/bonus for special packages
# ============================================================
Write-Host "[1/4] Fixing savePackage validation..." -ForegroundColor Yellow

$oldSave = "function savePackage() {
  var name=document.getElementById('pkgName').value.trim(), diamonds=parseInt(document.getElementById('pkgDiamonds').value), bonus=parseInt(document.getElementById('pkgBonus').value)||0, price=parseFloat(document.getElementById('pkgPrice').value), msg=document.getElementById('modalMsg');
  if (!name||!diamonds||!price) { msg.style.color='var(--red)'; msg.textContent='Fill all fields'; return; }
  fetch(editingPkgId?API+'/packages/'+editingPkgId:API+'/packages', { method:editingPkgId?'PATCH':'POST', headers:authHeaders(), body:JSON.stringify({name:name,diamonds:diamonds,bonus:bonus,price:price}) })
  .then(function(r){ return r.json().then(function(d){ return {ok:r.ok,d:d}; }); })
  .then(function(res){
    if (!res.ok) { msg.style.color='var(--red)'; msg.textContent='Failed to save'; return; }
    msg.style.color='var(--green)'; msg.textContent=editingPkgId?'Updated!':'Added!';
    setTimeout(function(){ closeModal(); loadPackages(); }, 900);
  })
  .catch(function(){ msg.style.color='var(--red)'; msg.textContent='Server error'; });
}"

$newSave = "function savePackage() {
  var name     = document.getElementById('pkgName').value.trim();
  var diamonds = parseInt(document.getElementById('pkgDiamonds').value) || 0;
  var bonus    = parseInt(document.getElementById('pkgBonus').value) || 0;
  var price    = parseFloat(document.getElementById('pkgPrice').value);
  var msg      = document.getElementById('modalMsg');
  var isSpecial = name.toLowerCase().indexOf('weekly pass') > -1 || name.toLowerCase().indexOf('twilight pass') > -1;
  if (!price || isNaN(price)) { msg.style.color='var(--red)'; msg.textContent='Enter a valid price'; return; }
  if (!isSpecial && !name) { msg.style.color='var(--red)'; msg.textContent='Enter package name'; return; }
  var payload = { price: price };
  if (!isSpecial) { payload.name = name; payload.diamonds = diamonds; payload.bonus = bonus; }
  fetch(editingPkgId ? API+'/packages/'+editingPkgId : API+'/packages', {
    method: editingPkgId ? 'PATCH' : 'POST',
    headers: authHeaders(),
    body: JSON.stringify(payload)
  })
  .then(function(r){ return r.json().then(function(d){ return {ok:r.ok,d:d}; }); })
  .then(function(res){
    if (!res.ok) { msg.style.color='var(--red)'; msg.textContent='Failed to save'; return; }
    msg.style.color='var(--green)'; msg.textContent=editingPkgId?'Updated!':'Added!';
    setTimeout(function(){ closeModal(); loadPackages(); }, 900);
  })
  .catch(function(){ msg.style.color='var(--red)'; msg.textContent='Server error'; });
}"

$original = $original.Replace($oldSave, $newSave)
Write-Host "      savePackage fixed." -ForegroundColor Green

# ============================================================
# FIX 2: Replace CSS for pkg-grid to match diamond card compact style
# ============================================================
Write-Host "[2/4] Fixing packages CSS layout..." -ForegroundColor Yellow

$oldPkgCSS = ".pkg-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:14px;padding:20px;}"
$newPkgCSS = ".pkg-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(190px,1fr));gap:12px;padding:20px;}"
$original = $original.Replace($oldPkgCSS, $newPkgCSS)

# Make pkg-card more compact
$oldPkgCard = ".pkg-card{background:var(--bg3);border:1px solid var(--border);border-radius:12px;padding:18px;}"
$newPkgCard = ".pkg-card{background:var(--bg3);border:1px solid var(--border);border-radius:12px;padding:14px;}"
$original = $original.Replace($oldPkgCard, $newPkgCard)

Write-Host "      CSS updated." -ForegroundColor Green

# ============================================================
# FIX 3: Inject updated CSS for special grid to also be compact
# ============================================================
Write-Host "[3/4] Adding compact special grid CSS..." -ForegroundColor Yellow

$extraCSS = "
.pkg-special-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(190px,1fr));gap:12px;padding:0 20px 20px;}
.pkg-special-card{background:var(--bg3);border:1px solid var(--border);border-radius:12px;padding:14px;}
.pkg-special-card.inactive{opacity:0.45;}
.pkg-special-img{width:100%;height:65px;object-fit:cover;border-radius:8px;margin-bottom:8px;display:block;}
.pkg-special-name{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:0.95rem;color:#fff;margin-bottom:4px;}
.pkg-special-price{font-family:'Orbitron',sans-serif;font-size:0.95rem;color:var(--gold);font-weight:700;margin-bottom:10px;}
.pkg-special-badge{display:inline-block;background:linear-gradient(135deg,#FF2D55,#FF6B00);border-radius:5px;padding:1px 7px;font-size:0.62rem;font-weight:700;color:#fff;font-family:'Rajdhani',sans-serif;letter-spacing:1px;text-transform:uppercase;margin-bottom:6px;}
.pkg-section-title{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:0.8rem;letter-spacing:2px;text-transform:uppercase;color:var(--muted);padding:16px 20px 6px;display:flex;align-items:center;gap:8px;}
.pkg-divider{height:1px;background:var(--border);margin:4px 20px;}
"

# Replace any existing special CSS block we added previously (or just append to </style>)
$original = $original.Replace("</style>", $extraCSS + "</style>")

Write-Host "      CSS injected." -ForegroundColor Green

# ============================================================
# FIX 4: Replace loadPackages with clean compact version
# ============================================================
Write-Host "[4/4] Replacing loadPackages with clean version..." -ForegroundColor Yellow

$newLoadPkgs = 'var WEEKLY_IMG_ADMIN="https://i.imgur.com/wpjoOwV.jpeg";var TWILIGHT_IMG_ADMIN="https://i.imgur.com/Lhj3x20.jpeg";function getPkgType(name){var n=name.toLowerCase();if(n.indexOf("weekly pass")>-1)return"weekly";if(n.indexOf("twilight pass")>-1)return"twilight";return"diamond";}function loadPackages(){fetch(API+"/packages").then(function(r){return r.json();}).then(function(pkgs){var diamonds=pkgs.filter(function(p){return getPkgType(p.name)==="diamond";});var weeklies=pkgs.filter(function(p){return getPkgType(p.name)==="weekly";});var twilights=pkgs.filter(function(p){return getPkgType(p.name)==="twilight";});var html="";html+="<div class=\"pkg-section-title\">&#x25C6; Diamond Packages</div><div class=\"pkg-grid\">";html+=diamonds.map(function(p){return"<div class=\"pkg-card "+(p.active?"":"inactive")+"\" id=\"pkg-"+p.id+"\"><div class=\"pkg-name\">"+p.name+"</div><div class=\"pkg-diamonds\">"+p.diamonds+" + "+p.bonus+" bonus</div><div class=\"pkg-price\">Rs"+p.price+"</div><div class=\"pkg-actions\"><button class=\"btn-edit\" data-pkgid=\""+p.id+"\" data-name=\""+p.name+"\" data-diamonds=\""+p.diamonds+"\" data-bonus=\""+p.bonus+"\" data-price=\""+p.price+"\">Edit</button><button class=\"btn-toggle "+(p.active?"":"activate")+"\" data-pkgid=\""+p.id+"\" data-active=\""+p.active+"\">"+(p.active?"Deactivate":"Activate")+"</button></div></div>";}).join("");html+="</div>";if(weeklies.length){weeklies.sort(function(a,b){var am=a.name.match(/(\d+)x/i),bm=b.name.match(/(\d+)x/i);return(am?parseInt(am[1]):0)-(bm?parseInt(bm[1]):0);});html+="<div class=\"pkg-divider\"></div><div class=\"pkg-section-title\">&#x25B6; Weekly Diamond Pass</div><div class=\"pkg-special-grid\">";html+=weeklies.map(function(p){var m=p.name.match(/(\d+)x/i);var label=m?m[1]+"x Weekly Pass":"Weekly Pass";return"<div class=\"pkg-special-card "+(p.active?"":"inactive")+"\" id=\"pkg-"+p.id+"\"><img class=\"pkg-special-img\" src=\""+WEEKLY_IMG_ADMIN+"\" alt=\"Weekly Pass\" /><div class=\"pkg-special-badge\">Special</div><div class=\"pkg-special-name\">"+label+"</div><div class=\"pkg-special-price\">Rs"+p.price+"</div><div class=\"pkg-actions\"><button class=\"btn-edit\" data-pkgid=\""+p.id+"\" data-name=\""+p.name+"\" data-diamonds=\""+p.diamonds+"\" data-bonus=\""+p.bonus+"\" data-price=\""+p.price+"\">Edit</button><button class=\"btn-toggle "+(p.active?"":"activate")+"\" data-pkgid=\""+p.id+"\" data-active=\""+p.active+"\">"+(p.active?"Deactivate":"Activate")+"</button></div></div>";}).join("");html+="</div>";}if(twilights.length){html+="<div class=\"pkg-divider\"></div><div class=\"pkg-section-title\">&#x2605; Twilight Pass</div><div class=\"pkg-special-grid\">";html+=twilights.map(function(p){return"<div class=\"pkg-special-card "+(p.active?"":"inactive")+"\" id=\"pkg-"+p.id+"\"><img class=\"pkg-special-img\" src=\""+TWILIGHT_IMG_ADMIN+"\" alt=\"Twilight Pass\" /><div class=\"pkg-special-badge\">Limited</div><div class=\"pkg-special-name\">Twilight Pass</div><div class=\"pkg-special-price\">Rs"+p.price+"</div><div class=\"pkg-actions\"><button class=\"btn-edit\" data-pkgid=\""+p.id+"\" data-name=\""+p.name+"\" data-diamonds=\""+p.diamonds+"\" data-bonus=\""+p.bonus+"\" data-price=\""+p.price+"\">Edit</button><button class=\"btn-toggle "+(p.active?"":"activate")+"\" data-pkgid=\""+p.id+"\" data-active=\""+p.active+"\">"+(p.active?"Deactivate":"Activate")+"</button></div></div>";}).join("");html+="</div>";}document.getElementById("pkgGrid").innerHTML=html;}).catch(function(){showToast("Failed to load packages",true);});}'

$original = [regex]::Replace(
    $original,
    '(?s)(var WEEKLY_IMG_ADMIN.*?)?function (getPkgType.*?)?loadPackages\(\).*?\.catch\(function\(\)\{ showToast\(''Failed to load packages'', true\); \}\);\s*\}',
    $newLoadPkgs
)

# Fix openEditPackage - show/hide fields correctly + clear hidden fields so validation passes
$newOpenEdit = "function openEditPackage(id,name,diamonds,bonus,price) {
  editingPkgId = id;
  var isSpecial = name.toLowerCase().indexOf('weekly pass') > -1 || name.toLowerCase().indexOf('twilight pass') > -1;
  document.getElementById('modalTitle').textContent = isSpecial ? 'Edit Price' : 'Edit Package';
  document.getElementById('pkgName').value     = name;
  document.getElementById('pkgDiamonds').value = diamonds;
  document.getElementById('pkgBonus').value    = bonus || 0;
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

$original = [regex]::Replace(
    $original,
    '(?s)function openEditPackage\(id,name,diamonds,bonus,price\) \{.*?document\.getElementById\(''pkgModal''\)\.classList\.add\(''open''\);\s*\}',
    $newOpenEdit
)

[System.IO.File]::WriteAllText(
    $filePath,
    $original,
    (New-Object System.Text.UTF8Encoding $false)
)
Write-Host "      admin/index.html saved." -ForegroundColor Green

Write-Host ""
Write-Host "Restarting nginx..." -ForegroundColor Yellow
docker compose restart nginx
Write-Host "      Done." -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Fixed!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Open http://localhost/admin/ > Packages" -ForegroundColor White
Write-Host ""
Write-Host "  - Diamond packs: compact grid, Edit opens full modal" -ForegroundColor Gray
Write-Host "  - Weekly Pass: compact grid with images, Edit opens" -ForegroundColor Gray
Write-Host "    price-only modal - type new price, Save works" -ForegroundColor Gray
Write-Host "  - Twilight Pass: same - price-only edit, Save works" -ForegroundColor Gray
Write-Host "  - Deactivate hides from customer page instantly" -ForegroundColor Gray
Write-Host ""
