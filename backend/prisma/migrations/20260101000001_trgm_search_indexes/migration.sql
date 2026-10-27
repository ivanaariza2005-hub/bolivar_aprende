-- Índices trigram para la búsqueda insensible a mayúsculas del catálogo.
-- Prisma genera `ILIKE '%texto%'` para `contains` con `mode: 'insensitive'`,
-- y sin trigram eso es un sequential scan.
--
-- El operador se califica como `extensions.gin_trgm_ops` porque la extensión
-- vive en el esquema `extensions` y Prisma fija `search_path` al esquema de
-- la conexión (por ejemplo `test`), dejando ese esquema fuera del path.

CREATE INDEX "offers_title_idx" ON "offers" USING GIN ("title" extensions.gin_trgm_ops);
CREATE INDEX "offers_description_idx" ON "offers" USING GIN ("description" extensions.gin_trgm_ops);
CREATE INDEX "offers_institution_idx" ON "offers" USING GIN ("institution" extensions.gin_trgm_ops);
