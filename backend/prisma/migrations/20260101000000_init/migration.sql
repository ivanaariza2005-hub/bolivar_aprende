-- Migración inicial para PostgreSQL (Supabase).
-- Generada a partir de prisma/schema.prisma con:
--   npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script
-- Más los extras que Prisma no gestiona: restricciones CHECK, trigger de
-- updated_at y Row Level Security.

-- CreateExtension
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA extensions;

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "full_name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "users_full_name_len" CHECK (char_length("full_name") BETWEEN 2 AND 120),
    CONSTRAINT "users_email_format" CHECK ("email" ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$')
);

-- CreateTable
CREATE TABLE "offers" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "institution" TEXT NOT NULL,
    "municipality" TEXT NOT NULL,
    "modality" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "offers_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "offers_type_check" CHECK ("type" IN ('job', 'academic')),
    CONSTRAINT "offers_modality_check" CHECK ("modality" IN ('onsite', 'remote', 'hybrid')),
    CONSTRAINT "offers_municipality_check" CHECK ("municipality" IN (
        'Achí', 'Altos del Rosario', 'Arenal', 'Arjona', 'Arroyohondo', 'Barranco de Loba',
        'Calamar', 'Cantagallo', 'Cartagena', 'Cicuco', 'Clemencia', 'Córdoba',
        'El Carmen de Bolívar', 'El Guamo', 'El Peñón', 'Hatillo de Loba', 'Magangué',
        'Mahates', 'Margarita', 'María La Baja', 'Montecristo', 'Morales', 'Norosí',
        'Pinillos', 'Regidor', 'Río Viejo', 'San Cristóbal', 'San Estanislao', 'San Fernando',
        'San Jacinto', 'San Jacinto del Cauca', 'San Juan Nepomuceno', 'San Martín de Loba',
        'San Pablo', 'Santa Catalina', 'Santa Cruz de Mompox', 'Santa Rosa', 'Santa Rosa del Sur',
        'Simití', 'Soplaviento', 'Talaigua Nuevo', 'Tiquisio', 'Turbaco', 'Turbaná',
        'Villanueva', 'Zambrano'
    )),
    CONSTRAINT "offers_title_len" CHECK (char_length("title") BETWEEN 5 AND 120),
    CONSTRAINT "offers_description_len" CHECK (char_length("description") BETWEEN 20 AND 2000),
    CONSTRAINT "offers_institution_len" CHECK (char_length("institution") BETWEEN 2 AND 120)
);

-- CreateTable
CREATE TABLE "saved_offers" (
    "user_id" UUID NOT NULL,
    "offer_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "saved_offers_pkey" PRIMARY KEY ("user_id","offer_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "offers_type_idx" ON "offers"("type");

-- CreateIndex
CREATE INDEX "offers_municipality_idx" ON "offers"("municipality");

-- CreateIndex
CREATE INDEX "offers_created_at_idx" ON "offers"("created_at" DESC);

-- CreateIndex
CREATE INDEX "offers_type_municipality_created_at_idx" ON "offers"("type", "municipality", "created_at" DESC);

-- CreateIndex
CREATE INDEX "saved_offers_offer_id_idx" ON "saved_offers"("offer_id");

-- AddForeignKey
ALTER TABLE "saved_offers" ADD CONSTRAINT "saved_offers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saved_offers" ADD CONSTRAINT "saved_offers_offer_id_fkey" FOREIGN KEY ("offer_id") REFERENCES "offers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Mantener updated_at al día sin depender del cliente.
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $fn$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$fn$;

CREATE TRIGGER "users_set_updated_at" BEFORE UPDATE ON "users"
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER "offers_set_updated_at" BEFORE UPDATE ON "offers"
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- RLS: el backend se conecta como `postgres` y la omite.
-- anon/authenticated solo pueden leer el catálogo; users y saved_offers
-- quedan denegadas por defecto (sin políticas).
ALTER TABLE "users" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "offers" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "saved_offers" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "offers_public_read" ON "offers"
    FOR SELECT TO anon, authenticated
    USING (true);
