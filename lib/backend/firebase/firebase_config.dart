import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBxR3zELG8A8WyJvZQabkpqwFQR6DvTbPU",
        authDomain: "viora-b75f7.firebaseapp.com",
        projectId: "viora-b75f7",
        storageBucket: "viora-b75f7.firebasestorage.app",
        messagingSenderId: "227687828358",
        appId: "1:227687828358:web:a41b8a500f2a68829e7a07",
        measurementId: "G-6HRS6SBC1H",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
}
