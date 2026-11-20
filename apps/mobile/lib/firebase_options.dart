// Configuración de Firebase generada para Aliento Andino.
// Solo Android está configurado por ahora — iOS se agrega cuando se publique.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions no configurado para Web. '
        'Generar con `flutterfire configure` si se necesita.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'FirebaseOptions no configurado para iOS. '
          'Generar con `flutterfire configure` si se necesita.',
        );
      default:
        throw UnsupportedError(
          'FirebaseOptions no soportado en esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDTAHls9jUEr9fsCezTbZbDRYKWvgDpjJ0',
    appId: '1:375288968446:android:d21978a52002f91b0fa1af',
    messagingSenderId: '375288968446',
    projectId: 'project-e18cb3de-8c18-45-ff093',
    storageBucket: 'project-e18cb3de-8c18-45-ff093.firebasestorage.app',
  );
}
