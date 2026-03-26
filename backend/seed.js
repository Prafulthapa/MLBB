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
