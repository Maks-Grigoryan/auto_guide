FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY tsconfig.json nest-cli.json ./
COPY src/ ./src/

RUN npx nest build

# ---- runtime ----
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev && \
    npm install node-pg-migrate pg

COPY --from=builder /app/dist ./dist
COPY database.json* ./

EXPOSE 3000
