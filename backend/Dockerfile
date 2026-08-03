# Build context is the REPO ROOT (see docker-compose.yml: context: .)
# so the image can include db/migrations, which live outside backend/.
FROM node:20-alpine AS builder

WORKDIR /app

COPY backend/package*.json ./
RUN npm ci

COPY backend/tsconfig.json backend/nest-cli.json ./
COPY backend/src/ ./src/

RUN npx nest build

# ---- minimal one-shot database migrator ----
FROM node:20-alpine AS migrator

WORKDIR /app

COPY backend/migrator/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY db/migrations ./db/migrations

USER node

CMD ["./node_modules/.bin/node-pg-migrate", "up", "-m", "./db/migrations", "--no-check-order"]

# ---- production API runtime ----
FROM node:20-alpine

WORKDIR /app
ENV NODE_ENV=production

COPY backend/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=builder --chown=node:node /app/dist ./dist

USER node

EXPOSE 3000

CMD ["node", "dist/main"]
