import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('BMS Monitor currently supports Firebase Auth on Web only.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCJZwnr1NfcoDAzFTBzkNsH2lCYTnpJMks',
    appId: '1:789194884617:web:a1800cd15e01b00a709ad8',
    messagingSenderId: '789194884617',
    projectId: 'bms-monitor-dashboard',
    authDomain: 'bms-monitor-dashboard.firebaseapp.com',
    storageBucket: 'bms-monitor-dashboard.firebasestorage.app',
  );
}
