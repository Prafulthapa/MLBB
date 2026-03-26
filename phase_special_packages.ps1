# ============================================================
#  MLBB TopUp Nepal - Special Packages UI
#  Adds Weekly Diamond Pass + Twilight Pass sections
#  Run from: D:\MLBB>  .\phase_special_packages.ps1
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Adding Weekly Pass + Twilight Pass UI" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ── STEP 1: Add special packages to DB via seed patch ───────
Write-Host "[1/2] Adding special packages to database..." -ForegroundColor Yellow

$seedPatch = @"
// Run: node add_special_packages.js
require('dotenv').config();
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
}
main().catch(console.error).finally(() => prisma.$disconnect());
"@

$stream = [System.IO.StreamWriter]::new(
    (Join-Path (Get-Location).Path "backend\add_special_packages.js"),
    $false,
    (New-Object System.Text.UTF8Encoding $false)
)
$stream.Write($seedPatch)
$stream.Close()

# Run the seed
Push-Location "backend"
node add_special_packages.js
Pop-Location
Write-Host "      Special packages added to DB." -ForegroundColor Green

# ── STEP 2: Rewrite mlbb-topup.html with special sections ───
Write-Host "[2/2] Updating mlbb-topup.html with special package sections..." -ForegroundColor Yellow

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MLBB Top Up Nepal - Cheapest Diamonds</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Exo+2:wght@300;400;500;600;700;900&family=Orbitron:wght@400;700;900&display=swap" rel="stylesheet">
<style>
:root{--gold:#FFD700;--gold-dark:#C8A800;--blue:#00C8FF;--red:#FF2D55;--green:#00E676;--bg-dark:#080C14;--bg-card:#0E1422;--bg-card2:#121929;--border:rgba(255,215,0,0.18);--text:#E8EAF6;--text-muted:#7B86A0;}
*{margin:0;padding:0;box-sizing:border-box;}
html{scroll-behavior:smooth;}
body{font-family:'Exo 2',sans-serif;background:var(--bg-dark);color:var(--text);min-height:100vh;overflow-x:hidden;}
body::before{content:'';position:fixed;inset:0;background:radial-gradient(ellipse 80% 50% at 10% 10%,rgba(0,71,255,0.12) 0%,transparent 60%),radial-gradient(ellipse 60% 40% at 90% 80%,rgba(0,200,255,0.08) 0%,transparent 60%);pointer-events:none;z-index:0;}

/* BANNER */
.banner-wrap{position:relative;z-index:1;width:100%;max-height:320px;overflow:hidden;}
.banner-wrap img{width:100%;max-height:320px;object-fit:cover;object-position:center top;display:block;}
.banner-overlay{position:absolute;inset:0;background:linear-gradient(180deg,rgba(8,12,20,0) 30%,rgba(8,12,20,0.95) 100%);}

/* HERO */
.hero{position:relative;z-index:1;text-align:center;padding:32px 20px 28px;border-bottom:1px solid var(--border);background:linear-gradient(180deg,rgba(0,71,255,0.06) 0%,transparent 100%);}
.logo-wrap{display:inline-flex;align-items:center;gap:16px;margin-bottom:8px;}
.logo-icon{width:64px;height:64px;border-radius:16px;background:linear-gradient(135deg,#FFD700,#FF6B00);display:flex;align-items:center;justify-content:center;font-size:32px;box-shadow:0 0 30px rgba(255,215,0,0.4);animation:pulse-logo 3s ease-in-out infinite;}
@keyframes pulse-logo{0%,100%{box-shadow:0 0 30px rgba(255,215,0,0.4),0 0 60px rgba(255,107,0,0.2);}50%{box-shadow:0 0 50px rgba(255,215,0,0.7),0 0 100px rgba(255,107,0,0.4);}}
.logo-text{font-family:'Orbitron',sans-serif;font-weight:900;font-size:2rem;background:linear-gradient(90deg,#FFD700,#FF6B00,#FFD700);background-size:200%;-webkit-background-clip:text;-webkit-text-fill-color:transparent;animation:shimmer 3s linear infinite;letter-spacing:2px;}
@keyframes shimmer{0%{background-position:0% 50%;}100%{background-position:200% 50%;}}
.hero-sub{font-family:'Rajdhani',sans-serif;font-size:1rem;color:var(--text-muted);letter-spacing:3px;text-transform:uppercase;}
.hero-badge{display:inline-flex;align-items:center;gap:8px;background:rgba(0,200,255,0.1);border:1px solid rgba(0,200,255,0.3);border-radius:50px;padding:4px 16px;font-size:0.8rem;color:var(--blue);font-family:'Rajdhani',sans-serif;font-weight:600;letter-spacing:1px;margin-top:8px;}
.hero-badge::before{content:'';width:8px;height:8px;border-radius:50%;background:var(--blue);animation:blink 1.5s infinite;}
@keyframes blink{0%,100%{opacity:1;}50%{opacity:0.2;}}

.container{max-width:960px;margin:0 auto;padding:0 20px 60px;position:relative;z-index:1;}

/* SECTION HEADERS */
.section-header{display:flex;align-items:center;gap:14px;margin:40px 0 24px;}
.step-badge{width:36px;height:36px;border-radius:50%;background:linear-gradient(135deg,var(--gold),var(--gold-dark));display:flex;align-items:center;justify-content:center;font-family:'Orbitron',sans-serif;font-weight:900;font-size:0.95rem;color:#000;flex-shrink:0;box-shadow:0 0 20px rgba(255,215,0,0.4);}
.section-title{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1.3rem;letter-spacing:2px;text-transform:uppercase;color:#fff;}
.section-line{flex:1;height:1px;background:linear-gradient(90deg,var(--border),transparent);}

/* GAME ID */
.game-id-card{background:var(--bg-card);border:1px solid var(--border);border-radius:16px;padding:28px;position:relative;overflow:hidden;}
.game-id-card::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,var(--gold),transparent);}
.game-id-grid{display:grid;grid-template-columns:1fr 1fr;gap:20px;}
@media(max-width:560px){.game-id-grid{grid-template-columns:1fr;}}
.input-group label{display:block;font-family:'Rajdhani',sans-serif;font-size:0.8rem;font-weight:600;letter-spacing:2px;text-transform:uppercase;color:var(--text-muted);margin-bottom:8px;}
.input-group input{width:100%;background:rgba(255,255,255,0.04);border:1px solid rgba(255,215,0,0.2);border-radius:10px;padding:14px 18px;font-family:'Exo 2',sans-serif;font-size:1rem;color:#fff;outline:none;transition:all 0.3s;}
.input-group input::placeholder{color:rgba(255,255,255,0.2);}
.input-group input:focus{border-color:var(--gold);background:rgba(255,215,0,0.04);box-shadow:0 0 20px rgba(255,215,0,0.1);}
.id-hint{margin-top:16px;padding:12px 16px;background:rgba(0,200,255,0.06);border-left:3px solid var(--blue);border-radius:0 8px 8px 0;font-size:0.82rem;color:var(--text-muted);line-height:1.5;}
.id-hint strong{color:var(--blue);}

/* DIAMOND GRID */
.diamond-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px;}
.diamond-card{background:var(--bg-card);border:1.5px solid rgba(255,215,0,0.1);border-radius:14px;padding:14px;cursor:pointer;transition:all 0.25s;position:relative;overflow:hidden;}
.diamond-card::after{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,215,0,0.06),transparent);opacity:0;transition:opacity 0.25s;}
.diamond-card:hover{border-color:rgba(255,215,0,0.5);transform:translateY(-3px);box-shadow:0 8px 30px rgba(255,215,0,0.15);}
.diamond-card:hover::after,.diamond-card.selected::after{opacity:1;}
.diamond-card.selected{border-color:var(--gold);box-shadow:0 0 0 2px rgba(255,215,0,0.3),0 8px 30px rgba(255,215,0,0.2);background:rgba(255,215,0,0.06);}
.card-top{display:flex;align-items:center;gap:10px;margin-bottom:10px;}
.diamond-name{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1rem;color:#fff;line-height:1.2;}
.diamond-bonus{font-size:0.72rem;color:var(--gold);margin-top:2px;}
.card-bottom{display:flex;align-items:flex-end;justify-content:space-between;}
.price-new{font-family:'Orbitron',sans-serif;font-size:0.95rem;font-weight:700;color:var(--gold);}
.discount-tag{background:linear-gradient(135deg,#FF2D55,#FF6B00);border-radius:6px;padding:2px 7px;font-size:0.7rem;font-weight:700;color:#fff;font-family:'Rajdhani',sans-serif;}
.selected-check{position:absolute;top:10px;right:10px;width:22px;height:22px;border-radius:50%;background:var(--gold);display:none;align-items:center;justify-content:center;font-size:11px;color:#000;font-weight:900;z-index:2;}
.diamond-card.selected .selected-check{display:flex;}
.loading-grid{text-align:center;padding:40px;color:var(--text-muted);font-family:'Rajdhani',sans-serif;letter-spacing:2px;}
.diamond-svg{width:44px;height:44px;flex-shrink:0;}

/* ── SPECIAL OFFERS SECTION ── */
.special-section{margin-top:32px;}
.special-section-label{display:flex;align-items:center;gap:10px;margin-bottom:16px;}
.special-section-label .fire{font-size:20px;}
.special-section-label h3{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1.1rem;letter-spacing:1px;color:#fff;text-transform:uppercase;}

/* Weekly pass grid */
.weekly-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px;}

/* Special card — used for both weekly variants and twilight */
.special-card{background:var(--bg-card);border:1.5px solid rgba(255,215,0,0.1);border-radius:14px;padding:14px;cursor:pointer;transition:all 0.25s;position:relative;overflow:hidden;}
.special-card::after{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,215,0,0.06),transparent);opacity:0;transition:opacity 0.25s;}
.special-card:hover{border-color:rgba(255,215,0,0.5);transform:translateY(-3px);box-shadow:0 8px 30px rgba(255,215,0,0.15);}
.special-card:hover::after,.special-card.selected::after{opacity:1;}
.special-card.selected{border-color:var(--gold);box-shadow:0 0 0 2px rgba(255,215,0,0.3),0 8px 30px rgba(255,215,0,0.2);background:rgba(255,215,0,0.06);}
.special-card .selected-check{position:absolute;top:10px;right:10px;width:22px;height:22px;border-radius:50%;background:var(--gold);display:none;align-items:center;justify-content:center;font-size:11px;color:#000;font-weight:900;z-index:2;}
.special-card.selected .selected-check{display:flex;}

.special-img-wrap{position:relative;margin-bottom:10px;}
.special-img-wrap img{width:100%;height:80px;object-fit:cover;border-radius:8px;display:block;}
.special-badge{position:absolute;top:6px;left:6px;background:linear-gradient(135deg,#FF2D55,#FF6B00);border-radius:5px;padding:2px 8px;font-size:0.65rem;font-weight:700;color:#fff;font-family:'Rajdhani',sans-serif;letter-spacing:1px;text-transform:uppercase;}
.special-name{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:0.95rem;color:#fff;margin-bottom:8px;line-height:1.3;}
.special-pricing{display:flex;align-items:center;justify-content:space-between;}
.special-price{font-family:'Orbitron',sans-serif;font-size:0.95rem;font-weight:700;color:var(--gold);}
.special-label-from{font-size:0.68rem;color:var(--text-muted);font-family:'Rajdhani',sans-serif;letter-spacing:1px;text-transform:uppercase;margin-bottom:2px;}
.special-discount{background:rgba(255,45,85,0.15);border:1px solid rgba(255,45,85,0.3);border-radius:5px;padding:1px 6px;font-size:0.7rem;font-weight:700;color:var(--red);font-family:'Rajdhani',sans-serif;}

/* Twilight pass — single wide card */
.twilight-card{background:var(--bg-card);border:1.5px solid rgba(255,215,0,0.1);border-radius:14px;padding:16px;cursor:pointer;transition:all 0.25s;position:relative;overflow:hidden;display:flex;align-items:center;gap:16px;max-width:400px;}
.twilight-card::after{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,215,0,0.06),transparent);opacity:0;transition:opacity 0.25s;}
.twilight-card:hover{border-color:rgba(255,215,0,0.5);transform:translateY(-3px);box-shadow:0 8px 30px rgba(255,215,0,0.15);}
.twilight-card:hover::after,.twilight-card.selected::after{opacity:1;}
.twilight-card.selected{border-color:var(--gold);box-shadow:0 0 0 2px rgba(255,215,0,0.3),0 8px 30px rgba(255,215,0,0.2);background:rgba(255,215,0,0.06);}
.twilight-card .selected-check{position:absolute;top:10px;right:10px;width:22px;height:22px;border-radius:50%;background:var(--gold);display:none;align-items:center;justify-content:center;font-size:11px;color:#000;font-weight:900;z-index:2;}
.twilight-card.selected .selected-check{display:flex;}
.twilight-img{width:72px;height:72px;border-radius:10px;object-fit:cover;flex-shrink:0;}
.twilight-info{flex:1;}
.twilight-name{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1rem;color:#fff;margin-bottom:6px;}
.twilight-from{font-size:0.68rem;color:var(--text-muted);font-family:'Rajdhani',sans-serif;letter-spacing:1px;text-transform:uppercase;margin-bottom:2px;}
.twilight-pricing{display:flex;align-items:center;gap:10px;}
.twilight-price{font-family:'Orbitron',sans-serif;font-size:1rem;font-weight:700;color:var(--gold);}
.twilight-discount{background:rgba(255,45,85,0.15);border:1px solid rgba(255,45,85,0.3);border-radius:5px;padding:1px 7px;font-size:0.72rem;font-weight:700;color:var(--red);font-family:'Rajdhani',sans-serif;}

/* PAYMENT */
.payment-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:20px;}
@media(max-width:480px){.payment-grid{grid-template-columns:1fr;}}
.payment-card{background:var(--bg-card);border:1.5px solid rgba(255,255,255,0.1);border-radius:14px;padding:20px;cursor:pointer;transition:all 0.25s;display:flex;align-items:center;gap:14px;}
.payment-card:hover{border-color:rgba(0,200,255,0.4);box-shadow:0 0 20px rgba(0,200,255,0.1);}
.payment-card.selected{border-color:var(--blue);background:rgba(0,200,255,0.06);box-shadow:0 0 30px rgba(0,200,255,0.15);}
.pay-logo{width:52px;height:52px;border-radius:12px;display:flex;align-items:center;justify-content:center;overflow:hidden;flex-shrink:0;}
.pay-logo img{width:100%;height:100%;object-fit:cover;border-radius:12px;}
.pay-bank-bg{background:linear-gradient(135deg,#1a73e8,#0d47a1);font-size:26px;}
.pay-info h4{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1.05rem;color:#fff;}
.pay-info p{font-size:0.78rem;color:var(--text-muted);margin-top:2px;}
.pay-detail{display:none;background:var(--bg-card2);border:1px solid var(--border);border-radius:14px;padding:22px 24px;margin-top:6px;animation:fadeIn 0.3s ease;}
.pay-detail.visible{display:block;}
@keyframes fadeIn{from{opacity:0;transform:translateY(8px);}to{opacity:1;transform:none;}}
.pay-detail h4{font-family:'Rajdhani',sans-serif;font-weight:700;letter-spacing:1px;margin-bottom:14px;color:var(--gold);font-size:1rem;text-transform:uppercase;}
.pay-row{display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid rgba(255,255,255,0.05);font-size:0.9rem;}
.pay-row:last-child{border-bottom:none;}
.pay-row span:first-child{color:var(--text-muted);}
.pay-row span:last-child{color:#fff;font-weight:600;}
.copy-btn{background:rgba(0,200,255,0.1);border:1px solid rgba(0,200,255,0.3);border-radius:6px;padding:2px 10px;font-size:0.72rem;color:var(--blue);cursor:pointer;font-family:'Rajdhani',sans-serif;font-weight:600;transition:all 0.2s;}
.copy-btn:hover{background:rgba(0,200,255,0.2);}
.pay-note{margin-top:12px;padding:10px 14px;background:rgba(255,215,0,0.06);border-left:3px solid var(--gold);border-radius:0 8px 8px 0;font-size:0.82rem;color:#bbb;line-height:1.5;}
.receipt-upload{margin-top:14px;}
.receipt-upload label{display:block;font-family:'Rajdhani',sans-serif;font-size:0.78rem;font-weight:600;letter-spacing:2px;text-transform:uppercase;color:var(--text-muted);margin-bottom:8px;}
.receipt-upload input[type=file]{width:100%;background:rgba(255,255,255,0.04);border:1px dashed rgba(255,215,0,0.3);border-radius:10px;padding:12px 16px;color:var(--text-muted);font-size:0.85rem;cursor:pointer;outline:none;}
.receipt-upload input[type=file]:hover{border-color:var(--gold);}

/* ORDER */
.order-section{margin-top:28px;text-align:center;}
.order-summary{background:var(--bg-card);border:1px solid var(--border);border-radius:14px;padding:18px 24px;display:flex;align-items:center;justify-content:space-between;margin-bottom:16px;flex-wrap:wrap;gap:12px;}
.order-info{text-align:left;}
.order-info .label{font-size:0.78rem;color:var(--text-muted);font-family:'Rajdhani',sans-serif;letter-spacing:1px;text-transform:uppercase;}
.order-info .value{font-family:'Orbitron',sans-serif;font-size:1.1rem;color:var(--gold);font-weight:700;margin-top:3px;}
.order-btn{background:linear-gradient(135deg,#FFD700,#FF6B00);border:none;border-radius:50px;padding:16px 48px;font-family:'Orbitron',sans-serif;font-weight:900;font-size:1rem;color:#000;cursor:pointer;letter-spacing:2px;text-transform:uppercase;transition:all 0.3s;box-shadow:0 4px 30px rgba(255,215,0,0.35);}
.order-btn:hover{transform:translateY(-2px);box-shadow:0 8px 40px rgba(255,215,0,0.5);}
.order-btn:disabled{opacity:0.5;cursor:not-allowed;transform:none;}
.success-banner{display:none;background:rgba(0,230,118,0.1);border:1px solid rgba(0,230,118,0.4);border-radius:14px;padding:20px 24px;margin-top:16px;text-align:center;}
.success-banner.show{display:block;animation:fadeIn 0.4s ease;}
.success-banner h3{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1.1rem;color:#00E676;letter-spacing:1px;margin-bottom:6px;}
.success-banner p{font-size:0.85rem;color:var(--text-muted);line-height:1.6;}
.success-banner .order-ref{font-family:'Orbitron',sans-serif;font-size:1.2rem;color:#00E676;font-weight:700;margin:8px 0;}

/* PRICE TABLE */
.price-table-wrap{background:var(--bg-card);border:1px solid var(--border);border-radius:16px;overflow:hidden;}
.price-table-header{background:linear-gradient(90deg,rgba(255,215,0,0.12),rgba(255,107,0,0.08));padding:18px 24px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid var(--border);}
.price-table-header h3{font-family:'Orbitron',sans-serif;font-weight:700;font-size:1rem;color:var(--gold);letter-spacing:1px;}
.price-table-header span{font-size:0.78rem;color:var(--text-muted);}
table{width:100%;border-collapse:collapse;}
thead tr th{padding:13px 20px;font-family:'Rajdhani',sans-serif;font-weight:700;font-size:0.78rem;letter-spacing:2px;text-transform:uppercase;color:var(--text-muted);text-align:left;border-bottom:1px solid rgba(255,255,255,0.06);background:rgba(0,0,0,0.2);}
tbody tr{transition:background 0.2s;border-bottom:1px solid rgba(255,255,255,0.04);}
tbody tr:hover{background:rgba(255,215,0,0.03);}
tbody tr:last-child{border-bottom:none;}
tbody tr td{padding:11px 20px;font-size:0.9rem;}
tbody tr td:first-child{color:#dde;}
tbody tr td:last-child{font-family:'Orbitron',sans-serif;font-size:0.85rem;font-weight:700;color:var(--gold);text-align:right;}
.table-scroll{max-height:400px;overflow-y:auto;}
.table-scroll::-webkit-scrollbar{width:4px;}
.table-scroll::-webkit-scrollbar-thumb{background:rgba(255,215,0,0.3);border-radius:4px;}

/* CONTACT */
.contact-section{margin-top:48px;text-align:center;padding:32px 20px;background:var(--bg-card);border:1px solid var(--border);border-radius:20px;position:relative;overflow:hidden;}
.contact-section::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse at center bottom,rgba(255,215,0,0.06),transparent 70%);}
.contact-section h3{font-family:'Rajdhani',sans-serif;font-weight:700;font-size:1.1rem;letter-spacing:2px;text-transform:uppercase;color:var(--text-muted);margin-bottom:16px;position:relative;}
.contact-btns{display:flex;justify-content:center;gap:14px;flex-wrap:wrap;position:relative;}
.contact-btn{display:inline-flex;align-items:center;gap:10px;padding:12px 24px;border-radius:50px;font-family:'Rajdhani',sans-serif;font-weight:700;font-size:0.95rem;letter-spacing:1px;text-decoration:none;transition:all 0.3s;}
.contact-btn img{width:22px;height:22px;object-fit:contain;border-radius:4px;}
.btn-whatsapp{background:rgba(37,211,102,0.12);border:1.5px solid rgba(37,211,102,0.4);color:#25D366;}
.btn-whatsapp:hover{background:rgba(37,211,102,0.22);transform:translateY(-2px);}
.btn-telegram{background:rgba(0,136,204,0.12);border:1.5px solid rgba(0,136,204,0.4);color:#0088cc;}
.btn-telegram:hover{background:rgba(0,136,204,0.22);transform:translateY(-2px);}
.footer-note{margin-top:32px;text-align:center;font-size:0.78rem;color:var(--text-muted);padding-bottom:20px;}
.particles{position:fixed;inset:0;pointer-events:none;z-index:0;overflow:hidden;}
.particle{position:absolute;width:2px;height:2px;background:var(--gold);border-radius:50%;opacity:0;animation:float-up linear infinite;}
@keyframes float-up{0%{transform:translateY(100vh) scale(0);opacity:0;}10%{opacity:0.6;}90%{opacity:0.2;}100%{transform:translateY(-10vh) scale(1);opacity:0;}}
.toast{position:fixed;bottom:24px;left:50%;transform:translateX(-50%) translateY(80px);background:rgba(255,215,0,0.15);border:1px solid var(--gold);border-radius:50px;padding:12px 24px;font-family:'Rajdhani',sans-serif;font-weight:600;color:var(--gold);font-size:0.9rem;z-index:999;transition:transform 0.4s cubic-bezier(0.175,0.885,0.32,1.275);backdrop-filter:blur(12px);}
.toast.show{transform:translateX(-50%) translateY(0);}
.toast.error{background:rgba(255,45,85,0.15);border-color:#FF2D55;color:#FF2D55;}
</style>
</head>
<body>

<div class="particles" id="particles"></div>
<div class="toast" id="toast"></div>

<!-- BANNER -->
<div class="banner-wrap">
  <img src="https://drive.google.com/uc?export=view&id=1SQQHXJix2SMalQsY7HEGezalDBCtBIHa" alt="MLBB Top Up Nepal" onerror="this.parentElement.style.display='none'" />
  <div class="banner-overlay"></div>
</div>

<!-- HERO -->
<div class="hero">
  <div class="logo-wrap">
    <div class="logo-icon">&#x1F48E;</div>
    <div>
      <div class="logo-text">MLBB TOP UP</div>
      <div class="hero-sub">Nepal's #1 Diamond Store</div>
    </div>
  </div>
  <br>
  <div class="hero-badge">LIVE &bull; Instant Delivery &bull; Best Price Guaranteed</div>
</div>

<div class="container">

  <!-- STEP 1 -->
  <div class="section-header">
    <div class="step-badge">1</div>
    <div class="section-title">Enter Game ID</div>
    <div class="section-line"></div>
  </div>
  <div class="game-id-card">
    <div class="game-id-grid">
      <div class="input-group"><label>User ID</label><input type="text" id="userId" placeholder="e.g. 123456789" /></div>
      <div class="input-group"><label>Zone ID</label><input type="text" id="zoneId" placeholder="e.g. 1234" /></div>
    </div>
    <div class="id-hint"><strong>How to find your ID?</strong> Open MLBB &rarr; Tap your profile picture &rarr; Your User ID and Zone ID are shown below your name.</div>
  </div>

  <!-- STEP 2 -->
  <div class="section-header">
    <div class="step-badge">2</div>
    <div class="section-title">Choose Diamonds</div>
    <div class="section-line"></div>
  </div>
  <div class="diamond-grid" id="diamondGrid">
    <div class="loading-grid">Loading packages...</div>
  </div>

  <!-- WEEKLY DIAMOND PASS (rendered by JS) -->
  <div id="weeklySection" style="display:none;">
    <div class="special-section">
      <div class="special-section-label">
        <span class="fire">&#x1F525;</span>
        <h3>Weekly Diamond Pass</h3>
      </div>
      <div class="weekly-grid" id="weeklyGrid"></div>
    </div>
  </div>

  <!-- TWILIGHT PASS (rendered by JS) -->
  <div id="twilightSection" style="display:none;">
    <div class="special-section">
      <div class="special-section-label">
        <span class="fire">&#x2728;</span>
        <h3>Twilight Pass</h3>
      </div>
      <div id="twilightGrid"></div>
    </div>
  </div>

  <!-- STEP 3 -->
  <div class="section-header">
    <div class="step-badge">3</div>
    <div class="section-title">Select Payment</div>
    <div class="section-line"></div>
  </div>

  <div class="payment-grid">
    <div class="payment-card" id="pay-esewa">
      <div class="pay-logo">
        <img src="https://drive.google.com/uc?export=view&id=1FyJmemVY-k1DykLs46slcMqj_9Js3R9S" alt="eSewa" onerror="this.parentElement.innerHTML='<span style=font-size:28px>E</span>'" />
      </div>
      <div class="pay-info"><h4>eSewa</h4><p>Instant &bull; Recommended</p></div>
    </div>
    <div class="payment-card" id="pay-bank">
      <div class="pay-logo pay-bank-bg">&#x1F3E6;</div>
      <div class="pay-info"><h4>Bank Transfer</h4><p>All banks accepted</p></div>
    </div>
  </div>

  <div class="pay-detail" id="detail-esewa">
    <h4>eSewa Payment Details</h4>
    <div class="pay-row"><span>eSewa ID</span><span>9702764422 <button class="copy-btn" id="copyEsewa">Copy</button></span></div>
    <div class="pay-row"><span>Account Name</span><span>MLBB TopUp Nepal</span></div>
    <div class="pay-note">After payment, upload your receipt screenshot below. Diamonds delivered within <strong>5 minutes</strong>.</div>
    <div class="receipt-upload"><label>Upload Receipt Screenshot</label><input type="file" id="receiptEsewa" accept="image/*" /></div>
  </div>

  <div class="pay-detail" id="detail-bank">
    <h4>Bank Transfer Details</h4>
    <div class="pay-row"><span>Bank</span><span>Global IME</span></div>
    <div class="pay-row"><span>Account No.</span><span>28407010034283 <button class="copy-btn" id="copyBank">Copy</button></span></div>
    <div class="pay-row"><span>Account Name</span><span>MLBB TopUp Nepal</span></div>
    <div class="pay-row"><span>Branch</span><span>Kathmandu</span></div>
    <div class="pay-note">Upload bank voucher below. Diamonds delivered within <strong>15 minutes</strong> of confirmation.</div>
    <div class="receipt-upload"><label>Upload Receipt / Voucher</label><input type="file" id="receiptBank" accept="image/*" /></div>
  </div>

  <!-- ORDER -->
  <div class="order-section">
    <div class="order-summary">
      <div class="order-info"><div class="label">Selected Package</div><div class="value" id="selectedPackage">Select a package</div></div>
      <div class="order-info"><div class="label">Total Price</div><div class="value" id="selectedPrice">Rs --</div></div>
      <div class="order-info"><div class="label">Payment</div><div class="value" id="selectedPayment" style="color:var(--blue)">Select payment</div></div>
    </div>
    <button class="order-btn" id="orderBtn">&#x26A1; PLACE ORDER NOW</button>
    <div class="success-banner" id="successBanner">
      <h3>Order Placed Successfully!</h3>
      <div class="order-ref" id="orderRef">#000</div>
      <p>Your order has been received. We will deliver your diamonds shortly.<br>Save your order number for tracking.</p>
    </div>
  </div>

  <!-- PRICE TABLE -->
  <div class="section-header" style="margin-top:48px;">
    <div class="step-badge" style="background:linear-gradient(135deg,var(--blue),#0047FF);color:#fff;">&#x1F4CB;</div>
    <div class="section-title">Full Price List</div>
    <div class="section-line"></div>
  </div>
  <div class="price-table-wrap">
    <div class="price-table-header">
      <h3>Mobile Legends Price List</h3>
      <span id="priceDate">Loading...</span>
    </div>
    <div class="table-scroll">
      <table>
        <thead><tr><th>Package</th><th style="text-align:right">Price (NPR)</th></tr></thead>
        <tbody id="priceTableBody"></tbody>
      </table>
    </div>
  </div>

  <!-- CONTACT -->
  <div class="contact-section" style="margin-top:40px;">
    <h3>Get Help &amp; Order Support</h3>
    <div class="contact-btns">
      <a href="https://wa.me/9779702764422" class="contact-btn btn-whatsapp" target="_blank">
        <img src="https://drive.google.com/uc?export=view&id=1nkGkrdrx86nOl4YxLa_3FfHiqet7-DiU" alt="WhatsApp" onerror="this.outerHTML=''" />
        WhatsApp Us
      </a>
      <a href="https://t.me/yourtelegram" class="contact-btn btn-telegram" target="_blank">
        <img src="https://drive.google.com/uc?export=view&id=1I-uxk6wWbrYu7iVz5fi3fkvSs4HdOdPl" alt="Telegram" onerror="this.outerHTML=''" />
        Telegram
      </a>
    </div>
  </div>

  <div class="footer-note">
    &copy; 2026 MLBB TopUp Nepal &nbsp;&bull;&nbsp; Instant Delivery &nbsp;&bull;&nbsp; 24/7 Support<br>
    <span style="color:rgba(255,215,0,0.3)">Prices subject to change. Not affiliated with Moonton.</span>
  </div>

</div>

<script>
var API = window.location.hostname === 'localhost' && window.location.port === '' ? '/api' : (window.location.port === '4000' ? 'http://localhost:4000/api' : '/api');
var selectedPackage = null;
var selectedPay = null;

// Image URLs for special packages
var WEEKLY_IMG   = 'https://i.imgur.com/wpjoOwV.jpeg';
var TWILIGHT_IMG = 'https://i.imgur.com/Lhj3x20.jpeg';

function getDiamondSVG() {
  return '<svg class="diamond-svg" viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="dg" x1="0" y1="0" x2="44" y2="44" gradientUnits="userSpaceOnUse"><stop offset="0%" stop-color="#00C8FF"/><stop offset="50%" stop-color="#4488FF"/><stop offset="100%" stop-color="#0022CC"/></linearGradient><linearGradient id="dg2" x1="0" y1="0" x2="44" y2="44" gradientUnits="userSpaceOnUse"><stop offset="0%" stop-color="rgba(255,255,255,0.6)"/><stop offset="100%" stop-color="rgba(255,255,255,0)"/></linearGradient></defs><polygon points="22,3 38,16 22,41 6,16" fill="url(#dg)" stroke="#00C8FF" stroke-width="0.8"/><polygon points="22,3 38,16 22,20" fill="url(#dg2)" opacity="0.5"/><polygon points="22,3 6,16 22,20" fill="url(#dg2)" opacity="0.2"/><line x1="6" y1="16" x2="38" y2="16" stroke="rgba(255,255,255,0.3)" stroke-width="0.5"/><line x1="22" y1="3" x2="22" y2="41" stroke="rgba(255,255,255,0.2)" stroke-width="0.5"/></svg>';
}

// Detect package category from name
function getPackageType(name) {
  var n = name.toLowerCase();
  if (n.indexOf('weekly pass') > -1) return 'weekly';
  if (n.indexOf('twilight pass') > -1) return 'twilight';
  return 'diamond';
}

// Label for weekly variants e.g. "Weekly Pass 2x" -> "2x Weekly Diamond Pass"
function weeklyLabel(name) {
  var match = name.match(/(\d+)x/i);
  if (match) return match[1] + 'x Weekly Diamond Pass';
  return 'Weekly Diamond Pass';
}

function selectPkg(p) {
  // Deselect all cards across all grids
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

    // ── Diamond grid ──────────────────────────────────
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
        card.addEventListener('click', function(){ selectPkg(p); });
        grid.appendChild(card);
      });
    }

    // ── Weekly Diamond Pass ───────────────────────────
    if (weeklies.length) {
      document.getElementById('weeklySection').style.display = 'block';
      var wgrid = document.getElementById('weeklyGrid');
      wgrid.innerHTML = '';

      // Sort: 1x, 2x, 3x, 4x
      weeklies.sort(function(a,b){
        var am = a.name.match(/(\d+)x/i), bm = b.name.match(/(\d+)x/i);
        return (am ? parseInt(am[1]) : 0) - (bm ? parseInt(bm[1]) : 0);
      });

      weeklies.forEach(function(p) {
        var card = document.createElement('div');
        card.className = 'special-card';
        card.id = 'pkgcard-' + p.id;
        var label = weeklyLabel(p.name);
        card.innerHTML =
          '<div class="selected-check">&#x2713;</div>' +
          '<div class="special-img-wrap">' +
          '<img src="' + WEEKLY_IMG + '" alt="Weekly Pass" />' +
          '<span class="special-badge">Special</span>' +
          '</div>' +
          '<div class="special-name">' + label + '</div>' +
          '<div class="special-label-from">From</div>' +
          '<div class="special-pricing">' +
          '<div class="special-price">Rs' + p.price + '</div>' +
          '<div class="special-discount">-4%</div>' +
          '</div>';
        card.addEventListener('click', function(){ selectPkg(p); });
        wgrid.appendChild(card);
      });
    }

    // ── Twilight Pass ─────────────────────────────────
    if (twilights.length) {
      document.getElementById('twilightSection').style.display = 'block';
      var tgrid = document.getElementById('twilightGrid');
      tgrid.innerHTML = '';
      twilights.forEach(function(p) {
        var card = document.createElement('div');
        card.className = 'twilight-card';
        card.id = 'pkgcard-' + p.id;
        card.innerHTML =
          '<div class="selected-check">&#x2713;</div>' +
          '<img class="twilight-img" src="' + TWILIGHT_IMG + '" alt="Twilight Pass" />' +
          '<div class="twilight-info">' +
          '<div class="twilight-name">Twilight Pass</div>' +
          '<div class="twilight-from">From</div>' +
          '<div class="twilight-pricing">' +
          '<div class="twilight-price">Rs' + p.price + '</div>' +
          '<div class="twilight-discount">-4%</div>' +
          '</div></div>';
        card.addEventListener('click', function(){ selectPkg(p); });
        tgrid.appendChild(card);
      });
    }

    // ── Price table ───────────────────────────────────
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

function selectPayment(method) {
  selectedPay = method;
  document.getElementById('pay-esewa').classList.toggle('selected', method === 'esewa');
  document.getElementById('pay-bank').classList.toggle('selected',  method === 'bank');
  document.getElementById('detail-esewa').classList.toggle('visible', method === 'esewa');
  document.getElementById('detail-bank').classList.toggle('visible',  method === 'bank');
  document.getElementById('selectedPayment').textContent = method === 'esewa' ? 'eSewa' : 'Bank Transfer';
}

function placeOrder() {
  var uid = document.getElementById('userId').value.trim();
  var zid = document.getElementById('zoneId').value.trim();
  if (!uid || !zid)     { showToast('Please enter your User ID and Zone ID!', true); return; }
  if (!selectedPackage) { showToast('Please select a package!', true); return; }
  if (!selectedPay)     { showToast('Please select a payment method!', true); return; }
  var receiptInput = selectedPay === 'esewa' ? document.getElementById('receiptEsewa') : document.getElementById('receiptBank');
  var btn = document.getElementById('orderBtn');
  btn.disabled = true; btn.textContent = 'Placing Order...';
  var formData = new FormData();
  formData.append('gameUserId',    uid);
  formData.append('gameZoneId',    zid);
  formData.append('packageId',     selectedPackage.id);
  formData.append('paymentMethod', selectedPay);
  if (receiptInput && receiptInput.files[0]) formData.append('receipt', receiptInput.files[0]);
  fetch(API + '/orders', { method: 'POST', body: formData })
  .then(function(r){ return r.json().then(function(d){ return {ok:r.ok,d:d}; }); })
  .then(function(res){
    btn.disabled = false; btn.textContent = 'PLACE ORDER NOW';
    if (!res.ok) { showToast(res.d.error || 'Order failed', true); return; }
    document.getElementById('orderRef').textContent = '#' + res.d.order.id;
    document.getElementById('successBanner').classList.add('show');
    showToast('Order placed! Ref: #' + res.d.order.id);
    selectedPackage = null; selectedPay = null;
    document.querySelectorAll('.diamond-card,.special-card,.twilight-card,.payment-card,.pay-detail').forEach(function(c){ c.classList.remove('selected','visible'); });
    document.getElementById('selectedPackage').textContent = 'Select a package';
    document.getElementById('selectedPrice').textContent   = 'Rs --';
    document.getElementById('selectedPayment').textContent = 'Select payment';
  })
  .catch(function(){ btn.disabled=false; btn.textContent='PLACE ORDER NOW'; showToast('Network error. Try again.', true); });
}

function showToast(msg, isError) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.className = 'toast show' + (isError ? ' error' : '');
  setTimeout(function(){ t.className = 'toast'; }, 3000);
}
function copyText(text) { navigator.clipboard.writeText(text).then(function(){ showToast('Copied!'); }); }

document.getElementById('pay-esewa').addEventListener('click', function(){ selectPayment('esewa'); });
document.getElementById('pay-bank').addEventListener('click',  function(){ selectPayment('bank'); });
document.getElementById('orderBtn').addEventListener('click',  placeOrder);
document.getElementById('copyEsewa').addEventListener('click', function(){ copyText('9702764422'); });
document.getElementById('copyBank').addEventListener('click',  function(){ copyText('28407010034283'); });

var pc = document.getElementById('particles');
for (var i = 0; i < 20; i++) {
  var p = document.createElement('div');
  p.className = 'particle';
  p.style.cssText = 'left:'+Math.random()*100+'%;width:'+(Math.random()*3+1)+'px;height:'+(Math.random()*3+1)+'px;animation-duration:'+(Math.random()*15+10)+'s;animation-delay:'+(Math.random()*10)+'s;';
  if (Math.random() > 0.5) p.style.background = '#00C8FF';
  pc.appendChild(p);
}

loadPackages();
</script>
</body>
</html>
"@

$stream2 = [System.IO.StreamWriter]::new(
    (Join-Path (Get-Location).Path "mlbb-topup.html"),
    $false,
    (New-Object System.Text.UTF8Encoding $false)
)
$stream2.Write($html)
$stream2.Close()

Write-Host "      mlbb-topup.html updated." -ForegroundColor Green
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Special Packages UI Done!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  HOW ADMIN PANEL CONTROLS THESE:" -ForegroundColor White
Write-Host ""
Write-Host "  Weekly Pass packages: name must contain 'Weekly Pass'" -ForegroundColor Gray
Write-Host "    e.g. 'Weekly Pass 1x', 'Weekly Pass 2x', etc." -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Twilight Pass: name must contain 'Twilight Pass'" -ForegroundColor Gray
Write-Host "    e.g. 'Twilight Pass'" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  To change price: Admin Panel > Packages > Edit" -ForegroundColor Gray
Write-Host "  To hide: Admin Panel > Packages > Deactivate" -ForegroundColor Gray
Write-Host ""
Write-Host "  NOTE: If backend is not running locally, run:" -ForegroundColor Yellow
Write-Host "  cd backend && npm run dev" -ForegroundColor DarkGray
Write-Host "  Then re-run: node add_special_packages.js" -ForegroundColor DarkGray
Write-Host ""
