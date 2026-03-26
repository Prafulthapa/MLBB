FROM node:20-bookworm-slim

# Install OpenSSL for Prisma
RUN apt-get update -qq && apt-get install -y openssl ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies first (layer cache)
COPY package*.json ./
RUN npm install --production

# Copy source
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Create uploads directory
RUN mkdir -p uploads

EXPOSE 4000

# Wait for DB, push schema, seed once, then start server
CMD ["sh", "-c", "npx prisma db push --accept-data-loss && node seed.js || true && node server.js"]
