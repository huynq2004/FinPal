import 'package:flutter/material.dart';
import 'package:finpal/ui/screens/ai_coach_screen.dart';

void main() {
  runApp(const AiCoachDemo());
}

class AiCoachDemo extends StatelessWidget {
  const AiCoachDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Coach Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        fontFamily: 'Arimo',
      ),
      home: const AiCoachScreen(),
    );
  }
}
