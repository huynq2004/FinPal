// lib/notifications_center_demo.dart
// Demo file for testing Notifications Center screen
// Run with: flutter run lib/notifications_center_demo.dart

import 'package:flutter/material.dart';
import 'package:finpal/ui/screens/notifications_center_screen.dart';

void main() {
  runApp(const NotificationsCenterDemoApp());
}

class NotificationsCenterDemoApp extends StatelessWidget {
  const NotificationsCenterDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifications Center Demo',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arimo',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const NotificationsCenterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
