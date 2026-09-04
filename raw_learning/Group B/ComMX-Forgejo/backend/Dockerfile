FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./

RUN npm ci --only=production

COPY --from=builder /app/dist ./dist

USER node

EXPOSE 3000

# dist/src/, bukan dist/ -- diukur 2026-09-04, lihat [[G-05]]
CMD ["node", "dist/src/main.js"]
