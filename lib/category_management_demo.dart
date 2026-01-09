// lib/category_management_demo.dart
// Demo file for testing Category Management screen
// Run with: flutter run lib/category_management_demo.dart

import 'package:flutter/material.dart';
import 'package:finpal/ui/screens/category_management_screen.dart';

void main() {
  runApp(const CategoryManagementDemoApp());
}

class CategoryManagementDemoApp extends StatelessWidget {
  const CategoryManagementDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Category Management Demo',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arimo',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const CategoryManagementScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
