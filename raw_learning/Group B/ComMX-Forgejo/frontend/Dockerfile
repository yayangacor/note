# NEXT_PUBLIC_* DIBAKAR SAAT BUILD, bukan dibaca saat runtime (G-04).
# Karena itu URL https:// dan wss:// masuk lewat --build-arg di pipeline CI,
# bukan lewat env di Deployment. Menyetelnya di Deployment tidak berpengaruh.
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS builder
WORKDIR /app

ARG NEXT_PUBLIC_SOCKET_URL
ARG NEXT_PUBLIC_BACKEND_URL
ENV NEXT_PUBLIC_SOCKET_URL=$NEXT_PUBLIC_SOCKET_URL
ENV NEXT_PUBLIC_BACKEND_URL=$NEXT_PUBLIC_BACKEND_URL

# Gagalkan build lebih awal kalau build-arg lupa dikirim. Lebih baik build
# merah sekarang daripada image yang diam-diam menunjuk URL kosong dan baru
# ketahuan saat demo.
RUN test -n "$NEXT_PUBLIC_SOCKET_URL" || (echo "NEXT_PUBLIC_SOCKET_URL wajib diisi lewat --build-arg" && exit 1)
RUN test -n "$NEXT_PUBLIC_BACKEND_URL" || (echo "NEXT_PUBLIC_BACKEND_URL wajib diisi lewat --build-arg" && exit 1)

COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
CMD ["node", "server.js"]
