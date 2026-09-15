import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6-TLl1cfA-pMxa34tDJ9Stn4XXYKGivQ',
    appId: '1:860001616686:android:7073d34f566c7fdc7270bf',
    messagingSenderId: '860001616686',
    projectId: 'parejasapp-4fec8',
    storageBucket: 'parejasapp-4fec8.appspot.com',
  );
}
