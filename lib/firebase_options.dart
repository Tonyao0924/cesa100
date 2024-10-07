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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAqmfjYrAYGkvJfP-bOTiRW15VHjF6JOp8',
    appId: '1:4231610679:web:57ddde7956f8b9d1fc1ab2',
    messagingSenderId: '4231610679',
    projectId: 'cesa100-6cdf5',
    authDomain: 'cesa100-6cdf5.firebaseapp.com',
    storageBucket: 'cesa100-6cdf5.appspot.com',
    measurementId: 'G-W2C8LNFKVH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmLqUFz1kuDevrwE76-ftbcSny7e6T4Vg',
    appId: '1:4231610679:android:146b1bdaad810914fc1ab2',
    messagingSenderId: '4231610679',
    projectId: 'cesa100-6cdf5',
    storageBucket: 'cesa100-6cdf5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBS8pZF7mepaZeHKVYxCbH_xB_ipklG_X4',
    appId: '1:4231610679:ios:6a873ebf379d3ab3fc1ab2',
    messagingSenderId: '4231610679',
    projectId: 'cesa100-6cdf5',
    storageBucket: 'cesa100-6cdf5.appspot.com',
    iosBundleId: 'com.ultrae.cesa100',
  );
}
