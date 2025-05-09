// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkZECYxqc41ZD46uQnxSaCdE5NyzeqamU',
    appId: '1:448583690916:android:6d0dc1435e5d77f0461431',
    messagingSenderId: '448583690916',
    projectId: 'wrist-wise-dd98e',
    databaseURL: 'https://wrist-wise-dd98e-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'wrist-wise-dd98e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_XhEXcWqnhZlOugzDjF0fZ2UpxHHZJlU',
    appId: '1:448583690916:ios:76657bd7ba7653b4461431',
    messagingSenderId: '448583690916',
    projectId: 'wrist-wise-dd98e',
    databaseURL: 'https://wrist-wise-dd98e-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'wrist-wise-dd98e.firebasestorage.app',
    iosBundleId: 'com.example.notiftry',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD_XhEXcWqnhZlOugzDjF0fZ2UpxHHZJlU',
    appId: '1:448583690916:ios:76657bd7ba7653b4461431',
    messagingSenderId: '448583690916',
    projectId: 'wrist-wise-dd98e',
    databaseURL: 'https://wrist-wise-dd98e-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'wrist-wise-dd98e.firebasestorage.app',
    iosBundleId: 'com.example.notiftry',
  );
}
