# Bolívar Aprende y Trabaja

Aplicación móvil para consultar y publicar ofertas laborales y académicas en los 46 municipios del departamento de Bolívar, Colombia.

El repositorio contiene dos entregables:

- `backend/`: API REST en Node.js + Express con PostgreSQL en Supabase (Prisma), autenticación JWT y CRUD completo de ofertas.
- `mobile/`: aplicación Flutter con tema oscuro minimalista, búsqueda, filtros, ofertas guardadas y perfil.

## API desplegada

| Dato | Valor |
| --- | --- |
| URL base | `https://bolivar-aprende-api.onrender.com/api` |
| Estado | `GET https://bolivar-aprende-api.onrender.com/api/health` |
| Cuenta de prueba | `demo@bolivaraprende.co` / `Demo12345` |
| Hosting | Render (plan gratuito, se suspende a los 15 minutos sin tráfico) |

Para probar todas las rutas sin instalar nada: [`docs/guia-pruebas-api.md`](docs/guia-pruebas-api.md). Incluye una colección de Postman lista para importar en [`docs/bolivar-aprende.postman_collection.json`](docs/bolivar-aprende.postman_collection.json).

Documentación de referencia: [`docs/fase-1-arquitectura.md`](docs/fase-1-arquitectura.md).
Lista de verificación contra los requisitos: [`docs/verificacion-requisitos.md`](docs/verificacion-requisitos.md).

## Funcionalidades

- Registro, inicio y cierre de sesión con token JWT almacenado de forma segura.
- Listado de ofertas con búsqueda por texto, filtro por tipo (laboral o académica) y por municipio.
- Detalle de oferta, creación, edición y eliminación con confirmación.
- Guardar y quitar ofertas de "Mis ofertas guardadas", aisladas por usuario.
- Drawer con Inicio, Mis ofertas guardadas, Mi perfil y Cerrar sesión.
- Estados de carga, vacío y error con reintento; actualización por arrastre.
- Semilla con 18 ofertas reales de contexto y un usuario de demostración.

## Estructura del repositorio

```
api_crudApp/
  backend/            API REST, migraciones, semilla y pruebas
  mobile/             aplicación Flutter
  docs/               arquitectura y verificación de requisitos
  README.md
  .gitignore
```

## Inicio rápido del backend

Requisitos: Node.js 20 o superior.

```bash
cd backend
npm install
cp .env.example .env
npm run db:generate
npm run db:migrate
npm run db:seed
npm run dev
```

En Windows PowerShell usa `Copy-Item .env.example .env`.

La API queda disponible en `http://localhost:3000/api`.

Credenciales de demostración:

| Correo | Contraseña |
| --- | --- |
| `demo@bolivaraprende.co` | `Demo12345` |

El detalle de variables, endpoints y scripts está en [`backend/README.md`](backend/README.md).

## Inicio rápido de la aplicación móvil

Requisitos: Flutter 3.35 o superior (Dart 3.9 o superior) con el SDK de Android configurado. El proyecto se compiló con Flutter 3.47.8 y Dart 3.13.7, y el APK de depuración se instaló y abrió en un teléfono con Android 15.

El repositorio ya incluye el scaffolding de Android en `mobile/android/`, por lo que no hace falta ejecutar `flutter create`:

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

La compilación de Android requiere Java 17 o superior. El proyecto usa `minSdk 24`, `compileSdk 36` y el NDK que declara el SDK de Flutter. El permiso de Internet está en el manifiesto principal y el tráfico sin cifrar solo se habilita en las variantes `debug` y `profile` (`android/app/src/debug/AndroidManifest.xml` y `android/app/src/profile/AndroidManifest.xml`). Para una compilación de release sirve la API por HTTPS; el tráfico sin cifrar no está habilitado en `release`.

Ejecución contra el backend local:

```bash
# Emulador de Android: 10.0.2.2 es el host de la máquina
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api

# Dispositivo físico: usa la IP de tu máquina en la red local
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
```

El valor por defecto de `API_BASE_URL` es `http://10.0.2.2:3000/api`. El backend escucha en todas las interfaces (`app.listen`), así que un teléfono en la misma red puede alcanzarlo en `http://<IP-de-la-máquina>:3000/api`. Si el router aísla clientes o no quieres exponer el puerto, usa `adb reverse tcp:3000 tcp:3000` y compila con `API_BASE_URL=http://127.0.0.1:3000/api`.

Para instalar el APK ya compilado sin `flutter run`:

```bash
cd mobile
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.bolivaraprende.bolivar_aprende/.MainActivity
```

Un APK compilado sin `--dart-define` apunta a `10.0.2.2`, que solo funciona en el emulador: en un teléfono físico la app mostrará un error de conexión al iniciar sesión.

## Pruebas

Backend (38 pruebas, ejecutadas en este entorno):

```bash
cd backend
npm test
```

Móvil (verificado en este entorno con Flutter 3.47.8):

```bash
cd mobile
flutter analyze
flutter test
```

Resultado: `flutter analyze` sin hallazgos y 17 pruebas aprobadas. Las pruebas móviles cubren validadores, la tarjeta de oferta y los estados vacío, error y carga.

## Decisiones relevantes

- **PostgreSQL en Supabase.** El esquema se migró de SQLite a PostgreSQL (proyecto `ymtfgdybmyquqjpsncqc`, región `us-east-1`) conservando el modelo de datos. Prisma es la única fuente de verdad de las migraciones y la conexión usa el Session pooler porque la conexión directa solo resuelve IPv6.
- **Despliegue en Render.** El archivo `render.yaml` define el servicio; las migraciones corren al arrancar (`npm run start:deploy`) porque el plan gratuito no tiene pre-deploy command. La cadena de proxies de Render tiene tres saltos (`trust proxy`), lo que permite que el rate limit use la IP real del cliente.
- **JWT + bcrypt.** Token HS256 con expiración de 7 días y contraseñas con 12 rondas de bcrypt.
- **Provider + ChangeNotifier.** El `OffersProvider` se crea por pantalla de listado y se pasa a las rutas de detalle y formulario para refrescar la lista correcta.
- **Diseño oscuro minimalista.** Fondo `#0F0F12`, superficie `#1A1A1F`, acento `#4F8EF7`, radios de hasta 12 px, sin sombras ni degradados, iconografía Material y sin emojis.

## Alcance excluido

Scrapers o integraciones con portales externos, notificaciones push, chat, mapas o geolocalización, roles administrativos, recuperación de contraseña, paginación infinita y pruebas end-to-end.

## Estado de la entrega

El backend está implementado, migrado, sembrado y verificado con 36 pruebas automatizadas y una prueba de humo contra el servidor real.

La aplicación Flutter está implementada y verificada con `flutter pub get`, `flutter analyze` (sin hallazgos) y 17 pruebas de widget aprobadas. El APK de depuración compila (`flutter build apk --debug`), se instaló en un teléfono con Android 15 y se recorrió la app completa contra el backend real: registro, inicio de sesión, filtros, búsqueda, detalle, guardar y quitar, creación, edición, eliminación, estado de error con reintento y cierre de sesión. El detalle de cada paso está en [`docs/verificacion-requisitos.md`](docs/verificacion-requisitos.md).
