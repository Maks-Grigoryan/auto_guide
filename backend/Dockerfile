# Build context is the REPO ROOT (see docker-compose.yml: context: .)
# so the image can include db/migrations, which live outside backend/.
FROM node:20-alpine AS builder

WORKDIR /app

COPY backend/package*.json ./
RUN npm ci

COPY backend/tsconfig.json backend/nest-cli.json ./
COPY backend/src/ ./src/

RUN npx nest build

# ---- runtime ----
FROM node:20-alpine

WORKDIR /app

COPY backend/package*.json ./
RUN npm ci --omit=dev && \
    npm install node-pg-migrate pg

COPY --from=builder /app/dist ./dist
# Migrations live at repo-root db/migrations; copy them so the container
# can run `node-pg-migrate up -m ./db/migrations` on startup.
COPY db/migrations ./db/migrations

EXPOSE 3000
