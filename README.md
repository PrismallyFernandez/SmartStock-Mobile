# SmartStock Mobile

Aplicación móvil de **gestión de inventario y ventas para pequeños negocios**.

Proyecto de la asignatura **Seminario de Proyectos II (ISW-411)** — UAPA.

## Autor

- **Prismally Manuel Fernández Hernández** (100042497)

## Tecnologías

- Flutter (Dart)
- Android Studio
- Visual Studio
- Provider
- Clean Architecture
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

## Configuración

La aplicación utiliza Firebase como backend. Antes de ejecutarla por primera vez debes configurar tu proyecto siguiendo las instrucciones del archivo **FIREBASE_SETUP.md**.

## Ejecución

```bash
flutter pub get
flutterfire configure
flutter run
```

También puedes ejecutar:

```bash
flutter test
flutter analyze
```

## Funcionalidades

- Inicio de sesión de usuarios.
- Gestión de productos.
- Control de inventario.
- Registro de ventas.
- Gestión de clientes.
- Reportes para administradores.