# Fase 1 - Arquitectura de Bolívar Aprende y Trabaja

Documento técnico de referencia para la construcción de la aplicación móvil de consulta y publicación de ofertas laborales y académicas del departamento de Bolívar. Esta versión incorpora el ajuste aprobado durante la implementación: SQLite como motor de la v1.

## 1. Resumen ejecutivo

Bolívar Aprende y Trabaja centraliza en una sola aplicación móvil las oportunidades laborales y académicas disponibles en los 46 municipios del departamento. La solución se compone de dos entregables:

1. **API REST** en Node.js + Express, con autenticación JWT, validación de entrada y persistencia mediante Prisma.
2. **Aplicación móvil** en Flutter, con tema oscuro minimalista, CRUD completo de ofertas y gestión de ofertas guardadas por usuario.

El alcance es una v1 funcional de uso local o académico: no incluye integraciones con portales externos, notificaciones push, chat, mapas, geolocalización, roles administrativos, recuperación de contraseña, paginación infinita ni pruebas end-to-end.

## 2. Decisiones de arquitectura

### 2.1 Motores descartados

El entorno de desarrollo disponible no cuenta con Docker ni PostgreSQL instalados. Levantar un contenedor o un servidor de base de datos no era posible sin privilegios adicionales, lo que habría impedido ejecutar y verificar el CRUD durante la entrega.

### 2.2 Decisión: SQLite para la v1

Se usa SQLite mediante Prisma. La decisión queda aislada detrás de la capa de datos:

- El esquema Prisma declara `provider = "sqlite"`.
- Los repositorios concentran todas las consultas; servicios y controladores no conocen el motor.
- Las restricciones de negocio (tipo de oferta, modalidad y municipios de Bolívar) están declaradas tanto en la migración SQL como en los validadores de entrada.

**Consecuencia:** el sistema completo se puede ejecutar y probar en esta máquina con `npm install` y `npm run db:migrate`. Migrar a PostgreSQL implica cambiar el `provider`, ajustar el tipo de dato de los identificadores si se desea usar `uuid` nativo, regenerar la migración inicial y actualizar `DATABASE_URL`. Ninguna línea de servicios, controladores o de la aplicación Flutter depende del motor.

### 2.3 Estilo arquitectónico

Arquitectura en capas con dependencias unidireccionales:

```
routes -> controllers -> services -> repositories -> Prisma -> SQLite
                 |
          middlewares (auth, validación, errores, rate limit)
```

- **routes:** declara endpoints y encadena middlewares.
- **controllers:** traduce HTTP a llamadas de servicio; no contiene reglas de negocio.
- **services:** reglas de negocio, DTOs y errores de dominio (`AppError`).
- **repositories:** acceso a datos exclusivamente.
- **middlewares:** autenticación, validación con Zod, manejo centralizado de errores, límite de peticiones.
- **lib:** utilidades transversales (JWT, hash, logger, cliente Prisma).
- **constants / validators:** catálogos y esquemas compartidos.

En Flutter se usa una organización por funcionalidad con separación `data` / `presentation`:

```
lib/
  core/            tema, red, almacenamiento, utilidades y widgets base
  features/
    auth/          data (API, repositorio, usuario) + presentation (provider, pantallas)
    offers/        data (modelo, borrador, consulta, API, repositorio) + presentation
    navigation/    session gate, splash y drawer
    profile/       pantalla de perfil
  app.dart
  main.dart
```

## 3. Alcance funcional

### 3.1 Incluido

- Registro, inicio y cierre de sesión con JWT y contraseñas cifradas con bcrypt.
- Almacenamiento seguro del token en el dispositivo.
- CRUD de ofertas laborales y académicas.
- Listado con búsqueda por texto y filtros por tipo y municipio.
- Detalle de oferta con acciones de guardar, editar y eliminar.
- Ofertas guardadas por usuario (`saved_offers`), con guardado y desguardado idempotentes.
- Drawer con Inicio, Mis ofertas guardadas, Mi perfil y Cerrar sesión.
- Estados de carga, vacío y error con reintento; actualización por arrastre.
- Semilla con 18 ofertas distribuidas en municipios de Bolívar y un usuario de demostración.

### 3.2 Excluido explícitamente

Scrapers o integraciones con portales externos, notificaciones push, chat, mapas o geolocalización, roles administrativos, recuperación de contraseña, paginación infinita y pruebas end-to-end.

## 4. Personas y casos de uso

| Persona | Necesidad | Casos de uso principales |
| --- | --- | --- |
| Habitante de Bolívar en búsqueda de empleo | Encontrar vacantes cercanas y confiables | Registrarse, explorar, filtrar por municipio, guardar ofertas, ver detalle |
| Estudiante o egresado | Encontrar formación y becas | Filtrar por tipo académico, guardar programas, comparar instituciones |
| Institución o empresa publicadora | Difundir oportunidades | Publicar oferta, corregir datos, retirar una oferta vencida |

Flujos principales:

1. **Consulta:** inicio de sesión -> listado -> filtros/búsqueda -> detalle -> guardar.
2. **Publicación:** inicio -> botón Publicar oferta -> formulario validado -> detalle de la oferta creada.
3. **Mantenimiento:** detalle -> editar o eliminar con confirmación.
4. **Seguimiento:** drawer -> Mis ofertas guardadas -> detalle -> desguardar.

## 5. Stack técnico

### Backend

| Componente | Versión / elección | Motivo |
| --- | --- | --- |
| Node.js | 20 o superior | ESM nativo y soporte vigente |
| Express | 4.21 | Simplicidad y ecosistema de middlewares |
| Prisma | 6.x | Esquema tipado, migraciones versionadas |
| SQLite | vía Prisma | Ejecutable sin servidor externo en esta máquina |
| Zod | 3.x | Validación declarativa con mensajes en español |
| jsonwebtoken | 9.x | JWT HS256 con expiración de 7 días |
| bcryptjs | 2.x | Hash puro en JavaScript, sin compilación nativa |
| pino / pino-http | 9.x / 10.x | Registro estructurado con redacción de tokens |
| helmet, cors, express-rate-limit | versiones actuales | Endurecimiento HTTP básico |

### Aplicación móvil

| Componente | Versión / elección | Motivo |
| --- | --- | --- |
| Flutter | SDK 3.35 o superior (Dart 3.9) | Multiplataforma con un solo código |
| Provider | 6.x | Estado simple, explícito y testeable |
| dio | 5.x | Interceptores y mapeo centralizado de errores |
| flutter_secure_storage | 9.x | Token en Keystore / Keychain |
| intl | 0.19 | Fechas en español (`es_CO`) |
| Material 3 | Tema oscuro personalizado | Consistencia visual sin dependencias extra |

La tipografía es la sans-serif del sistema (Roboto en Android) con pesos 400 a 600. No se empaquetan archivos de fuente para evitar dependencias binarias en el repositorio; la familia puede cambiarse en `app_typography.dart` sin tocar las pantallas.

## 6. Modelo de datos

### 6.1 Entidades

- **users:** cuenta autenticada. `email` único, `password_hash` nunca se expone en la API.
- **offers:** oportunidad laboral o académica. `type` en (`job`, `academic`), `modality` en (`onsite`, `remote`, `hybrid`) y `municipality` restringido a los municipios de Bolívar.
- **saved_offers:** relación muchos a muchos entre usuarios y ofertas, con clave primaria compuesta `(user_id, offer_id)` y borrado en cascada.

### 6.2 DDL de referencia (SQLite)

```sql
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
  CONSTRAINT "offers_municipality_bolivar_check" CHECK ("municipality" IN (...46 municipios...))
);
CREATE INDEX "offers_type_idx" ON "offers"("type");
CREATE INDEX "offers_municipality_idx" ON "offers"("municipality");
CREATE INDEX "offers_created_at_idx" ON "offers"("created_at");

CREATE TABLE "saved_offers" (
  "user_id" TEXT NOT NULL,
  "offer_id" TEXT NOT NULL,
  "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("user_id", "offer_id"),
  CONSTRAINT "saved_offers_user_id_fkey" FOREIGN KEY ("user_id")
    REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "saved_offers_offer_id_fkey" FOREIGN KEY ("offer_id")
    REFERENCES "offers"("id") ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX "saved_offers_offer_id_idx" ON "saved_offers"("offer_id");
```

La lista completa de municipios vive en `backend/src/constants/municipalities.js` y en `mobile/lib/core/constants/municipalities.dart`; la migración replica la misma lista como restricción `CHECK`.

## 7. Contrato de API

Prefijo: `/api`. Formato JSON. Fechas en ISO 8601 UTC.

### 7.1 Autenticación

| Método | Ruta | Auth | Cuerpo | Respuesta |
| --- | --- | --- | --- | --- |
| POST | `/auth/register` | No | `fullName`, `email`, `password`, `passwordConfirmation` | 201 `{ token, user }` |
| POST | `/auth/login` | No | `email`, `password` | 200 `{ token, user }` |
| GET | `/auth/me` | Bearer | - | 200 `{ user }` |

`user` = `{ id, fullName, email, createdAt }`. El token es HS256 con `sub`, `email` y expiración configurable (7 días por defecto).

### 7.2 Ofertas

| Método | Ruta | Auth | Descripción |
| --- | --- | --- | --- |
| GET | `/offers` | Bearer | Listado. Query: `q`, `type`, `municipality`, `saved=true` |
| GET | `/offers/:id` | Bearer | Detalle |
| POST | `/offers` | Bearer | Crear oferta |
| PUT | `/offers/:id` | Bearer | Actualizar oferta |
| DELETE | `/offers/:id` | Bearer | Eliminar oferta (204) |
| POST | `/offers/:id/save` | Bearer | Guardar (idempotente) |
| DELETE | `/offers/:id/save` | Bearer | Desguardar (idempotente) |

Cuerpo de creación y actualización:

```json
{
  "title": "Operario de producción en planta de alimentos",
  "description": "Se requiere operario para la línea de empaque...",
  "type": "job",
  "institution": "Agrosur del Bolívar",
  "municipality": "El Carmen de Bolívar",
  "modality": "onsite"
}
```

Respuesta de listado:

```json
{
  "data": [
    {
      "id": "uuid",
      "title": "Operario de producción en planta de alimentos",
      "description": "Se requiere operario...",
      "type": "job",
      "institution": "Agrosur del Bolívar",
      "municipality": "El Carmen de Bolívar",
      "modality": "onsite",
      "isSaved": true,
      "createdAt": "2026-10-20T13:00:00.000Z",
      "updatedAt": "2026-10-20T13:00:00.000Z"
    }
  ],
  "total": 1
}
```

`isSaved` se calcula por usuario autenticado mediante la relación `saved_offers`; no existe estado global de guardado.

### 7.3 Errores

Formato único:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Revisa los campos marcados.",
    "details": [{ "field": "email", "message": "Ingresa un correo electrónico válido." }]
  }
}
```

| Código HTTP | Código de error | Situación |
| --- | --- | --- |
| 400 | `VALIDATION_ERROR`, `INVALID_JSON` | Datos inválidos |
| 401 | `UNAUTHORIZED`, `TOKEN_EXPIRED`, `INVALID_CREDENTIALS` | Sin token, token vencido o credenciales incorrectas |
| 404 | `NOT_FOUND`, `ROUTE_NOT_FOUND` | Recurso o ruta inexistente |
| 409 | `EMAIL_TAKEN`, `CONFLICT` | Correo ya registrado |
| 429 | `RATE_LIMITED` | Límite de peticiones excedido |
| 500 | `INTERNAL_ERROR` | Fallo no controlado (se registra, no se filtra detalle) |

## 8. Experiencia de usuario

### 8.1 Paleta y estilo

| Token | Valor | Uso |
| --- | --- | --- |
| `background` | `#0F0F12` | Fondo de pantalla |
| `surface` | `#1A1A1F` | Tarjetas, campos, drawer |
| `surfaceElevated` | `#22222A` | Menús, snackbars |
| `border` | `#2A2A32` | Bordes de 1 px |
| `accent` | `#4F8EF7` | Acciones primarias y selección |
| `accentSoft` | `#16243C` | Fondo de elementos seleccionados |
| `textPrimary` | `#F5F5F7` | Texto principal |
| `textSecondary` | `#A1A1AA` | Texto secundario |
| `danger` | `#F2555A` | Errores y acciones destructivas |

Reglas visuales: radio máximo de 12 px, sin sombras ni degradados, iconografía Material lineal, jerarquía por tamaño y peso tipográfico. El contraste de `textPrimary` y `textSecondary` sobre `surface` supera 4.5:1; los objetivos táctiles mínimos son 44 x 44 px.

### 8.2 Pantallas

1. **Splash / SessionGate:** verifica el token guardado y decide entre sesión y login.
2. **Inicio de sesión:** correo, contraseña, error en línea y acceso a registro.
3. **Registro:** nombre, correo, contraseña y confirmación con validación local.
4. **Inicio:** buscador, chips de tipo, selector de municipio, listado con arrastre para actualizar, FAB Publicar oferta.
5. **Detalle:** etiquetas de tipo y modalidad, institución, municipio, fecha, descripción, guardar y editar; menú con eliminar.
6. **Publicar / editar:** formulario validado con selección de tipo, modalidad y municipio.
7. **Mis ofertas guardadas:** mismo listado con `saved=true`, estado vacío con acceso al inicio.
8. **Mi perfil:** avatar con iniciales, nombre, correo y fecha de registro; cierre de sesión.
9. **Drawer:** encabezado con nombre y correo, navegación y cierre de sesión con confirmación.

Cada pantalla de datos implementa cuatro estados: carga, éxito, vacío y error con reintento.

## 9. Estado y acceso a datos

- Un `AuthProvider` global mantiene `AuthStatus` (`unknown`, `authenticated`, `unauthenticated`), el usuario y el error de autenticación.
- `ApiClient` centraliza dio, inyecta el token y traduce cualquier fallo a `ApiException` con código y mensajes en español. Un 401 dispara `handleSessionExpired`.
- `OffersProvider` se crea por pantalla de listado y se pasa explícitamente a las rutas de detalle y formulario, de modo que las mutaciones refrescan la lista que originó la navegación.
- La búsqueda aplica debounce de 350 ms; los filtros de tipo y municipio se envían al backend; `offers/list` conserva el orden por fecha descendente.
- Guardar y desguardar son idempotentes en la API y actualizan el estado local sin recargar toda la lista; en "Mis guardadas" la fila se elimina al desguardar.

## 10. Seguridad

- Contraseñas con bcrypt (12 rondas) y nunca devueltas por la API.
- JWT firmado con HS256, secreto mínimo de 32 caracteres validado al arrancar, expiración de 7 días.
- Token en `flutter_secure_storage` con `encryptedSharedPreferences` en Android.
- Todas las rutas de ofertas exigen `Bearer` y verifican que la cuenta siga existiendo.
- Validación de entrada con Zod en `body`, `query` y `params`, con límite de cuerpo de 100 KB.
- Helmet, CORS configurable y rate limit global y específico para autenticación y escrituras.
- Errores internos registrados con pino (con redacción de cabeceras sensibles) y respuesta genérica al cliente.
- El listado de ofertas es global para usuarios autenticados, pero `saved_offers` está aislado por usuario.

## 11. Plan de pruebas

### Backend (Jest + Supertest, base SQLite de prueba)

- Autenticación: registro válido, correo duplicado, contraseñas distintas, correo inválido, contraseña débil, login correcto e incorrecto, `/me` con y sin token, token vencido.
- Ofertas: creación autenticada, rechazo sin token, municipio fuera de Bolívar, tipo inválido, descripción corta, listado, filtros por tipo y municipio, búsqueda por texto, combinación de filtros, detalle, 404, id inválido, actualización, eliminación.
- Guardadas: guardar, idempotencia, desguardar, idempotencia, `saved=true` y aislamiento entre usuarios.
- La base de prueba se recrea con `scripts/prepare-test-db.js` antes de cada ejecución.

### Móvil (flutter_test)

- `validators_test.dart`: reglas de correo, contraseña, confirmación y campos de oferta.
- `offer_card_test.dart`: contenido de la tarjeta, acción de guardado y apertura del detalle.
- `state_view_test.dart`: estados vacío, error con reintento y carga.

No hay pruebas end-to-end, en línea con el alcance acordado.

## 12. Plan de entrega por sprints

| Sprint | Contenido | Criterio de cierre |
| --- | --- | --- |
| 1 | Esquema, migración, semilla, autenticación y estructura de la API | Registro/login funcionando y pruebas de autenticación en verde |
| 2 | CRUD de ofertas, filtros, guardadas y manejo de errores | Pruebas de ofertas y guardadas en verde |
| 3 | Aplicación Flutter, tema, pantallas, documentación y verificación | Flujo completo login -> listado -> detalle -> CRUD -> guardadas |

## 13. Riesgos y mitigaciones

| Riesgo | Impacto | Mitigación |
| --- | --- | --- |
| Migrar a PostgreSQL con diferencias de tipos | Medio | Acceso a datos aislado en repositorios; DDL y catálogos centralizados |
| Crecimiento del listado sin paginación | Medio | Índices por tipo, municipio y fecha; paginación fuera de alcance de la v1 |
| Token en un dispositivo comprometido | Alto | Almacenamiento seguro, expiración y cierre de sesión ante 401 |
| Datos de ofertas sin moderación | Medio | Alcance v1 sin roles administrativos; se documenta como evolución |
| Diferencias entre emulador y dispositivo físico | Bajo | `API_BASE_URL` configurable con `--dart-define` |
| Flujos de interfaz verificados en un dispositivo | Bajo | Recorrido funcional en Android 15; pendientes tabletas, orientación horizontal y TalkBack |
