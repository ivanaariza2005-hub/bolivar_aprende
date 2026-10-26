CREATE TABLE "users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "full_name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL
);

CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

CREATE TABLE "offers" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "institution" TEXT NOT NULL,
    "municipality" TEXT NOT NULL,
    "modality" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL,
    CONSTRAINT "offers_type_check" CHECK ("type" IN ('job', 'academic')),
    CONSTRAINT "offers_modality_check" CHECK ("modality" IN ('onsite', 'remote', 'hybrid')),
    CONSTRAINT "offers_municipality_bolivar_check" CHECK ("municipality" IN (
        'Achí',
        'Altos del Rosario',
        'Arenal',
        'Arjona',
        'Arroyohondo',
        'Barranco de Loba',
        'Calamar',
        'Cantagallo',
        'Cartagena',
        'Cicuco',
        'Clemencia',
        'Córdoba',
        'El Carmen de Bolívar',
        'El Guamo',
        'El Peñón',
        'Hatillo de Loba',
        'Magangué',
        'Mahates',
        'Margarita',
        'María La Baja',
        'Montecristo',
        'Morales',
        'Norosí',
        'Pinillos',
        'Regidor',
        'Río Viejo',
        'San Cristóbal',
        'San Estanislao',
        'San Fernando',
        'San Jacinto',
        'San Jacinto del Cauca',
        'San Juan Nepomuceno',
        'San Martín de Loba',
        'San Pablo',
        'Santa Catalina',
        'Santa Cruz de Mompox',
        'Santa Rosa',
        'Santa Rosa del Sur',
        'Simití',
        'Soplaviento',
        'Talaigua Nuevo',
        'Tiquisio',
        'Turbaco',
        'Turbaná',
        'Villanueva',
        'Zambrano'
    ))
);

CREATE INDEX "offers_type_idx" ON "offers"("type");
CREATE INDEX "offers_municipality_idx" ON "offers"("municipality");
CREATE INDEX "offers_created_at_idx" ON "offers"("created_at");

CREATE TABLE "saved_offers" (
    "user_id" TEXT NOT NULL,
    "offer_id" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("user_id", "offer_id"),
    CONSTRAINT "saved_offers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "saved_offers_offer_id_fkey" FOREIGN KEY ("offer_id") REFERENCES "offers" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "saved_offers_offer_id_idx" ON "saved_offers"("offer_id");
