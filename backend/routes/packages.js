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
