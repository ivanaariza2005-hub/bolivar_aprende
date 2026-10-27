-- Cada oferta pasa a tener dueno. Las filas existentes se asignan al usuario
-- mas antiguo (hoy el usuario demo); en una base vacia el UPDATE no afecta
-- ninguna fila y la columna se puede marcar NOT NULL sin problema.

ALTER TABLE "offers" ADD COLUMN "owner_id" UUID;

UPDATE "offers"
SET "owner_id" = (SELECT "id" FROM "users" ORDER BY "created_at" ASC LIMIT 1)
WHERE "owner_id" IS NULL;

ALTER TABLE "offers" ALTER COLUMN "owner_id" SET NOT NULL;

CREATE INDEX "offers_owner_id_idx" ON "offers"("owner_id");

ALTER TABLE "offers"
  ADD CONSTRAINT "offers_owner_id_fkey"
  FOREIGN KEY ("owner_id") REFERENCES "users"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
