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
  console.log('All done!');
  await prisma.$disconnect();
}

main().catch(async (e) => {
  console.error(e);
  await prisma.$disconnect();
  process.exit(1);
});
