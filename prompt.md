actua como administrador de base de datos de proyecto de restaurante italiano, qué entidades se necesitan para su gestión, las entidades con sus atributos y tipo de forma de tabla para cada una de las entidades y generar un script aparte en sql para descargar con el nombre "bdrestaurante.sql" para las entidades con sus relaciones
# 📋 Plan de Implementación: Aplicación "Restaurante Italiano" (Flutter + Firebase)

> ⚠️ **Nota previa sobre IDE**: VS Code es la opción estándar y ampliamente soportada para Flutter. "Antigravity" no es un IDE reconocido para desarrollo móvil/Flutter. Si te refieres a un editor específico o extensión personalizada, se recomienda validarlo primero. Este plan asume **VS Code** como entorno principal.

---

## 🛠️ Fase 1: Configuración del Entorno y Herramientas
1. **Instalación de SDKs y herramientas base**
   - Instalar Flutter SDK y Dart SDK (versión estable más reciente).
   - Configurar Git para control de versiones.
   - Instalar emuladores Android (Android Studio) y/o iOS (Xcode en macOS).
2. **Configuración de VS Code**
   - Instalar extensiones oficiales: `Flutter`, `Dart`, `Firebase`, `Pubspec Assist`, `Error Lens`, `Pubspec Lock`, `Code Spell Checker`.
   - Configurar formateo automático (`dart format`), linting (`flutter analyze`) y snippets personalizados.
3. **Configuración de Firebase**
   - Crear cuenta en Firebase Console.
   - Crear proyecto: `restaurante-italiano`.
   - Instalar Firebase CLI para emuladores locales (`firebase emulators:start`) y despliegue.
4. **Creación del proyecto Flutter**
   - Ejecutar `flutter create restaurante_italiano --org com.tuempresa`
   - Verificar ejecución en Android/iOS/Web antes de continuar.

---

## 📐 Fase 2: Arquitectura y Dependencias (`pubspec.yaml`)
1. **Estructura de carpetas (Feature-First / Clean Architecture)**
   ```
   lib/
   ├── src/
   │   ├── models/          # Entidades y mapeo JSON
   │   ├── providers/       # Gestión de estado con Provider
   │   ├── services/        # Firebase, API, almacenamiento local
   │   ├── screens/         # Vistas principales (login, menú, perfil, etc.)
   │   ├── widgets/         # Componentes reutilizables
   │   ├── routes/          # Configuración de navegación
   │   ├── utils/           # Constantes, validadores, formateadores
   │   └── config/          # Temas, rutas, inyección de dependencias
   └── main.dart
   ```
2. **Dependencias principales para `pubspec.yaml`** (solo nombres y propósito, sin bloques de código)
   - `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` → Backend y servicios de Firebase.
   - `provider` → Gestión de estado oficial recomendado por el equipo de Flutter.
   - `go_router` o `auto_route` → Navegación declarativa y rutas protegidas.
   - `intl` → Formateo de fechas, monedas y localización (ES/IT/EN).
   - `cached_network_image` → Carga y caché de imágenes de platos.
   - `flutter_dotenv` → Manejo seguro de variables de entorno.
   - `shared_preferences` o `hive` → Persistencia ligera local (preferencias de usuario).
   - `flutter_form_builder` + `formz` o validación nativa → Formularios robustos.
   - `flutter_svg` / `lottie` → Iconos y animaciones ligeras.
   - `flutter_launcher_icons`, `flutter_native_splash` → Assets de lanzamiento.
3. **Configuración inicial**
   - Ejecutar `flutter pub get` tras cada adición.
   - Verificar compatibilidad de versiones con `flutter pub outdated`.
   - Configurar `.env` para separar claves de desarrollo/producción.

---

## 🎨 Fase 3: Diseño UI/UX y Prototipado
1. **Identidad visual**
   - Paleta: tonos cálidos (terracota, oliva, crema, rojo italiano, negro carbón).
   - Tipografía: Serif elegante para títulos (ej. Playfair Display), Sans-serif legible para cuerpo (ej. Lato/Inter).
   - Iconografía: línea fina, estilo minimalista con acentos culinarios.
2. **Wireframes y flujos de usuario**
   - Onboarding → Login/Registro → Home (categorías/platos destacados) → Detalle de plato → Carrito/Reserva → Perfil.
   - Definir estados de carga, vacío, error y éxito para cada pantalla.
3. **Principios UX aplicados**
   - Feedback inmediato en acciones (toast, loaders, transiciones).
   - Accesibilidad: contraste WCAG AA, tamaños de texto escalables, soporte para lectores de pantalla.
   - Navegación consistente: barra inferior o drawer según complejidad.
4. **Sistema de diseño en Flutter**
   - Crear `AppTheme` con `ThemeData` unificado.
   - Desarrollar `Atomic Components`: Botones, Inputs, Cards, Badges, Loaders, Diálogos.
   - Validar responsividad con `MediaQuery`, `LayoutBuilder` y breakpoints.

---

## 🔐 Fase 4: Firebase y Autenticación (Email/Password)
1. **Vinculación de plataformas**
   - Registrar Android, iOS y Web en Firebase Console.
   - Descargar y ubicar `google-services.json` y `GoogleService-Info.plist`.
   - Configurar SHA-1/SHA-256 para Android (debug y release).
2. **Habilitar y configurar Auth**
   - Activar método `Email/Password` en Firebase Authentication.
   - Configurar plantillas de correo (verificación, recuperación de contraseña).
   - Establecer políticas de contraseñas y límites de intentos.
3. **Flujo de implementación lógica**
   - Servicio `AuthService`: `register`, `login`, `logout`, `resetPassword`, `updateEmail`.
   - Manejo de excepciones de Firebase (`FirebaseAuthException`) con mensajes localizados.
   - Persistencia de sesión automática (Firebase maneja el token; solo se expone el estado al UI).
4. **Validaciones UX**
   - Reglas de formato de email y contraseña en tiempo real.
   - Indicadores de seguridad de contraseña.
   - Redirección automática según estado de autenticación.

---

## 🔄 Fase 5: Gestión de Estado con Provider y Navegación
1. **Configuración de `MultiProvider`**
   - Envolver `MaterialApp` con proveedores globales: `AuthProvider`, `MenuProvider`, `CartProvider`, `ThemeProvider`.
   - Usar `ChangeNotifierProvider` para estado mutable y `Provider` para estado inmutable/servicios.
2. **Estructura de Providers**
   - `AuthProvider`: estado de usuario, `isLoading`, `errorMessage`, métodos de auth.
   - `MenuProvider`: carga de categorías y platos, filtros, favoritos.
   - `CartProvider`/`ReservationProvider`: ítems seleccionados, totales, sincronización con Firestore.
   - `UIProvider` (opcional): modo oscuro, idioma, preferencias de visualización.
3. **Navegación y Rutas**
   - Implementar `go_router` para rutas tipadas y protección.
   - Definir `redirect` en rutas: si `!user.isAuthenticated` → `/login`.
   - Transiciones suaves y gestión de back stack por plataforma.
4. **Optimización de renders**
   - Usar `Consumer` o `context.watch` solo donde se requiera actualización.
   - Separar widgets de presentación (`StatelessWidget`) de lógica (`ChangeNotifier`).

---

## 🗃️ Fase 6: Firestore y Lógica de Negocio del Restaurante
1. **Modelado de base de datos**
   - Colecciones: `users` (perfil, roles, historial), `categories`, `menu_items` (nombre, descripción, precio, imagen, disponibilidad), `orders`/`reservations` (estado, fecha, items, total).
   - Referencias vs. datos embebidos según frecuencia de lectura.
2. **Reglas de seguridad**
   - `users`: solo lectura/escritura por el propietario o admin.
   - `menu_items`: lectura pública, escritura solo por rol `staff`.
   - `orders/reservations`: creación por usuario autenticado, lectura por usuario o admin.
3. **Servicio de datos**
   - `FirestoreService`: métodos CRUD genéricos + streams para tiempo real.
   - Paginación (`limit`, `startAfterDocument`) para listas largas.
   - Manejo de desconexión y reintento con `retry` o `connectivity_plus`.
4. **Sincronización con Providers**
   - `MenuProvider` escucha `Stream<QuerySnapshot>` de `menu_items`.
   - Actualizaciones optimistas en carrito/reservas antes de confirmar en backend.
   - Validación de stock/disponibilidad antes de permitir checkout.

---

## 🧪 Fase 7: Pruebas, Optimización y Despliegue
1. **Estrategia de testing**
   - Unitarias: validadores, lógica de providers, mapeo de modelos.
   - Widget: formularios, navegación, componentes reutilizables.
   - Integración: flujo completo auth → menú → pedido → confirmación.
2. **Optimización de rendimiento**
   - Reducir rebuilds innecesarios con `const` widgets y `Provider.of(..., listen: false)`.
   - Caché de imágenes y respuestas de Firestore.
   - Perfilado con Flutter DevTools (CPU, Memory, Network).
3. **Preparación para producción**
   - Generar íconos adaptativos y splash screen.
   - Configurar `minSdkVersion`, `targetSdkVersion`, permisos de red/almacenamiento.
   - Firmar APK/App Bundle y configurar keystore seguro.
4. **Despliegue y distribución**
   - Beta: Firebase App Distribution o TestFlight.
   - Producción: Google Play Console + Apple App Store Connect.
   - Activar Crashlytics y Analytics para monitoreo post-lanzamiento.

---

## 📖 Fase 8: Documentación y Mantenimiento
1. **Documentación técnica**
   - Diagrama de arquitectura, flujo de datos, estructura de Firestore.
   - Guía de onboarding para nuevos desarrolladores.
   - Inventario de dependencias y política de actualizaciones.
2. **Automatización (CI/CD)**
   - GitHub Actions o Codemagic: lint, test, build, deploy automático.
   - Hooks pre-commit para `flutter format` y `flutter analyze`.
3. **Mantenimiento continuo**
   - Revisión mensual de dependencias (`flutter pub upgrade --major-versions`).
   - Auditoría de reglas de seguridad y permisos de Firebase.
   - Retroalimentación de usuarios → backlog de mejoras y parches.

---

✅ **Próximo paso**: Una vez validado y ajustado este plan, puedo proporcionarte el código base estructurado por fases (configuración, auth, providers, Firestore, UI), siempre siguiendo esta hoja de ruta. ¿Deseas que profundice en algún punto o ajustes específicos antes de pasar a la implementación técnica?
