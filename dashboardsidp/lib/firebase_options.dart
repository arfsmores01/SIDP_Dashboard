import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    } else {
      throw UnsupportedError(
        'DefaultFirebaseOptions are only supported for Web.',
      );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDPh-ymE7DAj84tjQ3vIXkWZXwfNh98HcU",
    authDomain: "sidp-5fcae.firebaseapp.com",
    databaseURL: "https://sidp-5fcae-default-rtdb.asia-southeast1.firebasedatabase.app",
    projectId: "sidp-5fcae",
    storageBucket: "sidp-5fcae.firebasestorage.app",
    messagingSenderId: "774496800704",
    appId: "1:774496800704:web:12ae2645771a23968b0225",
    measurementId: "G-YQT4Q3R47V"
  );
}