import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const DigitalBodaApp());
}

class DigitalBodaApp extends StatelessWidget {
  const DigitalBodaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigitalBoda',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}