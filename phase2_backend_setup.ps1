# ============================================================
#  MLBB TopUp Nepal - Phase 2: Backend Setup
#  Run from: D:\MLBB>  .\phase2_backend_setup.ps1
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  MLBB TopUp Nepal - Phase 2 Backend Setup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# -- 1. FOLDER STRUCTURE -------------------------------------
Write-Host "[1/6] Creating folder structure..." -ForegroundColor Yellow

$folders = @(
    "backend",
    "backend\routes",
    "backend\middleware",
    "backend\prisma"
)
foreach ($f in $folders) {
    New-Item -ItemType Directory -Force -Path $f | Out-Null
}
Write-Host "      Folders created." -ForegroundColor Green

# -- 2. package.json -----------------------------------------
Write-Host "[2/6] Writing package.json..." -ForegroundColor Yellow

@'
{
  "name": "mlbb-topup-backend",
  "version": "1.0.0",
  "description": "MLBB TopUp Nepal API",
  "main": "server.js",
  "scripts": {
    "dev": "nodemon server.js",
    "start": "node server.js",
    "db:push": "npx prisma db push",
    "db:studio": "npx prisma studio"
  },
  "dependencies": {
    "@prisma/client": "^5.0.0",
    "bcryptjs": "^2.4.3",
    "cors": "^2.8.5",
    "dotenv": "^16.0.0",
    "express": "^4.18.0",
    "jsonwebtoken": "^9.0.0",
    "multer": "^1.4.5-lts.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.0",
    "prisma": "^5.0.0"
  }
}
'@ | Set-Content "backend\package.json" -Encoding UTF8

Write-Host "      package.json written." -ForegroundColor Green

# -- 3. .env -------------------------------------------------
Write-Host "[3/6] Writing .env file..." -ForegroundColor Yellow

@'
# -- Database ----------------------------------------------
# Local PostgreSQL (change user/password/dbname to match yours)
DATABASE_URL="postgresql://postgres:yourpassword@localhost:5432/mlbb_topup"

# -- JWT ---------------------------------------------------
JWT_SECRET="change_this_to_a_long_random_string_abc123xyz"

# -- Server ------------------------------------------------
PORT=4000

# -- Admin account (used for first-time seed only) ---------
ADMIN_EMAIL="admin@mlbbtopup.com"
ADMIN_PASSWORD="Admin@1234"
'@ | Set-Content "backend\.env" -Encoding UTF8

Write-Host "      .env written. EDIT your DB password inside!" -ForegroundColor Green

# -- 4. PRISMA SCHEMA ----------------------------------------
Write-Host "[4/6] Writing Prisma schema..." -ForegroundColor Yellow

@'
// backend/prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  password  String
  name      String?
  role      String   @default("user")
  createdAt DateTime @default(now())
  orders    Order[]
}

model Package {
  id       Int     @id @default(autoincrement())
  name     String
  diamonds Int
  bonus    Int     @default(0)
  price    Float
  active   Boolean @default(true)
  orders   Order[]
}

model Order {
  id            Int      @id @default(autoincrement())
  userId        Int?
  user          User?    @relation(fields: [userId], references: [id])
  packageId     Int
  package       Package  @relation(fields: [packageId], references: [id])
  gameUserId    String
  gameZoneId    String
  paymentMethod String
  status        String   @default("pending")
  receiptPath   String?
  totalPrice    Float
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  note          String?
}
'@ | Set-Content "backend\prisma\schema.prisma" -Encoding UTF8

Write-Host "      schema.prisma written." -ForegroundColor Green

# -- 5. WRITE ALL SOURCE FILES --------------------------------
Write-Host "[5/6] Writing source files..." -ForegroundColor Yellow

# ---- middleware/auth.js ----
@'
// backend/middleware/auth.js
const jwt = require("jsonwebtoken");

function authMiddleware(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith("Bearer ")) {
    return res.status(401).json({ error: "No token provided" });
  }
  const token = header.split(" ")[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch {
    return res.status(401).json({ error: "Invalid or expired token" });
  }
}

function adminOnly(req, res, next) {
  if (req.user?.role !== "admin") {
    return res.status(403).json({ error: "Admin access required" });
  }
  next();
}

module.exports = { authMiddleware, adminOnly };
'@ | Set-Content "backend\middleware\auth.js" -Encoding UTF8

# ---- routes/auth.js ----
@'
// backend/routes/auth.js
const express = require("express");
const router  = express.Router();
const bcrypt  = require("bcryptjs");
const jwt     = require("jsonwebtoken");
const { PrismaClient } = require("@prisma/client");
const prisma  = new PrismaClient();

// POST /api/auth/register
router.post("/register", async (req, res) => {
  const { email, password, name } = req.body;
  if (!email || !password) return res.status(400).json({ error: "Email and password required" });

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) return res.status(409).json({ error: "Email already registered" });

  const hashed = await bcrypt.hash(password, 10);
  const user   = await prisma.user.create({ data: { email, password: hashed, name } });

  const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, process.env.JWT_SECRET, { expiresIn: "7d" });
  res.json({ token, user: { id: user.id, email: user.email, name: user.name, role: user.role } });
});

// POST /api/auth/login
router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: "Email and password required" });

  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) return res.status(401).json({ error: "Invalid credentials" });

  const match = await bcrypt.compare(password, user.password);
  if (!match) return res.status(401).json({ error: "Invalid credentials" });

  const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, process.env.JWT_SECRET, { expiresIn: "7d" });
  res.json({ token, user: { id: user.id, email: user.email, name: user.name, role: user.role } });
});

module.exports = router;
'@ | Set-Content "backend\routes\auth.js" -Encoding UTF8

# ---- routes/orders.js ----
@'
// backend/routes/orders.js
const express  = require("express");
const router   = express.Router();
const multer   = require("multer");
const path     = require("path");
const { PrismaClient } = require("@prisma/client");
const { authMiddleware, adminOnly } = require("../middleware/auth");
const prisma   = new PrismaClient();

// Receipt file upload setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename:    (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname))
});
const upload = multer({ storage, limits: { fileSize: 5 * 1024 * 1024 } });

// POST /api/orders - place a new order (public, no login required)
router.post("/", upload.single("receipt"), async (req, res) => {
  try {
    const { gameUserId, gameZoneId, packageId, paymentMethod, userId } = req.body;

    if (!gameUserId || !gameZoneId || !packageId || !paymentMethod) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const pkg = await prisma.package.findUnique({ where: { id: parseInt(packageId) } });
    if (!pkg || !pkg.active) return res.status(404).json({ error: "Package not found" });

    const order = await prisma.order.create({
      data: {
        gameUserId,
        gameZoneId,
        packageId:     parseInt(packageId),
        paymentMethod,
        totalPrice:    pkg.price,
        userId:        userId ? parseInt(userId) : null,
        receiptPath:   req.file ? req.file.filename : null
      },
      include: { package: true }
    });

    res.status(201).json({ message: "Order placed successfully", order });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

// GET /api/orders/my - logged-in user sees their own orders
router.get("/my", authMiddleware, async (req, res) => {
  const orders = await prisma.order.findMany({
    where:   { userId: req.user.id },
    include: { package: true },
    orderBy: { createdAt: "desc" }
  });
  res.json(orders);
});

// GET /api/orders/:id - get single order by id (public, for order tracking)
router.get("/:id", async (req, res) => {
  const order = await prisma.order.findUnique({
    where:   { id: parseInt(req.params.id) },
    include: { package: true }
  });
  if (!order) return res.status(404).json({ error: "Order not found" });
  res.json(order);
});

// -- ADMIN ROUTES --------------------------------------------

// GET /api/orders - admin: list all orders
router.get("/", authMiddleware, adminOnly, async (req, res) => {
  const orders = await prisma.order.findMany({
    include: { package: true, user: { select: { email: true, name: true } } },
    orderBy: { createdAt: "desc" }
  });
  res.json(orders);
});

// PATCH /api/orders/:id/status - admin: update order status
router.patch("/:id/status", authMiddleware, adminOnly, async (req, res) => {
  const { status, note } = req.body;
  const validStatuses = ["pending", "processing", "delivered", "failed"];
  if (!validStatuses.includes(status)) return res.status(400).json({ error: "Invalid status" });

  const order = await prisma.order.update({
    where: { id: parseInt(req.params.id) },
    data:  { status, note }
  });
  res.json({ message: "Status updated", order });
});

module.exports = router;
'@ | Set-Content "backend\routes\orders.js" -Encoding UTF8

# ---- routes/packages.js ----
@'
// backend/routes/packages.js
const express = require("express");
const router  = express.Router();
const { PrismaClient } = require("@prisma/client");
const { authMiddleware, adminOnly } = require("../middleware/auth");
const prisma  = new PrismaClient();

// GET /api/packages - public: list all active packages
router.get("/", async (req, res) => {
  const packages = await prisma.package.findMany({
    where:   { active: true },
    orderBy: { price: "asc" }
  });
  res.json(packages);
});

// POST /api/packages - admin: create new package
router.post("/", authMiddleware, adminOnly, async (req, res) => {
  const { name, diamonds, bonus, price } = req.body;
  const pkg = await prisma.package.create({ data: { name, diamonds, bonus: bonus || 0, price } });
  res.status(201).json(pkg);
});

// PATCH /api/packages/:id - admin: edit package price/name
router.patch("/:id", authMiddleware, adminOnly, async (req, res) => {
  const { name, diamonds, bonus, price, active } = req.body;
  const pkg = await prisma.package.update({
    where: { id: parseInt(req.params.id) },
    data:  { name, diamonds, bonus, price, active }
  });
  res.json(pkg);
});

// DELETE /api/packages/:id - admin: deactivate package
router.delete("/:id", authMiddleware, adminOnly, async (req, res) => {
  await prisma.package.update({
    where: { id: parseInt(req.params.id) },
    data:  { active: false }
  });
  res.json({ message: "Package deactivated" });
});

module.exports = router;
'@ | Set-Content "backend\routes\packages.js" -Encoding UTF8

# ---- server.js ----
@'
// backend/server.js
require("dotenv").config();
const express = require("express");
const cors    = require("cors");
const path    = require("path");
const fs      = require("fs");

const app = express();

// -- Middleware --------------------------------------------
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded receipts statically
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// -- Routes ------------------------------------------------
app.use("/api/auth",     require("./routes/auth"));
app.use("/api/orders",   require("./routes/orders"));
app.use("/api/packages", require("./routes/packages"));

// -- Health check ------------------------------------------
app.get("/api/health", (req, res) => {
  res.json({ status: "ok", time: new Date().toISOString() });
});

// -- Start -------------------------------------------------
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`\n  MLBB API running at http://localhost:${PORT}`);
  console.log(`  Health: http://localhost:${PORT}/api/health\n`);
});
'@ | Set-Content "backend\server.js" -Encoding UTF8

# ---- seed.js ----
@'
// backend/seed.js - run once: node seed.js
// Seeds admin user + all diamond packages into the DB

require("dotenv").config();
const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();

const packages = [
  { name: "5 Diamonds",    diamonds: 5,    bonus: 0,  price: 18.24 },
  { name: "11 Diamonds",   diamonds: 10,   bonus: 1,  price: 34.56 },
  { name: "17 Diamonds",   diamonds: 15,   bonus: 2,  price: 57.60 },
  { name: "22 Diamonds",   diamonds: 20,   bonus: 2,  price: 68.16 },
  { name: "28 Diamonds",   diamonds: 25,   bonus: 3,  price: 96.96 },
  { name: "33 Diamonds",   diamonds: 30,   bonus: 3,  price: 114.24 },
  { name: "36 Diamonds",   diamonds: 33,   bonus: 3,  price: 126.72 },
  { name: "38 Diamonds",   diamonds: 34,   bonus: 4,  price: 133.44 },
  { name: "44 Diamonds",   diamonds: 40,   bonus: 4,  price: 145.92 },
  { name: "56 Diamonds",   diamonds: 51,   bonus: 5,  price: 168.96 },
  { name: "66 Diamonds",   diamonds: 60,   bonus: 6,  price: 228.48 },
  { name: "71 Diamonds",   diamonds: 64,   bonus: 7,  price: 236.16 },
  { name: "86 Diamonds",   diamonds: 78,   bonus: 8,  price: 240.96 },
  { name: "112 Diamonds",  diamonds: 102,  bonus: 10, price: 336.96 },
  { name: "172 Diamonds",  diamonds: 156,  bonus: 16, price: 477.12 },
  { name: "257 Diamonds",  diamonds: 234,  bonus: 23, price: 691.20 },
  { name: "344 Diamonds",  diamonds: 312,  bonus: 32, price: 964.80 },
  { name: "514 Diamonds",  diamonds: 468,  bonus: 46, price: 1403.52 },
  { name: "600 Diamonds",  diamonds: 546,  bonus: 54, price: 1646.40 },
  { name: "706 Diamonds",  diamonds: 625,  bonus: 81, price: 1876.80 },
];

async function main() {
  console.log("Seeding packages...");
  for (const pkg of packages) {
    await prisma.package.upsert({
      where:  { id: packages.indexOf(pkg) + 1 },
      update: pkg,
      create: pkg
    });
  }

  console.log("Seeding admin user...");
  const hashed = await bcrypt.hash(process.env.ADMIN_PASSWORD || "Admin@1234", 10);
  await prisma.user.upsert({
    where:  { email: process.env.ADMIN_EMAIL || "admin@mlbbtopup.com" },
    update: {},
    create: {
      email:    process.env.ADMIN_EMAIL || "admin@mlbbtopup.com",
      password: hashed,
      name:     "Admin",
      role:     "admin"
    }
  });

  console.log("Done! Admin:", process.env.ADMIN_EMAIL);
  console.log("Packages seeded:", packages.length);
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
'@ | Set-Content "backend\seed.js" -Encoding UTF8

# ---- .gitignore ----
@'
node_modules/
.env
uploads/
prisma/migrations/
'@ | Set-Content "backend\.gitignore" -Encoding UTF8

Write-Host "      All source files written." -ForegroundColor Green

# -- 6. NPM INSTALL ------------------------------------------
Write-Host "[6/6] Installing npm dependencies (this takes ~30 seconds)..." -ForegroundColor Yellow

Set-Location "backend"

# Create uploads folder
New-Item -ItemType Directory -Force -Path "uploads" | Out-Null

npm install 2>&1 | Out-Null

Write-Host "      npm install complete." -ForegroundColor Green

# -- DONE ----------------------------------------------------
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Phase 2 Setup Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Your folder structure:" -ForegroundColor White
Write-Host "  D:\MLBB\" -ForegroundColor Gray
Write-Host "  +-- mlbb-topup.html" -ForegroundColor Gray
Write-Host "  +-- backend\" -ForegroundColor Gray
Write-Host "      +-- server.js" -ForegroundColor Gray
Write-Host "      +-- seed.js" -ForegroundColor Gray
Write-Host "      +-- .env            <-- EDIT THIS FIRST" -ForegroundColor Yellow
Write-Host "      +-- routes\" -ForegroundColor Gray
Write-Host "      |   +-- auth.js" -ForegroundColor Gray
Write-Host "      |   +-- orders.js" -ForegroundColor Gray
Write-Host "      |   +-- packages.js" -ForegroundColor Gray
Write-Host "      +-- middleware\" -ForegroundColor Gray
Write-Host "      |   +-- auth.js" -ForegroundColor Gray
Write-Host "      +-- prisma\" -ForegroundColor Gray
Write-Host "      |   +-- schema.prisma" -ForegroundColor Gray
Write-Host "      +-- uploads\" -ForegroundColor Gray
Write-Host ""
Write-Host "  NEXT STEPS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Install PostgreSQL if you havent:" -ForegroundColor White
Write-Host "     https://www.postgresql.org/download/windows/" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  2. Create your database in psql:" -ForegroundColor White
Write-Host "     CREATE DATABASE mlbb_topup;" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  3. Edit backend\.env - set your DB password" -ForegroundColor White
Write-Host ""
Write-Host "  4. Push schema to DB:" -ForegroundColor White
Write-Host "     cd backend" -ForegroundColor DarkGray
Write-Host "     npx prisma db push" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  5. Seed admin + packages:" -ForegroundColor White
Write-Host "     node seed.js" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  6. Start the server:" -ForegroundColor White
Write-Host "     npm run dev" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  7. Test it:" -ForegroundColor White
Write-Host "     http://localhost:4000/api/health" -ForegroundColor DarkGray
Write-Host ""
