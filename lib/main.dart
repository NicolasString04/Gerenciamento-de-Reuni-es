import 'package:flutter/material.dart';
import 'package:myapp/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}
