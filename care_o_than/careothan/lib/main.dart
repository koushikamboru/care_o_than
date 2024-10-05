import 'package:flutter/material.dart';
import 'screens/registration_screen.dart';  // Assuming you have this screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(  // Removed `const` here
      title: 'Care-o-Than',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RegistrationScreen(),  // This can still be `const`
    );
  }
}
