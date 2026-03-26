# ============================================================
#  MLBB TopUp Nepal - Phase 3: Admin Dashboard
#  Run from: D:\MLBB>  .\phase3_admin_dashboard.ps1
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  MLBB TopUp Nepal - Phase 3 Admin Dashboard" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Creating admin folder..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "admin" | Out-Null
Write-Host "      Done." -ForegroundColor Green

Write-Host "[2/3] Writing admin dashboard HTML..." -ForegroundColor Yellow

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MLBB Admin Panel</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Exo+2:wght@400;600;700&family=Orbitron:wght@400;700;900&family=Rajdhani:wght@400;600;700&display=swap" rel="stylesheet">
<style>
:root{--gold:#FFD700;--gold-dark:#C8A800;--blue:#00C8FF;--red:#FF2D55;--green:#00E676;--bg:#080C14;--bg2:#0E1422;--bg3:#121929;--border:rgba(255,215,0,0.15);--text:#E8EAF6;--muted:#7B86A0;}
*{margin:0;padding:0;box-sizing:border-box;}
body{font-family:'Exo 2',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;}
body::before{content:'';position:fixed;inset:0;background:radial-gradient(ellipse 80% 50% at 10% 10%,rgba(0,71,255,0.1) 0%,transparent 60%);pointer-events:none;z-index:0;}
#loginScreen{position:fixed;inset:0;background:var(--bg);display:flex;align-items:center;justify-content:center;z-index:100;}
.login-box{background:var(--bg2);border:1px solid var(--border);border-radius:20px;padding:40px 36px;width:100%;max-width:400px;position:relative;}
.login-box::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,var(--gold),transparent);border-radius:20px 20px 0 0;}
.login-logo{text-align:center;margin-bottom:28px;}
.login-logo h1{font-family:'Orbitron',sans-serif;font-size:1.4rem;background:linear-gradient(90deg,#FFD700,#FF6B00);-webkit-background-clip:text;-webkit-text-fill-color:transparent;}
.login-logo p{color:var(--muted);font-size:0.82rem;margin-top:4px;letter-spacing:2px;text-transform:uppercase;}
.field{margin-bottom:18px;}
.field label{display:block;font-family:'Rajdhani',sans-serif;font-size:0.78rem;font-weight:600;letter-spacing:2px;text-transform:uppercase;color:var(--muted);margin-bottom:8px;}
.field input{width:100%;background:rgba(255,255,255,0.04);border:1px solid rgba(255,215,0,0.2);border-radius:10px;padding:13px 16px;font-family:'Exo 2',sans-serif;font-size:0.95rem;color:#fff;outline:none;transition:all 0.3s;}
.field input:focus{border-color:var(--gold);box-shadow:0 0 20px rgba(255,215,0,0.1);}
.login-btn{width:100%;background:linear-gradient(135deg,#FFD700,#FF6B00);border:none;border-radius:50px;padding:14px;font-family:'Orbitron',sans-serif;font-weight:700;font-size:0.9rem;color:#000;cursor:pointer;letter-spacing:2px;margin-top:8px;transition:all 0.3s;}
.login-btn:hover{transform:translateY(-2px);box-shadow:0 8px 30px rgba(255,215,0,0.4);}
.login-err{color:var(--red);font-size:0.82rem;text-align:center;margin-top:12px;min-height:18px;}
#appScreen{display:none;min-height:100vh;}
.sidebar{position:fixed;left:0;top:0;bottom:0;width:220px;background:var(--bg2);border-right:1px solid var(--border);z-index:10;display:flex;flex-direction:column;}
.sidebar-logo{padding:24px 20px 20px;border-bottom:1px solid var(--border);}
.sidebar-logo h2{font-family:'Orbitron',sans-serif;font-size:1rem;background:linear-gradient(90deg,#FFD700,#FF6B00);-webkit-background-clip:text;-webkit-text-fill-color:transparent;}
.sidebar-logo p{font-size:0.72rem;color:var(--muted);margin-top:2px;letter-spacing:1px;}
nav{flex:1;padding:16px 12px;}
.nav-item{display:flex;align-items:center;gap:12px;padding:11px 14px;border-radius:10px;cursor:pointer;font-family:'Rajdhani',sans-serif;font-weight:600;font-size:0.95rem;color:var(--muted);transition:all 0.2s;margin-bottom:4px;}
.nav-item:hover{background:rgba(255,215,0,0.06);color:#fff;}
.nav-item.active{background:rgba(255,215,0,0.1);color:var(--gold);border-left:3px solid var(--gold);padding-left:11px;}
.sidebar-footer{padding:16px 20px;border-top:1px solid var(--border);}
.admin-badge{display:flex;align-items:center;gap:10px;}
.admin-avatar{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,var(--gold),#FF6B00);display:flex;align-items:center;justify-content:center;font-weight:700;font-size:0.85rem;color:#000;}
.admin-info .name{color:#fff;font-weight:600;font-size:0.85rem;}
.admin-info .role{color:var(--muted);font-size:0.7rem;text-transform:uppercase;letter-spacing:1px;}
.logout-btn{background:none;border:1px solid rgba(255,45,85,0.3);border-radius:8px;padding:6px 14px;color:var(--red);font-size:0.78rem;cursor:pointer;font-family:'Rajdhani',sans-serif;font-weight:600;transition:all 0.2s;margin-top:10px;width:100%;}
.logout-btn:hover{background:rgba(255,45,85,0.1);}
.main{margin-left:220px;padding:28px;position:relative;z-index:1;}
.page{display:none;}
.page.active{display:block;}
.topbar{display:flex;align-items:center;justify-content:space-between;margin-bottom:28px;}
.topbar h1{font-family:'Orbitron',sans-serif;font-size:1.2rem;color:#fff;}
.live-dot{display:flex;align-items:center;gap:6px;font-size:0.78rem;color:var(--green);font-family:'Rajdhani',sans-serif;font-weight:600;}
@keyframes blink{0%,100%{opacity:1}50%{opacity:0.2}}
.stats-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:28px;}
.stat-card{background:var(--bg2);border:1px solid var(--border);border-radius:14px;padding:20px;position:relative;overflow:hidden;}
.stat-card::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;}
.stat-card.gold::before{background:linear-gradient(90deg,transparent,var(--gold),transparent);}
.stat-card.blue::before{background:linear-gradient(90deg,transparent,var(--blue),transparent);}
.stat-card.green::before{background:linear-gradient(90deg,transparent,var(--green),transparent);}
.stat-card.red::before{background:linear-gradient(90deg,transparent,var(--red),transparent);}
.stat-label{font-family:'Rajdhani',sans-serif;font-size:0.72rem;letter-spacing:2px;text-transform:uppercase;color:var(--muted);margin-bottom:8px;}
.stat-value{font-family:'Orbitron',sans-serif;font-size:1.6rem;font-weight:700;}
.stat-card.gold .stat-value{color:var(--gold);}
.stat-card.blue .stat-value{color:var(--blue);}
.stat-card.green .stat-value{color:var(--green);}
.stat-card.red .stat-value{color:var(--red);}
.stat-sub{font-size:0.75rem;color:var(--muted);margin-top:4px;}
.section-card{background:var(--bg2);border:1px solid var(--border);border-radius:16px;overflow:hidden;margin-bottom:24px;}
.section-head{display:flex;align-items:center;justify-content:space-between;padding:18px 22px;border-bottom:1px solid var(--border);}
.section-head h3{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1rem;letter-spacing:1px;text-transform:uppercase;color:#fff;}
.refresh-btn{background:rgba(0,200,255,0.1);border:1px solid rgba(0,200,255,0.3);border-radius:8px;padding:6px 14px;color:var(--blue);font-size:0.78rem;cursor:pointer;font-family:'Rajdhani',sans-serif;font-weight:600;}
.refresh-btn:hover{background:rgba(0,200,255,0.2);}
.table-wrap{overflow-x:auto;}
table{width:100%;border-collapse:collapse;}
thead tr th{padding:11px 18px;font-family:'Rajdhani',sans-serif;font-size:0.72rem;letter-spacing:2px;text-transform:uppercase;color:var(--muted);text-align:left;background:rgba(0,0,0,0.2);border-bottom:1px solid rgba(255,255,255,0.06);}
tbody tr{border-bottom:1px solid rgba(255,255,255,0.04);transition:background 0.2s;}
tbody tr:hover{background:rgba(255,215,0,0.02);}
tbody td{padding:12px 18px;font-size:0.88rem;}
.order-id{font-family:'Orbitron',sans-serif;font-size:0.75rem;color:var(--muted);}
.game-id{font-family:'Orbitron',sans-serif;font-size:0.78rem;color:var(--blue);}
.price-cell{font-family:'Orbitron',sans-serif;font-size:0.82rem;color:var(--gold);font-weight:700;}
.badge{display:inline-flex;align-items:center;padding:3px 10px;border-radius:20px;font-family:'Rajdhani',sans-serif;font-weight:600;font-size:0.75rem;}
.badge-pending{background:rgba(255,215,0,0.12);color:var(--gold);border:1px solid rgba(255,215,0,0.3);}
.badge-processing{background:rgba(0,200,255,0.12);color:var(--blue);border:1px solid rgba(0,200,255,0.3);}
.badge-delivered{background:rgba(0,230,118,0.12);color:var(--green);border:1px solid rgba(0,230,118,0.3);}
.badge-failed{background:rgba(255,45,85,0.12);color:var(--red);border:1px solid rgba(255,45,85,0.3);}
.action-btns{display:flex;gap:6px;flex-wrap:wrap;}
.btn-sm{padding:4px 10px;border-radius:6px;font-family:'Rajdhani',sans-serif;font-weight:600;font-size:0.72rem;cursor:pointer;border:none;transition:all 0.2s;}
.btn-process{background:rgba(0,200,255,0.15);color:var(--blue);border:1px solid rgba(0,200,255,0.3);}
.btn-deliver{background:rgba(0,230,118,0.15);color:var(--green);border:1px solid rgba(0,230,118,0.3);}
.btn-fail{background:rgba(255,45,85,0.12);color:var(--red);border:1px solid rgba(255,45,85,0.3);}
.filter-bar{display:flex;gap:10px;padding:14px 22px;border-bottom:1px solid var(--border);flex-wrap:wrap;align-items:center;}
.filter-btn{padding:5px 14px;border-radius:20px;font-family:'Rajdhani',sans-serif;font-weight:600;font-size:0.78rem;cursor:pointer;border:1px solid rgba(255,255,255,0.1);background:none;color:var(--muted);transition:all 0.2s;}
.filter-btn.active{border-color:var(--gold);color:var(--gold);background:rgba(255,215,0,0.08);}
.filter-search{margin-left:auto;background:rgba(255,255,255,0.04);border:1px solid rgba(255,215,0,0.15);border-radius:8px;padding:6px 14px;color:#fff;font-size:0.82rem;outline:none;font-family:'Exo 2',sans-serif;width:200px;}
.filter-search::placeholder{color:var(--muted);}
.filter-search:focus{border-color:var(--gold);}
.pkg-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:14px;padding:20px;}
.pkg-card{background:var(--bg3);border:1px solid var(--border);border-radius:12px;padding:18px;}
.pkg-card.inactive{opacity:0.45;}
.pkg-name{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1rem;color:#fff;margin-bottom:4px;}
.pkg-diamonds{font-size:0.78rem;color:var(--blue);margin-bottom:10px;}
.pkg-price{font-family:'Orbitron',sans-serif;font-size:1.1rem;color:var(--gold);font-weight:700;margin-bottom:12px;}
.pkg-actions{display:flex;gap:8px;}
.btn-edit{background:rgba(0,200,255,0.1);border:1px solid rgba(0,200,255,0.3);border-radius:6px;padding:5px 12px;color:var(--blue);font-size:0.75rem;cursor:pointer;font-family:'Rajdhani',sans-serif;font-weight:600;}
.btn-toggle{background:rgba(255,45,85,0.1);border:1px solid rgba(255,45,85,0.3);border-radius:6px;padding:5px 12px;color:var(--red);font-size:0.75rem;cursor:pointer;font-family:'Rajdhani',sans-serif;font-weight:600;}
.btn-toggle.activate{background:rgba(0,230,118,0.1);border-color:rgba(0,230,118,0.3);color:var(--green);}
.add-pkg-btn{background:linear-gradient(135deg,var(--gold),#FF6B00);border:none;border-radius:50px;padding:9px 22px;font-family:'Orbitron',sans-serif;font-weight:700;font-size:0.78rem;color:#000;cursor:pointer;letter-spacing:1px;transition:all 0.3s;}
.add-pkg-btn:hover{transform:translateY(-2px);box-shadow:0 6px 24px rgba(255,215,0,0.35);}
.modal-overlay{position:fixed;inset:0;background:rgba(0,0,0,0.7);z-index:200;display:none;align-items:center;justify-content:center;}
.modal-overlay.open{display:flex;}
.modal{background:var(--bg2);border:1px solid var(--border);border-radius:18px;padding:32px;width:100%;max-width:420px;position:relative;}
.modal::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,var(--gold),transparent);border-radius:18px 18px 0 0;}
.modal h3{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1.1rem;letter-spacing:1px;text-transform:uppercase;color:var(--gold);margin-bottom:20px;}
.modal-btns{display:flex;gap:10px;margin-top:20px;}
.btn-save{flex:1;background:linear-gradient(135deg,var(--gold),#FF6B00);border:none;border-radius:10px;padding:12px;font-family:'Orbitron',sans-serif;font-weight:700;font-size:0.82rem;color:#000;cursor:pointer;}
.btn-cancel{flex:1;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.12);border-radius:10px;padding:12px;font-family:'Rajdhani',sans-serif;font-weight:600;font-size:0.88rem;color:var(--muted);cursor:pointer;}
.modal-msg{font-size:0.82rem;min-height:18px;margin-top:10px;text-align:center;}
.empty-state{padding:48px;text-align:center;color:var(--muted);}
.empty-state .icon{font-size:2.5rem;margin-bottom:12px;}
.toast{position:fixed;bottom:24px;right:24px;background:rgba(0,230,118,0.15);border:1px solid var(--green);border-radius:12px;padding:12px 20px;font-family:'Rajdhani',sans-serif;font-weight:600;color:var(--green);font-size:0.88rem;z-index:999;transform:translateY(80px);opacity:0;transition:all 0.4s;}
.toast.show{transform:translateY(0);opacity:1;}
.toast.error{background:rgba(255,45,85,0.15);border-color:var(--red);color:var(--red);}
.receipt-link{color:var(--blue);text-decoration:none;font-size:0.78rem;font-family:'Rajdhani',sans-serif;font-weight:600;}
.no-receipt{color:var(--muted);font-size:0.75rem;}
.note-text{font-size:0.78rem;color:var(--muted);max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;display:block;}
</style>
</head>
<body>

<div id="loginScreen">
  <div class="login-box">
    <div class="login-logo">
      <h1>MLBB ADMIN</h1>
      <p>Secure Admin Panel</p>
    </div>
    <div class="field">
      <label>Email</label>
      <input type="email" id="loginEmail" placeholder="admin@mlbbtopup.com" />
    </div>
    <div class="field">
      <label>Password</label>
      <input type="password" id="loginPassword" placeholder="Password" />
    </div>
    <button class="login-btn" id="loginBtn">ENTER PANEL</button>
    <div class="login-err" id="loginErr"></div>
  </div>
</div>

<div id="appScreen">
  <div class="sidebar">
    <div class="sidebar-logo">
      <h2>MLBB ADMIN</h2>
      <p>Admin Panel</p>
    </div>
    <nav>
      <div class="nav-item active" id="nav-dashboard">Dashboard</div>
      <div class="nav-item" id="nav-orders">Orders</div>
      <div class="nav-item" id="nav-packages">Packages</div>
    </nav>
    <div class="sidebar-footer">
      <div class="admin-badge">
        <div class="admin-avatar" id="adminInitial">A</div>
        <div class="admin-info">
          <div class="name" id="adminName">Admin</div>
          <div class="role">Administrator</div>
        </div>
      </div>
      <button class="logout-btn" id="logoutBtn">Logout</button>
    </div>
  </div>

  <div class="main">

    <div class="page active" id="page-dashboard">
      <div class="topbar">
        <h1>Dashboard</h1>
        <div class="live-dot" style="animation:blink 1.5s infinite">API LIVE</div>
      </div>
      <div class="stats-grid">
        <div class="stat-card gold"><div class="stat-label">Total Orders</div><div class="stat-value" id="stat-total">-</div><div class="stat-sub">All time</div></div>
        <div class="stat-card blue"><div class="stat-label">Pending</div><div class="stat-value" id="stat-pending">-</div><div class="stat-sub">Needs action</div></div>
        <div class="stat-card green"><div class="stat-label">Delivered</div><div class="stat-value" id="stat-delivered">-</div><div class="stat-sub">Completed</div></div>
        <div class="stat-card red"><div class="stat-label">Revenue</div><div class="stat-value" id="stat-revenue">-</div><div class="stat-sub">NPR delivered</div></div>
      </div>
      <div class="section-card">
        <div class="section-head">
          <h3>Recent Orders</h3>
          <button class="refresh-btn" id="dashRefreshBtn">Refresh</button>
        </div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>#</th><th>Game ID / Zone</th><th>Package</th><th>Payment</th><th>Status</th><th>Time</th><th>Actions</th></tr></thead>
            <tbody id="dashOrdersBody"></tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="page" id="page-orders">
      <div class="topbar">
        <h1>All Orders</h1>
        <button class="refresh-btn" id="ordersRefreshBtn">Refresh</button>
      </div>
      <div class="section-card">
        <div class="filter-bar">
          <button class="filter-btn active" data-filter="all">All</button>
          <button class="filter-btn" data-filter="pending">Pending</button>
          <button class="filter-btn" data-filter="processing">Processing</button>
          <button class="filter-btn" data-filter="delivered">Delivered</button>
          <button class="filter-btn" data-filter="failed">Failed</button>
          <input class="filter-search" id="orderSearch" placeholder="Search Game ID..." />
        </div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>#</th><th>Game ID / Zone</th><th>Package</th><th>Price</th><th>Payment</th><th>Receipt</th><th>Status</th><th>Note</th><th>Date</th><th>Actions</th></tr></thead>
            <tbody id="allOrdersBody"></tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="page" id="page-packages">
      <div class="topbar">
        <h1>Packages</h1>
        <button class="add-pkg-btn" id="addPkgBtn">+ Add Package</button>
      </div>
      <div class="section-card">
        <div class="pkg-grid" id="pkgGrid"></div>
      </div>
    </div>

  </div>
</div>

<div class="modal-overlay" id="pkgModal">
  <div class="modal">
    <h3 id="modalTitle">Add Package</h3>
    <div class="field"><label>Package Name</label><input type="text" id="pkgName" placeholder="e.g. 86 Diamonds" /></div>
    <div class="field"><label>Base Diamonds</label><input type="number" id="pkgDiamonds" placeholder="86" /></div>
    <div class="field"><label>Bonus Diamonds</label><input type="number" id="pkgBonus" placeholder="8" value="0" /></div>
    <div class="field"><label>Price (NPR)</label><input type="number" id="pkgPrice" placeholder="240.96" step="0.01" /></div>
    <div class="modal-btns">
      <button class="btn-cancel" id="modalCancelBtn">Cancel</button>
      <button class="btn-save" id="modalSaveBtn">Save Package</button>
    </div>
    <div class="modal-msg" id="modalMsg"></div>
  </div>
</div>

<div class="toast" id="toast"></div>

<script>
var API = 'http://localhost:4000/api';
var TOKEN = localStorage.getItem('mlbb_admin_token') || '';
var allOrders = [];
var currentFilter = 'all';
var editingPkgId = null;

function authHeaders() {
  return { 'Authorization': 'Bearer ' + TOKEN, 'Content-Type': 'application/json' };
}
function statusBadge(s) {
  var map = { pending:'badge-pending', processing:'badge-processing', delivered:'badge-delivered', failed:'badge-failed' };
  return '<span class="badge ' + (map[s]||'') + '">' + s + '</span>';
}
function timeAgo(dt) {
  var d = new Date(dt), now = new Date(), m = Math.floor((now - d) / 60000);
  if (m < 1) return 'just now';
  if (m < 60) return m + 'm ago';
  var h = Math.floor(m / 60);
  if (h < 24) return h + 'h ago';
  return d.toLocaleDateString();
}
function showToast(msg, isError) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.className = 'toast show' + (isError ? ' error' : '');
  setTimeout(function(){ t.className = 'toast'; }, 3000);
}
function orderActionBtns(order) {
  var btns = '';
  if (order.status === 'pending')   btns += '<button class="btn-sm btn-process" data-id="' + order.id + '" data-status="processing">Processing</button>';
  if (order.status !== 'delivered') btns += '<button class="btn-sm btn-deliver" data-id="' + order.id + '" data-status="delivered">Delivered</button>';
  if (order.status !== 'failed')    btns += '<button class="btn-sm btn-fail"    data-id="' + order.id + '" data-status="failed">Failed</button>';
  return '<div class="action-btns">' + btns + '</div>';
}
function doLogin() {
  var email = document.getElementById('loginEmail').value.trim();
  var password = document.getElementById('loginPassword').value;
  document.getElementById('loginErr').textContent = '';
  fetch(API + '/auth/login', {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: email, password: password })
  })
  .then(function(r){ return r.json().then(function(d){ return {ok:r.ok,d:d}; }); })
  .then(function(res){
    if (!res.ok) { document.getElementById('loginErr').textContent = res.d.error || 'Login failed'; return; }
    if (res.d.user.role !== 'admin') { document.getElementById('loginErr').textContent = 'Not an admin account'; return; }
    TOKEN = res.d.token;
    localStorage.setItem('mlbb_admin_token', TOKEN);
    initApp(res.d.user);
  })
  .catch(function(){ document.getElementById('loginErr').textContent = 'Cannot reach API. Is server running?'; });
}
function initApp(user) {
  document.getElementById('loginScreen').style.display = 'none';
  document.getElementById('appScreen').style.display = 'block';
  document.getElementById('adminName').textContent = user.name || user.email.split('@')[0];
  document.getElementById('adminInitial').textContent = (user.name || user.email)[0].toUpperCase();
  loadDashboard();
  loadPackages();
}
function doLogout() { TOKEN = ''; localStorage.removeItem('mlbb_admin_token'); location.reload(); }
function showPage(name) {
  document.querySelectorAll('.page').forEach(function(p){ p.classList.remove('active'); });
  document.querySelectorAll('.nav-item').forEach(function(n){ n.classList.remove('active'); });
  document.getElementById('page-' + name).classList.add('active');
  document.getElementById('nav-' + name).classList.add('active');
  if (name === 'orders') loadOrders();
  if (name === 'packages') loadPackages();
}
function loadDashboard() {
  fetch(API + '/orders', { headers: authHeaders() })
  .then(function(r){ return r.json(); })
  .then(function(orders){
    allOrders = orders;
    document.getElementById('stat-total').textContent = orders.length;
    document.getElementById('stat-pending').textContent = orders.filter(function(o){ return o.status==='pending'; }).length;
    document.getElementById('stat-delivered').textContent = orders.filter(function(o){ return o.status==='delivered'; }).length;
    var rev = orders.filter(function(o){ return o.status==='delivered'; }).reduce(function(s,o){ return s+o.totalPrice; },0);
    document.getElementById('stat-revenue').textContent = 'Rs' + rev.toFixed(0);
    var tbody = document.getElementById('dashOrdersBody');
    var recent = orders.slice(0,8);
    if (!recent.length) { tbody.innerHTML = '<tr><td colspan="7"><div class="empty-state"><div class="icon">📭</div><p>No orders yet</p></div></td></tr>'; return; }
    tbody.innerHTML = recent.map(function(o){
      return '<tr><td class="order-id">#'+o.id+'</td><td class="game-id">'+o.gameUserId+' / '+o.gameZoneId+'</td><td>'+(o.package?o.package.name:'-')+'</td><td>'+o.paymentMethod+'</td><td>'+statusBadge(o.status)+'</td><td style="color:var(--muted);font-size:0.78rem">'+timeAgo(o.createdAt)+'</td><td>'+orderActionBtns(o)+'</td></tr>';
    }).join('');
  })
  .catch(function(){ showToast('Failed to load orders', true); });
}
function loadOrders() {
  fetch(API + '/orders', { headers: authHeaders() })
  .then(function(r){ return r.json(); })
  .then(function(orders){ allOrders = orders; renderOrders(orders); })
  .catch(function(){ showToast('Failed to load orders', true); });
}
function renderOrders(orders) {
  var filtered = orders;
  if (currentFilter !== 'all') filtered = orders.filter(function(o){ return o.status===currentFilter; });
  var search = document.getElementById('orderSearch') ? document.getElementById('orderSearch').value.toLowerCase() : '';
  if (search) filtered = filtered.filter(function(o){ return o.gameUserId.toLowerCase().indexOf(search)>-1 || o.gameZoneId.toLowerCase().indexOf(search)>-1; });
  var tbody = document.getElementById('allOrdersBody');
  if (!filtered.length) { tbody.innerHTML = '<tr><td colspan="10"><div class="empty-state"><div class="icon">📭</div><p>No orders found</p></div></td></tr>'; return; }
  tbody.innerHTML = filtered.map(function(o){
    var receipt = o.receiptPath ? '<a class="receipt-link" href="http://localhost:4000/uploads/'+o.receiptPath+'" target="_blank">View</a>' : '<span class="no-receipt">None</span>';
    return '<tr><td class="order-id">#'+o.id+'</td><td class="game-id">'+o.gameUserId+'<br><span style="font-size:0.7rem;color:var(--muted)">Zone: '+o.gameZoneId+'</span></td><td>'+(o.package?o.package.name:'-')+'</td><td class="price-cell">Rs'+o.totalPrice+'</td><td>'+o.paymentMethod+'</td><td>'+receipt+'</td><td>'+statusBadge(o.status)+'</td><td><span class="note-text" title="'+(o.note||'')+'">'+( o.note||'-')+'</span></td><td style="color:var(--muted);font-size:0.75rem;white-space:nowrap">'+new Date(o.createdAt).toLocaleDateString()+'</td><td>'+orderActionBtns(o)+'</td></tr>';
  }).join('');
}
function updateStatus(id, status) {
  fetch(API + '/orders/' + id + '/status', { method:'PATCH', headers:authHeaders(), body:JSON.stringify({status:status}) })
  .then(function(r){ return r.json().then(function(d){ return {ok:r.ok,d:d}; }); })
  .then(function(res){
    if (!res.ok) { showToast('Failed to update', true); return; }
    showToast('Order #' + id + ' marked ' + status);
    loadDashboard();
    if (document.getElementById('page-orders').classList.contains('active')) loadOrders();
  })
  .catch(function(){ showToast('Failed', true); });
}
function loadPackages() {
  fetch(API + '/packages')
  .then(function(r){ return r.json(); })
  .then(function(pkgs){
    document.getElementById('pkgGrid').innerHTML = pkgs.map(function(p){
      return '<div class="pkg-card '+(p.active?'':'inactive')+'" id="pkg-'+p.id+'"><div class="pkg-name">'+p.name+'</div><div class="pkg-diamonds">'+p.diamonds+' + '+p.bonus+' bonus</div><div class="pkg-price">Rs'+p.price+'</div><div class="pkg-actions"><button class="btn-edit" data-pkgid="'+p.id+'" data-name="'+p.name+'" data-diamonds="'+p.diamonds+'" data-bonus="'+p.bonus+'" data-price="'+p.price+'">Edit</button><button class="btn-toggle '+(p.active?'':'activate')+'" data-pkgid="'+p.id+'" data-active="'+p.active+'">'+(p.active?'Deactivate':'Activate')+'</button></div></div>';
    }).join('');
  })
  .catch(function(){ showToast('Failed to load packages', true); });
}
function openAddPackage() {
  editingPkgId = null;
  document.getElementById('modalTitle').textContent = 'Add Package';
  ['pkgName','pkgDiamonds','pkgPrice'].forEach(function(id){ document.getElementById(id).value=''; });
  document.getElementById('pkgBonus').value = '0';
  document.getElementById('modalMsg').textContent = '';
  document.getElementById('pkgModal').classList.add('open');
}
function openEditPackage(id,name,diamonds,bonus,price) {
  editingPkgId = id;
  document.getElementById('modalTitle').textContent = 'Edit Package';
  document.getElementById('pkgName').value = name;
  document.getElementById('pkgDiamonds').value = diamonds;
  document.getElementById('pkgBonus').value = bonus;
  document.getElementById('pkgPrice').value = price;
  document.getElementById('modalMsg').textContent = '';
  document.getElementById('pkgModal').classList.add('open');
}
function closeModal() { document.getElementById('pkgModal').classList.remove('open'); }
function savePackage() {
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
}
function togglePackage(id,currentlyActive) {
  fetch(API+'/packages/'+id, { method:'PATCH', headers:authHeaders(), body:JSON.stringify({active:!currentlyActive}) })
  .then(function(r){ return r.json(); })
  .then(function(){ showToast(currentlyActive?'Deactivated':'Activated'); loadPackages(); })
  .catch(function(){ showToast('Failed', true); });
}
document.getElementById('loginBtn').addEventListener('click', doLogin);
document.getElementById('loginPassword').addEventListener('keydown', function(e){ if(e.key==='Enter') doLogin(); });
document.getElementById('logoutBtn').addEventListener('click', doLogout);
document.getElementById('dashRefreshBtn').addEventListener('click', loadDashboard);
document.getElementById('ordersRefreshBtn').addEventListener('click', loadOrders);
document.getElementById('addPkgBtn').addEventListener('click', openAddPackage);
document.getElementById('modalCancelBtn').addEventListener('click', closeModal);
document.getElementById('modalSaveBtn').addEventListener('click', savePackage);
document.getElementById('orderSearch').addEventListener('input', function(){ renderOrders(allOrders); });
document.getElementById('nav-dashboard').addEventListener('click', function(){ showPage('dashboard'); });
document.getElementById('nav-orders').addEventListener('click', function(){ showPage('orders'); });
document.getElementById('nav-packages').addEventListener('click', function(){ showPage('packages'); });
document.querySelectorAll('.filter-btn').forEach(function(btn){
  btn.addEventListener('click', function(){
    currentFilter = this.dataset.filter;
    document.querySelectorAll('.filter-btn').forEach(function(b){ b.classList.remove('active'); });
    this.classList.add('active');
    renderOrders(allOrders);
  });
});
document.getElementById('dashOrdersBody').addEventListener('click', function(e){ var b=e.target.closest('[data-status]'); if(b) updateStatus(b.dataset.id, b.dataset.status); });
document.getElementById('allOrdersBody').addEventListener('click', function(e){ var b=e.target.closest('[data-status]'); if(b) updateStatus(b.dataset.id, b.dataset.status); });
document.getElementById('pkgGrid').addEventListener('click', function(e){
  var eb=e.target.closest('.btn-edit'), tb=e.target.closest('.btn-toggle');
  if(eb) openEditPackage(eb.dataset.pkgid, eb.dataset.name, eb.dataset.diamonds, eb.dataset.bonus, eb.dataset.price);
  if(tb) togglePackage(tb.dataset.pkgid, tb.dataset.active==='true');
});
window.addEventListener('load', function(){
  if (!TOKEN) return;
  fetch(API + '/orders', { headers: authHeaders() })
  .then(function(r){
    if (r.ok) { try { var d=JSON.parse(atob(TOKEN.split('.')[1])); initApp({name:d.email.split('@')[0],email:d.email}); } catch(e){ localStorage.removeItem('mlbb_admin_token'); } }
    else { localStorage.removeItem('mlbb_admin_token'); }
  }).catch(function(){ localStorage.removeItem('mlbb_admin_token'); });
});
</script>
</body>
</html>
"@

[System.IO.File]::WriteAllText(
    (Join-Path (Get-Location).Path "admin\index.html"),
    $html,
    [System.Text.Encoding]::UTF8
)

Write-Host "      admin\index.html written." -ForegroundColor Green

Write-Host "[3/3] Done!" -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Phase 3 Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  File created: D:\MLBB\admin\index.html" -ForegroundColor White
Write-Host ""
Write-Host "  HOW TO USE:" -ForegroundColor Cyan
Write-Host "  1. Keep backend running:  cd D:\MLBB\backend && npm run dev" -ForegroundColor Gray
Write-Host "  2. Open in browser:       D:\MLBB\admin\index.html" -ForegroundColor Gray
Write-Host "  3. Login with:" -ForegroundColor Gray
Write-Host "     Email:    admin@mlbbtopup.com" -ForegroundColor DarkGray
Write-Host "     Password: Admin@1234" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Ready for Phase 4 when confirmed working!" -ForegroundColor Cyan
Write-Host ""
