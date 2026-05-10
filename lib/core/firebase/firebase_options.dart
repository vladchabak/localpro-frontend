import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAXAwtrTMu7U-55oHvK1BHuJNGjcjC3Ugo',
    appId: '1:325919771634:web:79094bc10075e6335e796b',
    messagingSenderId: '325919771634',
    projectId: 'localpro-9e4f1',
    authDomain: 'localpro-9e4f1.firebaseapp.com',
    storageBucket: 'localpro-9e4f1.firebasestorage.app',
  );
}
