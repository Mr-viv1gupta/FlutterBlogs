import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blogs/views/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: 'FlutterBlogs',
    debugShowCheckedModeBanner: false,
    home: HomePage(),
    theme: ThemeData.dark(),
  ));
}
