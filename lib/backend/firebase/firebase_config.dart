import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDjhs5HFY4H2FOZZoWYwbxYVzB5yAEBwUQ",
            authDomain: "squadd-640af.firebaseapp.com",
            projectId: "squadd-640af",
            storageBucket: "squadd-640af.firebasestorage.app",
            messagingSenderId: "129801406213",
            appId: "1:129801406213:web:25eef66ebbacff1df7196c",
            measurementId: "G-17K17DM5ZR"));
  } else {
    await Firebase.initializeApp();
  }
}
