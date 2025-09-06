import 'package:flutter/material.dart';
import 'package:floating_bubbles_tasks/screens/home_screen.dart';

void main() {
  runApp(const FloatingBubblesApp());
}

class FloatingBubblesApp extends StatelessWidget {
  const FloatingBubblesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floating Bubbles Tasks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}