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
