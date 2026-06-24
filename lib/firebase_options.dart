// ⚠️ ARCHIVO MARCADOR DE POSICION (PLACEHOLDER).
//
// Estos valores son ficticios para que el proyecto COMPILE. La app NO se
// conectara a Firebase hasta que ejecutes:
//
//     flutterfire configure
//
// Ese comando SOBRESCRIBE este archivo con las credenciales reales de tu
// proyecto de Firebase. Consulta FIREBASE_SETUP.md para la guia completa.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opciones por defecto de Firebase para la app.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Plataforma no configurada. Ejecuta "flutterfire configure".',
        );
    }
  }

  // TODO: reemplazado automaticamente por `flutterfire configure`.

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbGSR2vHBUnFTjz-iq-LFpKgtDE9Z4uRU',
    appId: '1:491350582799:android:3d02cbc5292ece0595657a',
    messagingSenderId: '491350582799',
    projectId: 'smartstock-mobile',
    storageBucket: 'smartstock-mobile.firebasestorage.app',
  );
  // TODO: reemplazado automaticamente por `flutterfire configure`.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REEMPLAZAR-CON-FLUTTERFIRE-CONFIGURE',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'smartstock-placeholder',
    storageBucket: 'smartstock-placeholder.appspot.com',
    authDomain: 'smartstock-placeholder.firebaseapp.com',
  );
}
