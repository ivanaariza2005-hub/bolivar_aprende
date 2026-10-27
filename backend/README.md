# API - Bolívar Aprende y Trabaja

API REST en Node.js + Express para la gestión de ofertas laborales y académicas del departamento de Bolívar. Incluye autenticación con JWT, CRUD de ofertas y gestión de ofertas guardadas por usuario.

## Requisitos

- Node.js 20 o superior.
- npm 9 o superior.
- Una base de datos PostgreSQL. El proyecto usa Supabase, pero cualquier PostgreSQL sirve.

## Instalación

```bash
cd backend
npm install
cp .env.example .env
```

En Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

Edita `.env` y define al menos un `JWT_SECRET` de 32 caracteres o más.

## Variables de entorno

| Variable | Obligatoria | Valor por defecto | Descripción |
| --- | --- | --- | --- |
| `NODE_ENV` | No | `development` | `development`, `test` o `production` |
| `PORT` | No | `3000` | Puerto HTTP |
| `DATABASE_URL` | Sí | - | Cadena de conexión PostgreSQL (Session pooler de Supabase) |
| `JWT_SECRET` | Sí | - | Secreto de firma, mínimo 32 caracteres |
| `JWT_EXPIRES_IN` | No | `7d` | Vigencia del token |
| `CORS_ORIGINS` | No | `*` | Orígenes permitidos separados por coma |
| `LOG_LEVEL` | No | `info` | Nivel de pino: `fatal` a `silent` |

La aplicación valida la configuración al arrancar y falla con un mensaje claro si falta algo.

## Puesta en marcha

```bash
npm run db:generate   # genera el cliente Prisma
npm run db:migrate    # aplica las migraciones en PostgreSQL
npm run db:seed       # carga 18 ofertas y el usuario de demostración
npm run dev           # servidor con recarga automática en http://localhost:3000
```

Para producción:

```bash
npm start
```

La API no expone una ruta raíz; todos los recursos viven bajo `/api`.

## Usuario de demostración

| Correo | Contraseña |
| --- | --- |
| `demo@bolivaraprende.co` | `Demo12345` |

La semilla deja tres ofertas guardadas para este usuario.

## Scripts

| Script | Acción |
| --- | --- |
| `npm run dev` | Servidor con `node --watch` |
| `npm start` | Servidor sin recarga |
| `npm run db:generate` | `prisma generate` |
| `npm run db:migrate` | `prisma migrate deploy` |
| `npm run db:reset` | Borra, recrea y vuelve a sembrar la base |
| `npm run db:seed` | Ejecuta `prisma/seed.js` |
| `npm test` | Prepara `prisma/test.db` y ejecuta Jest + Supertest |

## Endpoints

Todas las rutas de ofertas requieren `Authorization: Bearer <token>`.

### Autenticación

| Método | Ruta | Cuerpo | Respuesta |
| --- | --- | --- | --- |
| POST | `/api/auth/register` | `fullName`, `email`, `password`, `passwordConfirmation` | 201 `{ token, user }` |
| POST | `/api/auth/login` | `email`, `password` | 200 `{ token, user }` |
| GET | `/api/auth/me` | - | 200 `{ user }` |

Contraseña válida: entre 8 y 64 caracteres, al menos una letra y un número. El correo se normaliza a minúsculas.

### Ofertas

| Método | Ruta | Descripción |
| --- | --- | --- |
| GET | `/api/offers` | Listado ordenado por fecha descendente |
| GET | `/api/offers/:id` | Detalle |
| POST | `/api/offers` | Crear |
| PUT | `/api/offers/:id` | Actualizar todos los campos |
| DELETE | `/api/offers/:id` | Eliminar (204) |
| POST | `/api/offers/:id/save` | Guardar para el usuario (idempotente) |
| DELETE | `/api/offers/:id/save` | Desguardar (idempotente) |

Filtros de `GET /api/offers`:

| Parámetro | Valores | Ejemplo |
| --- | --- | --- |
| `q` | Texto libre hasta 100 caracteres | `?q=beca` |
| `type` | `job`, `academic` | `?type=academic` |
| `municipality` | Municipio exacto de Bolívar | `?municipality=Cartagena` |
| `saved` | `true` | `?saved=true` |

Cuerpo de creación y actualización:

```json
{
  "title": "Operario de producción en planta de alimentos",
  "description": "Se requiere operario para la línea de empaque de una planta de alimentos.",
  "type": "job",
  "institution": "Agrosur del Bolívar",
  "municipality": "El Carmen de Bolívar",
  "modality": "onsite"
}
```

`type`: `job` o `academic`. `modality`: `onsite`, `remote` o `hybrid`. `municipality` debe pertenecer a los 46 municipios de Bolívar.

Cada oferta incluye `isSaved`, calculado para el usuario autenticado.

### Formato de error

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Revisa los campos marcados.",
    "details": [
      { "field": "title", "message": "El título debe tener al menos 5 caracteres." }
    ]
  }
}
```

Códigos: `VALIDATION_ERROR`, `INVALID_JSON`, `UNAUTHORIZED`, `TOKEN_EXPIRED`, `INVALID_CREDENTIALS`, `NOT_FOUND`, `ROUTE_NOT_FOUND`, `EMAIL_TAKEN`, `CONFLICT`, `RATE_LIMITED`, `INTERNAL_ERROR`.

## Ejemplo con curl

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"demo@bolivaraprende.co\",\"password\":\"Demo12345\"}"
```

```bash
curl http://localhost:3000/api/offers \
  -H "Authorization: Bearer <token>"
```

## Pruebas

```bash
npm test
```

- Jest en modo ESM (`NODE_OPTIONS=--experimental-vm-modules`).
- Supertest contra la aplicación Express sin abrir puerto.
- Esquema `test` dentro de la misma base PostgreSQL, recreado antes de cada ejecución.
- 36 pruebas en tres suites: autenticación, ofertas y ofertas guardadas.

Resultado de referencia en este entorno: 3 suites y 36 pruebas aprobadas.

## Estructura

```
backend/
  prisma/
    schema.prisma          modelo de datos PostgreSQL
    seed.js                semilla de 18 ofertas y usuario demo
    migrations/            DDL versionado con restricciones CHECK, RLS y triggers
  scripts/
    prepare-test-db.js     recrea el esquema de prueba
    testDatabase.js        resuelve la URL del esquema de prueba
  src/
    app.js                 composición de Express
    server.js              arranque y cierre ordenado
    config/env.js          validación de variables de entorno
    constants/             municipios y enums
    controllers/           capa HTTP
    lib/                   AppError, JWT, bcrypt, pino, Prisma
    middlewares/           auth, validación, errores, rate limit
    repositories/          acceso a datos
    routes/                definición de endpoints
    services/              reglas de negocio y DTOs
    validators/            esquemas Zod
  tests/                   suites con Jest + Supertest
```

## Seguridad

- Contraseñas con bcrypt (12 rondas); el hash nunca sale de la capa de datos.
- JWT HS256 con expiración y verificación de que la cuenta siga existiendo.
- Helmet, CORS configurable, cuerpo máximo de 100 KB y rate limit global, de autenticación y de escrituras.
- Registro de errores con pino y redacción de cabeceras sensibles.
- Límite de intentos de autenticación: 20 por ventana de 15 minutos.

## Base de datos (Supabase)

El esquema vive en PostgreSQL, en el proyecto `ymtfgdybmyquqjpsncqc` (región `us-east-1`).

1. Copia la cadena de conexión desde **Project Settings → Database → Connection string → Session pooler**.
2. Pégala en `DATABASE_URL` dentro de `.env`. Usa el pooler (`aws-0-us-east-1.pooler.supabase.com`): la conexión directa `db.<ref>.supabase.co` solo resuelve IPv6.
3. Aplica el esquema y los datos:

```bash
npm run db:migrate
npm run db:seed
```

Notas:

- Las tablas `users`, `offers` y `saved_offers` viven en el esquema `public`.
- Tienen `CHECK` de enums y de municipios, trigger de `updated_at` y Row Level Security activo. Solo `offers` es legible con las claves públicas; el resto queda denegado por defecto.
- Las pruebas usan el esquema `test` de la misma base (ver `scripts/testDatabase.js`), así que no tocan los datos reales.
- El backend se conecta con el rol `postgres`, que omite RLS. No expongas la `DATABASE_URL` al cliente.

Los repositorios, servicios y la aplicación móvil no requieren cambios.

## Despliegue en Render

El repositorio incluye `render.yaml` en la raíz, así que la vía rápida es
**New → Blueprint** y seleccionar el repo. Render crea el servicio con estos
valores:

| Ajuste | Valor |
| --- | --- |
| Root Directory | `backend` |
| Build Command | `npm ci --include=dev` |
| Start Command | `npm run start:deploy` |
| Health Check Path | `/api/health` |
| Region | Virginia (`us-east-1`, junto a Supabase) |

`start:deploy` ejecuta `prisma migrate deploy` antes de arrancar el servidor.
En el plan free no existe pre-deploy command, por eso las migraciones van en el
arranque. `--include=dev` es necesario porque con `NODE_ENV=production` npm
omite las devDependencies y fallaría `postinstall: prisma generate`.

### Variables de entorno

| Variable | Valor |
| --- | --- |
| `NODE_ENV` | `production` |
| `DATABASE_URL` | Session pooler con `&connection_limit=5&pool_timeout=20` |
| `JWT_SECRET` | Generado por Render (`generateValue`) o `openssl rand -base64 48` |
| `JWT_EXPIRES_IN` | `7d` |
| `CORS_ORIGINS` | `*` mientras solo haya app móvil |
| `LOG_LEVEL` | `info` |

`PORT` lo inyecta Render; no hay que definirlo.

### Limitaciones del plan free

- El servicio se suspende a los **15 minutos** sin tráfico. El primer request
  después tarda entre 30 y 60 segundos (cold start).
- La app móvil ya usa timeouts de 30 s para tolerarlo. Si aun así falla, añade
  un ping cada 10 minutos (UptimeRobot, cron-job.org) o pasa a plan Starter.
- Supabase free también pausa el proyecto a los 7 días sin actividad.

### Verificación

```bash
curl https://<servicio>.onrender.com/api/health
# {"status":"ok","database":"connected"}

curl -X POST https://<servicio>.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@bolivaraprende.co","password":"Demo12345"}'
```

### App móvil

Compila apuntando a la URL pública (HTTPS obligatorio en Android desde API 28):

```bash
flutter build apk --dart-define=API_BASE_URL=https://<servicio>.onrender.com/api
```

