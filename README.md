# SmartStock Mobile

Aplicación móvil de **gestión de inventario y ventas para pequeños negocios**.
Proyecto de la asignatura *Seminario de Proyectos II (ISW-411)* — UAPA.

- **Autor:** Prismally Manuel Fernández Hernández (100042497)
- **Stack:** Flutter (Dart) · Provider · Clean Architecture · Firebase
- **Diseño:** minimalista y profesional (modo claro)
  - Acento `#456EFD` · Texto/navy `#050914` · Superficies `#FFFFFF`

> **Backend:** la app usa **Firebase Authentication**, **Cloud Firestore** y
> **Firebase Storage**. Antes de ejecutarla por primera vez debes conectar tu
> proyecto de Firebase siguiendo **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)**
> (genera `lib/firebase_options.dart` con `flutterfire configure`).

## Cómo ejecutar

```bash
flutter pub get
# 1) Conecta Firebase una sola vez (ver FIREBASE_SETUP.md)
flutterfire configure
# 2) Corre la app con un emulador o dispositivo Android
flutter run

flutter test       # pruebas (usan un Firestore falso, no requieren red)
flutter analyze    # análisis estático
```

El inicio de sesión usa los usuarios que crees en Firebase Authentication, con
su perfil/rol en la colección `users` (ver guía de configuración).

## Arquitectura (Clean Architecture)

Cada módulo se divide en tres capas:

```
lib/
├── core/                     # Tema, colores, errores, utilidades, DI, Storage
│   ├── theme/  constants/  error/  utils/  widgets/  storage/  di/
└── features/
    ├── auth/                 # Inicio de sesión (RF-01..03)
    ├── products/             # Catálogo y CRUD (RF-04..07)
    ├── inventory/            # Movimientos, entradas, alertas (RF-08..10)
    ├── sales/                # Registro de ventas y comprobante (RF-11..13)
    ├── clients/              # Gestión de clientes
    ├── reports/              # Reportes — solo admin (RF-14..16)
    └── dashboard/            # Home + navegación
        ├── data/             # models · datasources · repositories (impl)
        ├── domain/           # entities · repositories (contratos) · usecases
        └── presentation/     # providers · pages · widgets
```

**Flujo de dependencias:** `presentation → domain ← data`.
La presentación solo conoce los *casos de uso*; el dominio define contratos; la
capa de datos los implementa. El cableado se hace en
[`core/di/service_locator.dart`](lib/core/di/service_locator.dart).

## Reglas de negocio implementadas

- El **código de producto** es único.
- No se permite **vender sin stock** suficiente.
- Toda venta **descuenta el stock** automáticamente y registra el movimiento.
- Los **reportes** solo son visibles para el rol *Administrador*.
- Alertas de **bajo inventario** según el umbral de cada producto.

## Cobertura de requerimientos

| Módulo      | Requerimientos |
|-------------|----------------|
| Auth        | RF-01, RF-02, RF-03 |
| Productos   | RF-04, RF-05, RF-06, RF-07 |
| Inventario  | RF-08, RF-09, RF-10 |
| Ventas      | RF-11, RF-12, RF-13 |
| Reportes    | RF-14, RF-15, RF-16 |

## Backend (Firebase)

- **Authentication:** inicio de sesión con correo/contraseña; el rol del usuario
  se lee de `users/{uid}` en Firestore.
- **Cloud Firestore:** colecciones `products`, `clients`, `sales`,
  `inventory_entries`, `users`. La venta se registra en una **transacción**
  (valida stock, lo descuenta y crea el movimiento de inventario).
- **Storage:** servicio listo en `core/storage/` para futuras imágenes de
  productos.

Configuración detallada en **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)**.

## Próximos pasos (Semana 4+)

1. Diseño/documentación formal de la base de datos en Firestore.
2. Pantalla de registro de usuarios para administradores.
3. Fotos de producto usando Firebase Storage (`core/storage/`).
