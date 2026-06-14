-- Migration 001: Enable required PostgreSQL extensions
-- postgis provides geography type and spatial functions (ST_MakePoint, ST_DWithin, etc.)
-- pg_trgm provides GIN trigram indexes for fast full-text search on parts.title

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
