# Guía para probar la API

Última actualización: 26 de octubre de 2026.

Esta guía permite probar todas las rutas de la API sin instalar el backend ni la base de datos: el servicio está desplegado y conectado a PostgreSQL en Supabase.

## 1. Dirección del servicio

| Dato | Valor |
| --- | --- |
| URL base | `https://bolivar-aprende-api.onrender.com/api` |
| Estado | `GET https://bolivar-aprende-api.onrender.com/api/health` |
| Repositorio | `https://github.com/ivanaariza2005-hub/bolivar_aprende` |
| Base de datos | PostgreSQL (Supabase, región `us-east-1`) |
| Despliegue | Render, región Virginia |

### Antes de empezar: el servicio se suspende

El plan gratuito de Render suspende la instancia tras **15 minutos sin tráfico**. La primera petición después de eso tarda entre **30 y 60 segundos** mientras arranca.

Antes de probar, abre esta dirección en el navegador:

```
https://bolivar-aprende-api.onrender.com/api/health
```

Cuando responda lo siguiente, el servicio ya está despierto y el resto de las pruebas será rápido:

```json
{ "status": "ok", "database": "connected" }
```

Si la primera vez ves un error de conexión o un tiempo de espera agotado, espera unos segundos y recarga. No es un fallo de la API.

## 2. Cuenta de prueba

| Correo | Contraseña |
| --- | --- |
| `demo@bolivaraprende.co` | `Demo12345` |

La base contiene **18 ofertas** publicadas por esta cuenta y **3 ofertas guardadas**. También se puede crear una cuenta nueva con `POST /api/auth/register`.

## 3. Cómo funciona la autenticación

1. Se envía `POST /api/auth/login` con correo y contraseña.
2. La respuesta incluye un `token` (JWT) que dura **7 días**.
3. Todas las rutas de `/api/offers` exigen la cabecera:

```
Authorization: Bearer <token>
```

4. Sin token o con un token vencido la respuesta es `401`.

## 4. Prueba rápida en PowerShell (Windows)

Copia y pega el bloque completo. Al final quedan creadas, editadas, guardadas y eliminadas ofertas de prueba.

```powershell
$BASE = "https://bolivar-aprende-api.onrender.com/api"

# 1. Despertar el servicio y comprobar la base de datos
Invoke-RestMethod -Uri "$BASE/health"

# 2. Iniciar sesión y guardar el token
$login = Invoke-RestMethod -Uri "$BASE/auth/login" -Method Post `
  -ContentType "application/json" `
  -Body '{"email":"demo@bolivaraprende.co","password":"Demo12345"}'
$token = $login.token

# 3. Cabecera que se reutiliza en todas las peticiones protegidas
$auth = @{ Authorization = "Bearer $token" }

# 4. Listar todas las ofertas (deben ser 18)
$ofertas = Invoke-RestMethod -Uri "$BASE/offers" -Headers $auth
$ofertas.total

# 5. Filtrar por tipo y municipio
(Invoke-RestMethod -Uri "$BASE/offers?type=academic&municipality=Cartagena" -Headers $auth).total

# 6. Buscar por texto (sin distinguir mayúsculas)
(Invoke-RestMethod -Uri "$BASE/offers?q=SENA" -Headers $auth).total

# 7. Consultar el detalle de una oferta
$id = $ofertas.data[0].id
Invoke-RestMethod -Uri "$BASE/offers/$id" -Headers $auth

# 8. Crear una oferta
$cuerpo = @{
  title        = "Instructor de logística portuaria"
  description  = "Formación técnica de 120 horas en operaciones portuarias y cadena de suministro para jóvenes de Cartagena."
  type         = "academic"
  institution  = "SENA"
  municipality = "Cartagena"
  modality     = "hybrid"
} | ConvertTo-Json

$creada = Invoke-RestMethod -Uri "$BASE/offers" -Method Post -Headers $auth `
  -ContentType "application/json" -Body $cuerpo
$creada.data.id

# 9. Editar la oferta recién creada
$edicion = @{
  title        = "Instructor de logística portuaria y aduanas"
  description  = "Formación técnica de 120 horas en operaciones portuarias, cadena de suministro y trámites de aduana."
  type         = "academic"
  institution  = "SENA"
  municipality = "Cartagena"
  modality     = "remote"
} | ConvertTo-Json

$nuevoId = $creada.data.id
(Invoke-RestMethod -Uri "$BASE/offers/$nuevoId" -Method Put -Headers $auth `
  -ContentType "application/json" -Body $edicion).data.title

# 10. Guardar y quitar de guardadas
Invoke-RestMethod -Uri "$BASE/offers/$nuevoId/save" -Method Post -Headers $auth
Invoke-RestMethod -Uri "$BASE/offers/$nuevoId/save" -Method Delete -Headers $auth

# 11. Eliminar la oferta de prueba (devuelve 204, sin cuerpo)
Invoke-RestMethod -Uri "$BASE/offers/$nuevoId" -Method Delete -Headers $auth
```

## 5. Prueba rápida con curl (macOS, Linux o Git Bash)

En Windows, dentro de PowerShell, usa `curl.exe` (no `curl`, que es un alias de `Invoke-WebRequest` y no entiende `-H`).

```bash
BASE=https://bolivar-aprende-api.onrender.com/api

# Estado del servicio
curl -s $BASE/health

# Iniciar sesión
curl -s -X POST $BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@bolivaraprende.co","password":"Demo12345"}'

# Copia el valor de "token" de la respuesta anterior y pégalo aquí
TOKEN=eyJhbGciOiJIUzI1NiIs...

# Listar ofertas
curl -s $BASE/offers -H "Authorization: Bearer $TOKEN"

# Filtrar (los nombres con tilde van codificados: Magangué -> Magangu%C3%A9)
curl -s "$BASE/offers?type=job&municipality=Magangu%C3%A9" -H "Authorization: Bearer $TOKEN"

# Buscar
curl -s "$BASE/offers?q=operario" -H "Authorization: Bearer $TOKEN"

# Crear
curl -s -X POST $BASE/offers \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Auxiliar de bodega",
    "description": "Apoyo en recepción, conteo y despacho de mercancía en la zona industrial de Mamonal.",
    "type": "job",
    "institution": "Logística del Caribe",
    "municipality": "Cartagena",
    "modality": "onsite"
  }'

# Eliminar (usa el id que devolvió la creación)
curl -s -X DELETE $BASE/offers/<ID> -H "Authorization: Bearer $TOKEN" -i
```

> Los nombres de municipio con tilde deben ir codificados en la URL: `Magangu%C3%A9` en lugar de `Magangué`.

## 6. Endpoints

| Método | Ruta | Token | Qué hace | Éxito |
| --- | --- | --- | --- | --- |
| `GET` | `/api/health` | No | Estado del servicio y de la base de datos | `200` |
| `POST` | `/api/auth/register` | No | Crear una cuenta | `201` |
| `POST` | `/api/auth/login` | No | Iniciar sesión y obtener el token | `200` |
| `GET` | `/api/auth/me` | Sí | Perfil del usuario autenticado | `200` |
| `GET` | `/api/offers` | Sí | Listar y filtrar ofertas | `200` |
| `GET` | `/api/offers/:id` | Sí | Detalle de una oferta | `200` |
| `POST` | `/api/offers` | Sí | Crear una oferta | `201` |
| `PUT` | `/api/offers/:id` | Sí | Editar una oferta (solo el dueño) | `200` |
| `DELETE` | `/api/offers/:id` | Sí | Eliminar una oferta (solo el dueño) | `204` |
| `POST` | `/api/offers/:id/save` | Sí | Guardar una oferta en la lista personal | `200` |
| `DELETE` | `/api/offers/:id/save` | Sí | Quitarla de la lista personal | `200` |

## 7. Detalle de cada endpoint

### `GET /api/health`

Sin token. Comprueba que el proceso responde y que la base contesta un `SELECT 1`.

```json
{ "status": "ok", "database": "connected" }
```

Si la base no responde devuelve `503` con `{ "status": "error", "database": "disconnected" }`.

### `POST /api/auth/register`

```json
{
  "fullName": "Laura Pineda",
  "email": "laura.pineda@example.com",
  "password": "Bolivar2026",
  "passwordConfirmation": "Bolivar2026"
}
```

Respuesta `201`:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "10c1a42f-b6dc-4073-bf94-3f33c8fed184",
    "fullName": "Laura Pineda",
    "email": "laura.pineda@example.com",
    "createdAt": "2026-10-26T02:17:41.000Z"
  }
}
```

Errores: `400` si falta un campo o no cumple las reglas, `409 EMAIL_TAKEN` si el correo ya existe.

### `POST /api/auth/login`

```json
{
  "email": "demo@bolivaraprende.co",
  "password": "Demo12345"
}
```

Respuesta `200` con la misma forma que el registro. Error `401 INVALID_CREDENTIALS` si el correo o la contraseña no coinciden.

### `GET /api/auth/me`

Cabecera `Authorization: Bearer <token>`. Respuesta `200`:

```json
{
  "user": {
    "id": "d0000000-0000-4000-8000-000000000001",
    "fullName": "Usuario Demo",
    "email": "demo@bolivaraprende.co",
    "createdAt": "2026-10-25T18:00:00.000Z"
  }
}
```

### `GET /api/offers`

Devuelve las ofertas ordenadas de la más reciente a la más antigua.

```json
{
  "data": [
    {
      "id": "a0000000-0000-4000-8000-000000000001",
      "title": "Operario de producción en planta de alimentos",
      "description": "Se requiere operario para la línea de empaque...",
      "type": "job",
      "institution": "Agrosur del Bolívar",
      "municipality": "El Carmen de Bolívar",
      "modality": "onsite",
      "ownerId": "d0000000-0000-4000-8000-000000000001",
      "isSaved": false,
      "createdAt": "2026-10-25T18:00:00.000Z",
      "updatedAt": "2026-10-25T18:00:00.000Z"
    }
  ],
  "total": 18
}
```

Filtros combinables:

| Parámetro | Valores | Ejemplo |
| --- | --- | --- |
| `q` | Texto libre, máximo 100 caracteres | `?q=operario` |
| `type` | `job` (laboral) o `academic` (académica) | `?type=academic` |
| `municipality` | Uno de los 46 municipios | `?municipality=Cartagena` |
| `saved` | `true` o `false` | `?saved=true` |

```bash
GET /api/offers?type=academic&municipality=Cartagena
GET /api/offers?q=sena
GET /api/offers?saved=true
```

`q` busca en **título, institución y descripción**, sin distinguir mayúsculas ni minúsculas.

### `GET /api/offers/:id`

```json
{ "data": { "id": "...", "title": "...", "...": "..." } }
```

`404 NOT_FOUND` si el identificador no existe. `400` si no tiene formato UUID.

### `POST /api/offers`

```json
{
  "title": "Instructor de logística portuaria",
  "description": "Formación técnica de 120 horas en operaciones portuarias y cadena de suministro.",
  "type": "academic",
  "institution": "SENA",
  "municipality": "Cartagena",
  "modality": "hybrid"
}
```

Respuesta `201` con `{ "data": { ...oferta } }`. El `ownerId` se toma del token, no se envía en el cuerpo.

### `PUT /api/offers/:id`

Mismo cuerpo que la creación, con todos los campos. Respuesta `200` con la oferta actualizada.

Solo el dueño puede editar. Cualquier otro usuario recibe `404` (se usa 404 en vez de 403 para no revelar que la oferta existe).

### `DELETE /api/offers/:id`

Respuesta `204` sin cuerpo. Solo el dueño. Otro usuario recibe `404`.

### `POST /api/offers/:id/save` y `DELETE /api/offers/:id/save`

```json
{ "data": { "offerId": "a0000000-...", "saved": true } }
```

Son idempotentes: guardar dos veces no genera error. La lista personal es independiente por usuario.

## 8. Reglas de validación

### Ofertas

| Campo | Regla |
| --- | --- |
| `title` | Texto de 5 a 120 caracteres |
| `description` | Texto de 20 a 2000 caracteres |
| `type` | `job` o `academic` |
| `institution` | Texto de 2 a 120 caracteres |
| `municipality` | Uno de los 46 municipios de Bolívar (nombre exacto) |
| `modality` | `onsite` (presencial), `remote` (virtual) o `hybrid` (híbrida) |

### Cuentas

| Campo | Regla |
| --- | --- |
| `fullName` | 3 a 80 caracteres |
| `email` | Correo válido, máximo 120 caracteres, se guarda en minúsculas |
| `password` | 8 a 64 caracteres, al menos una letra y un número |
| `passwordConfirmation` | Debe coincidir con `password` |

### Municipios aceptados

`Achí`, `Altos del Rosario`, `Arenal`, `Arjona`, `Arroyohondo`, `Barranco de Loba`, `Calamar`, `Cantagallo`, `Cartagena`, `Cicuco`, `Clemencia`, `Córdoba`, `El Carmen de Bolívar`, `El Guamo`, `El Peñón`, `Hatillo de Loba`, `Magangué`, `Mahates`, `Margarita`, `María La Baja`, `Montecristo`, `Morales`, `Norosí`, `Pinillos`, `Regidor`, `Río Viejo`, `San Cristóbal`, `San Estanislao`, `San Fernando`, `San Jacinto`, `San Jacinto del Cauca`, `San Juan Nepomuceno`, `San Martín de Loba`, `San Pablo`, `Santa Catalina`, `Santa Cruz de Mompox`, `Santa Rosa`, `Santa Rosa del Sur`, `Simití`, `Soplaviento`, `Talaigua Nuevo`, `Tiquisio`, `Turbaco`, `Turbaná`, `Villanueva`, `Zambrano`.

## 9. Formato de los errores

Todos los errores tienen la misma forma:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Revisa los campos marcados.",
    "details": [
      { "field": "municipality", "message": "Selecciona un municipio de Bolívar." }
    ]
  }
}
```

`details` solo aparece en los errores de validación.

| Código HTTP | Código interno | Cuándo |
| --- | --- | --- |
| `400` | `VALIDATION_ERROR` | Un campo falta o no cumple las reglas |
| `400` | `INVALID_JSON` | El cuerpo no es un JSON válido |
| `401` | `UNAUTHORIZED` | Falta el token, es inválido o la cuenta ya no existe |
| `401` | `INVALID_CREDENTIALS` | Correo o contraseña incorrectos en el login |
| `404` | `NOT_FOUND` | La oferta no existe o no pertenece al usuario |
| `409` | `EMAIL_TAKEN` | El correo ya está registrado |
| `429` | `RATE_LIMITED` | Se superó el límite de peticiones |
| `500` | `INTERNAL_ERROR` | Error inesperado del servidor |

## 10. Límites de peticiones

| Grupo | Límite |
| --- | --- |
| Todas las rutas | 300 peticiones cada 15 minutos |
| `/api/auth/login` y `/api/auth/register` | 20 cada 15 minutos |
| Escrituras (`POST`, `PUT`, `DELETE`) | 120 cada 15 minutos |

Cada respuesta incluye las cabeceras `Ratelimit-Limit`, `Ratelimit-Remaining` y `Ratelimit-Reset`. Si se supera, responde `429` con `RATE_LIMITED`; basta esperar unos minutos.

## 11. Demostrar el control de permisos

Las ofertas tienen dueño. Para comprobarlo en clase:

1. Inicia sesión con la cuenta demo y anota el `id` de una oferta.
2. Registra un segundo usuario con `POST /api/auth/register`.
3. Con el token del segundo usuario, intenta `DELETE /api/offers/<id>`.
4. La respuesta es `404` y la oferta sigue existiendo.
5. Repite con el token del dueño: responde `204`.

En la aplicación móvil esto se refleja en que el menú **Editar / Eliminar** solo aparece en las ofertas propias.

## 12. Colección de Postman

El archivo [`bolivar-aprende.postman_collection.json`](bolivar-aprende.postman_collection.json) contiene todas las peticiones organizadas por carpetas.

1. Abre Postman → **Import** → arrastra el archivo.
2. Ejecuta primero **Autenticación → Iniciar sesión**: el token se guarda automáticamente en la variable `token`.
3. Ejecuta **Ofertas → Crear oferta**: el `id` se guarda en la variable `offerId` para las peticiones siguientes.

La variable `baseUrl` ya apunta al servicio desplegado. Si quieres probar contra el backend local, cámbiala a `http://localhost:3000/api`.

## 13. Probar desde la aplicación Android

El APK de release ya está compilado contra el servicio desplegado:

```
mobile/build/app/outputs/flutter-apk/app-release.apk
```

Para instalarlo en un teléfono con depuración USB activada:

```powershell
adb install -r mobile\build\app\outputs\flutter-apk\app-release.apk
adb shell am start -n com.bolivaraprende.bolivar_aprende/.MainActivity
```

La aplicación ya apunta a `https://bolivar-aprende-api.onrender.com/api`; no hay que configurar nada. Se puede iniciar sesión con la cuenta demo o registrar una cuenta nueva.

## 14. Problemas frecuentes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| La primera petición tarda ~40 s o falla | Render suspendió la instancia por inactividad | Reintentar; el servicio ya está despierto |
| `401 UNAUTHORIZED` | Falta la cabecera o el token venció | Volver a hacer login y copiar el token nuevo |
| `404` al editar una oferta propia | Se está usando el token de otra cuenta | Usar el token del dueño (`ownerId`) |
| `400` con `details.municipality` | El municipio no está en la lista o falta la tilde | Copiar el nombre exacto de la sección 8 |
| `429 RATE_LIMITED` | Más de 20 logins o 300 peticiones en 15 minutos | Esperar a que se reinicie la ventana |
| `503` en `/api/health` | Supabase pausó el proyecto por inactividad (7 días) | Entrar al panel de Supabase y reanudar el proyecto |
| La app móvil no conecta | Se compiló sin `--dart-define` | Recompilar con la URL del servicio |
