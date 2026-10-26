# API - Bolívar Aprende y Trabaja

API REST en Node.js + Express para la gestión de ofertas laborales y académicas del departamento de Bolívar. Incluye autenticación con JWT, CRUD de ofertas y gestión de ofertas guardadas por usuario.

## Requisitos

- Node.js 20 o superior.
- npm 9 o superior.
- No requiere un servidor de base de datos: la v1 usa SQLite a través de Prisma.

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
| `DATABASE_URL` | Sí | `file:./dev.db` | Ruta SQLite relativa al directorio `prisma` |
| `JWT_SECRET` | Sí | - | Secreto de firma, mínimo 32 caracteres |
| `JWT_EXPIRES_IN` | No | `7d` | Vigencia del token |
| `CORS_ORIGINS` | No | `*` | Orígenes permitidos separados por coma |
| `LOG_LEVEL` | No | `info` | Nivel de pino: `fatal` a `silent` |

La aplicación valida la configuración al arrancar y falla con un mensaje claro si falta algo.

## Puesta en marcha

```bash
npm run db:generate   # genera el cliente Prisma
npm run db:migrate    # aplica las migraciones (crea dev.db)
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
- Base SQLite aislada en `prisma/test.db`, recreada antes de cada ejecución.
- 36 pruebas en tres suites: autenticación, ofertas y ofertas guardadas.

Resultado de referencia en este entorno: 3 suites y 36 pruebas aprobadas.

## Estructura

```
backend/
  prisma/
    schema.prisma          modelo de datos SQLite
    seed.js                semilla de 18 ofertas y usuario demo
    migrations/            DDL versionado con restricciones CHECK
  scripts/
    prepare-test-db.js     recrea la base de prueba
    testDatabase.js        rutas de la base de prueba
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

## Cambiar a PostgreSQL

1. Cambia `provider = "sqlite"` por `"postgresql"` en `prisma/schema.prisma`.
2. Actualiza `DATABASE_URL` con la cadena de conexión.
3. Borra `prisma/migrations` y genera una migración inicial nueva con `npx prisma migrate dev --name init`.
4. Ajusta las restricciones `CHECK` de municipios si usas otro catálogo.

Los repositorios, servicios y la aplicación móvil no requieren cambios.
