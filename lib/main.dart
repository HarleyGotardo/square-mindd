import 'package:android_mims_development/screens/login_screen.dart';
import 'package:android_mims_development/screens/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String email = prefs.getString('email') ?? '';

  runApp(MyApp(isLoggedIn: isLoggedIn, email: email));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String email;

  MyApp({required this.isLoggedIn, required this.email});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory and Sales Management System',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 0, 0, 0),
        hintColor: const Color.fromARGB(255, 0, 0, 0),
        fontFamily: 'Roboto',
      ),
      home: isLoggedIn ? MainPage(email: email) : const LoginPage(),
    );
  }
}