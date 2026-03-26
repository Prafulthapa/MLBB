// backend/server.js
require("dotenv").config();
const express = require("express");
const cors    = require("cors");
const path    = require("path");
const fs      = require("fs");

const app = express();

// -- Middleware --------------------------------------------
app.use(cors({ origin: true, credentials: true }));
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
