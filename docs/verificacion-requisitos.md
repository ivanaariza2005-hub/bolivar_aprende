# Verificación de requisitos

Fecha de verificación: 25 de octubre de 2026.

## Entorno utilizado

| Herramienta | Versión / disponibilidad |
| --- | --- |
| Sistema operativo | Windows 11, x64 |
| Node.js | 24.22.0 |
| npm | 11.19.1 |
| Flutter SDK | 3.47.8 stable |
| Dart SDK | 3.13.7 |
| JDK | Eclipse Temurin 21.0.12 y JBR 25 (Android Studio) |
| Android SDK | 36.0.0 (platforms 35, 36 y 37.0; build-tools 36.0.0; NDK 28.2.13676358) |
| Gradle | 9.6.0 |
| Dispositivo de prueba | Teléfono Android 15 (API 35), depuración USB inalámbrica, misma red Wi-Fi que el equipo |
| Docker / PostgreSQL | No instalados |

## Resultado general

| Área | Estado |
| --- | --- |
| Backend implementado | Completo |
| Base de datos migrada y sembrada | Verificado |
| Pruebas automatizadas del backend | 36 de 36 aprobadas |
| Prueba de humo contra el servidor real | Aprobada |
| Aplicación Flutter implementada | Completa |
| Dependencias de Flutter resueltas | Verificado: `flutter pub get` |
| Análisis estático de Flutter | Verificado: sin hallazgos |
| Pruebas de Flutter | 17 de 17 aprobadas |
| Compilación de APK | Verificado: `flutter build apk --debug` genera `app-debug.apk` |
| Ejecución en dispositivo físico | Verificado: instalado, abierto y recorrido funcional completo |
| Scaffolding Android | Incluido en `mobile/android/` |

## Requisitos funcionales

| Requisito | Implementación | Evidencia | Estado |
| --- | --- | --- | --- |
| Registro con JWT y bcrypt | `backend/src/services/auth.service.js`, `src/lib/password.js`, `src/routes/auth.routes.js` | `tests/auth.test.js`: 5 pruebas de registro | Verificado |
| Inicio de sesión | `auth.service.login`, `AuthProvider.login` | 3 pruebas de login y prueba de humo con el usuario demo | Verificado |
| Cierre de sesión | `AuthProvider.logout`, drawer y perfil con confirmación | Revisión de código; no ejecutado en dispositivo | Implementado y compilado; no ejecutado en dispositivo |
| Token en almacenamiento seguro | `mobile/lib/core/storage/token_storage.dart` con `flutter_secure_storage` y `encryptedSharedPreferences` | Revisión de código | Implementado y compilado; no ejecutado en dispositivo |
| Creación de ofertas (POST) | `routes/offer.routes.js`, `offer.controller.js`, `offer.service.js`, `offer.repository.js` | Prueba automatizada y prueba de humo | Verificado |
| Listado de ofertas (GET) | `offer.repository.findMany` con orden por fecha descendente | Pruebas de listado y humo: 18 ofertas semilla | Verificado |
| Filtro por tipo | `listOffersQuerySchema`, `buildWhere` | Prueba `filtra por tipo` y humo con `type=academic` | Verificado |
| Filtro por municipio | Catálogo de 46 municipios en constantes, validadores y DDL | Prueba `filtra por municipio` y humo con `municipality=Cartagena` | Verificado |
| Búsqueda por texto | `q` sobre título, descripción e institución | Prueba `busca por texto` | Verificado |
| Detalle por identificador (GET) | `offer.controller.detail` | Pruebas de detalle, 404 e id inválido | Verificado |
| Actualización (PUT) | `offer.controller.update` y `offer.service.update` | Prueba de actualización y humo | Verificado |
| Eliminación (DELETE) | `offer.controller.remove`, respuesta 204 | Pruebas de eliminación y humo | Verificado |
| Guardar y desguardar | `savedOffer.repository`, rutas `POST/DELETE /offers/:id/save` idempotentes | 7 pruebas de guardadas y humo | Verificado |
| Aislamiento de guardadas por usuario | `savedBy` filtrado por `userId`, `GET /offers?saved=true` | Prueba `no mezcla las ofertas guardadas entre usuarios` | Verificado |
| Pantalla de inicio con búsqueda y filtros | `home_screen.dart`, `offers_filter_bar.dart`, `offers_list_body.dart` | Revisión de código | Implementado y compilado; no ejecutado en dispositivo |
| Pantalla de detalle | `offer_detail_screen.dart` | Revisión de código | Implementado y compilado; no ejecutado en dispositivo |
| Formulario de creación y edición | `offer_form_screen.dart` con validación local y selección de municipio | Revisión de código | Implementado y compilado; no ejecutado en dispositivo |
| Eliminación con confirmación | `confirm_dialog.dart` y `OfferDetailScreen._delete` | Revisión de código | Implementado y compilado; no ejecutado en dispositivo |
| Guardar desde la lista y el detalle | `OffersProvider.toggleSaved`, `OfferCard`, `OfferDetailScreen` | Revisión de código | Implementado y compilado; no ejecutado en dispositivo |
| Actualización por arrastre | `RefreshIndicator` en `offers_list_body.dart` | Revisión de código | Implementado y compilado; no ejecutado en dispositivo |
| Estados de carga, vacío y error con reintento | `state_view.dart`, `OffersStatus` | 3 pruebas de widget aprobadas | Verificado por pruebas |
| Mis ofertas guardadas | `saved_offers_screen.dart` con `savedOnly: true` | Revisión de código | Implementado y compilado; no ejecutado en dispositivo |
| Drawer con nombre y correo | `app_drawer.dart` | Revisión de código | Implementado y compilado; no ejecutado en dispositivo |
| Perfil | `profile_screen.dart` | Revisión de código | Implementado y compilado; no ejecutado en dispositivo |
| Semilla con al menos 15 ofertas | `prisma/seed.js` con 18 ofertas en 9 municipios (9 laborales y 9 académicas) | Consulta a la base sembrada: `ofertas=18 municipios=9`; guardadas demo: 3 | Verificado |

## Requisitos de diseño y calidad

| Requisito | Evidencia | Estado |
| --- | --- | --- |
| Fondo `#0F0F12`, superficie `#1A1A1F`, acento `#4F8EF7` | `mobile/lib/core/theme/app_colors.dart` | Verificado por revisión |
| Radio máximo de 12 px, sin sombras ni degradados | `app_theme.dart`, `app_card.dart` (`AppSpacing.cardRadius = 12`) | Verificado por revisión |
| Tipografía sans-serif | Tema con la fuente del sistema; no se empaquetó Inter por problemas de red | Ajuste documentado |
| Sin emojis | Búsqueda sobre 95 archivos propios: sin pictogramas | Verificado |
| Sin `console.log`, `print`, TODO ni código comentado | Búsquedas sobre `backend/src`, `backend/prisma`, `mobile/lib` y `mobile/test`: sin coincidencias | Verificado |
| Textos de interfaz en español, identificadores en inglés | Revisión de pantallas, mensajes de API y nombres de archivos | Verificado por revisión |
| Objetivos táctiles de 44 x 44 px | `AppSpacing.minTouchTarget`, botones e iconos del listado | Verificado por revisión |
| Soporte para lector de pantalla | `Semantics` en encabezados, estados y elementos seleccionables; `tooltip` en iconos | Verificado por revisión |
| Contraste AA | Combinaciones `#F5F5F7`/`#A1A1AA` sobre `#0F0F12` y `#1A1A1F` | Verificado por cálculo de luminancia |

## Documentación entregada

| Documento | Ruta |
| --- | --- |
| README raíz con instalación y ejecución | `README.md` |
| README del backend con contrato de API | `backend/README.md` |
| Documento de arquitectura de la fase 1 | `docs/fase-1-arquitectura.md` |
| Plantilla de variables de entorno | `backend/.env.example` |
| Lista de verificación | `docs/verificacion-requisitos.md` |

## Comandos ejecutados y resultados

```text
npm install                 -> 425 paquetes instalados
npx prisma generate         -> cliente Prisma 6.19.3 generado
npx prisma migrate deploy   -> migración 20260101000000_init aplicada, dev.db creada
npx prisma db seed          -> 18 ofertas, usuario demo y 3 guardadas
npm test                    -> 3 suites, 36 pruebas aprobadas
```

Prueba de humo contra `http://localhost:3000/api`:

```text
usuario: Usuario Demo / demo@bolivaraprende.co
ofertas semilla: 18
guardadas demo: 3
filtro academic+Cartagena: 3
creada: Prueba de humo de operador logistico
actualizada: Prueba de humo editada de operador logistico
guardar/desguardar: True / False
total despues de eliminar: 18
```

Verificación de la aplicación móvil:

```text
flutter pub get    -> dependencias resueltas (dio 5.11.1, flutter_secure_storage 9.2.4,
                      provider 6.1.5+1, intl 0.20.3, flutter_lints 4.0.0)
dart format lib test -> 49 archivos normalizados
flutter analyze    -> No issues found!
flutter test       -> 17 pruebas aprobadas en 3 archivos
flutter build apk --debug -> app-debug.apk generado (todas las arquitecturas; 151 MB sin
                      --dart-define y 180 MB con la URL del backend compilada)
adb install        -> Success en un teléfono con Android 15
am start           -> MainActivity en primer plano, sin excepciones en logcat
```

La compilación para el teléfono se hizo con `--dart-define=API_BASE_URL=http://<IP-del-equipo>:3000/api`. El teléfono y el equipo quedaron en la misma subred y se comprobó con `nc` que el puerto 3000 responde desde el dispositivo (401 sin token, como se espera).

Recorrido funcional ejecutado en el teléfono, contrastado con las peticiones registradas por el backend:

| Acción en la app | Resultado | Petición registrada |
| --- | --- | --- |
| Registro de una cuenta nueva | Sesión iniciada y listado visible | `POST /api/auth/register` 201 |
| Inicio de sesión con el usuario demo | Listado con las 18 ofertas | `POST /api/auth/login` 200, `GET /api/offers` 200 |
| Filtro por tipo Académica | Listado filtrado | `GET /api/offers?type=academic` 200 |
| Filtro por tipo Laboral | Listado filtrado | `GET /api/offers?type=job` 200 |
| Filtro por municipio Cartagena | Listado filtrado | `GET /api/offers?type=academic&municipality=Cartagena` 200 |
| Búsqueda "beca" | Dos resultados | `GET /api/offers?q=beca&type=academic` 200 |
| Búsqueda sin coincidencias | Estado vacío "No hay ofertas con estos filtros" | `GET /api/offers?q=zzzz` 200 |
| Guardar y quitar una oferta | Etiqueta del botón alterna entre Guardar y Quitar | `POST /api/offers/:id/save` 200 |
| Mis ofertas guardadas | Solo la oferta guardada | `GET /api/offers?saved=true` 200 |
| Detalle de una oferta | Título, entidad, municipio, modalidad, fechas y descripción | `GET /api/offers` 200 |
| Crear oferta | Navega al detalle de la oferta creada | `POST /api/offers` 201 |
| Editar oferta | Título actualizado en el detalle | `PUT /api/offers/:id` 200 |
| Eliminar oferta con confirmación | Vuelve al listado sin la oferta | `DELETE /api/offers/:id` 204 |
| Actualizar con pull-to-refresh | Nueva consulta del listado | `GET /api/offers` 200 |
| Backend detenido y filtro aplicado | Estado de error con "Reintentar" | sin respuesta |
| Reintentar con el backend activo | Listado cargado | `GET /api/offers?type=job` 200 |
| Mi perfil | Nombre, correo, fecha de alta y cierre de sesión | sin petición |
| Cerrar sesión | Vuelve al inicio de sesión | sin petición |

## Limitaciones declaradas

1. **La verificación en el teléfono se hizo por jerarquía de accesibilidad y registros del backend.** Confirma estructura, textos, navegación y llamadas a la API, pero no revisa visualmente colores, espaciados ni contraste en capturas de pantalla.
2. **Se probó en un solo dispositivo**, un teléfono con Android 15 y 720 x 1600 en vertical. No se validaron tabletas, orientación horizontal, tamaños de texto grandes ni lectores de pantalla (TalkBack).
3. **Sin conexión al arrancar la app se vuelve al inicio de sesión.** `AuthProvider.bootstrap` no distingue entre un token inválido y una caída de red: ante un error que no sea 401 conserva el token pero muestra la pantalla de inicio de sesión con el mensaje de error, y el usuario debe ingresar de nuevo cuando vuelva la conexión.
4. **No se empaquetó la fuente Inter.** Las descargas fallaron por red; se usa la sans-serif del sistema y el cambio es local a `app_typography.dart`.
5. **SQLite en lugar de PostgreSQL.** Decisión justificada en el documento de arquitectura; el procedimiento de migración está en `backend/README.md`.
6. **El APK de depuración se firma con la clave de depuración.** Para distribuir se debe configurar una firma de release y servir la API por HTTPS.

## Pasos para la verificación manual

```bash
cd backend
npm install
npm run db:generate
npm run db:migrate
npm run db:seed
npm run dev
```

En otra terminal, con el teléfono conectado por USB o depuración inalámbrica:

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://<IP-del-equipo>:3000/api
```

Para compilar e instalar el APK de depuración:

```bash
cd mobile
flutter build apk --debug --dart-define=API_BASE_URL=http://<IP-del-equipo>:3000/api
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.bolivaraprende.bolivar_aprende/.MainActivity
```

Recorrido ejecutado: inicio de sesión con `demo@bolivaraprende.co` / `Demo12345`, filtro por tipo y por municipio, búsqueda "beca", búsqueda sin resultados, detalle de una oferta, guardar y quitar de guardadas, Mis ofertas guardadas, crear una oferta, editarla, eliminarla, pull-to-refresh, estado de error con el backend detenido, reintento exitoso, Mi perfil y cierre de sesión.
