import 'package:flutter/material.dart';

class FinPalBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FinPalBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF3E8AFF),
      unselectedItemColor: const Color(0xFF94A3B8),
      backgroundColor: Colors.white,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Tổng quan'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: 'Smart Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.savings_rounded), label: 'Hũ tiết kiệm'),
        BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'Trợ lý AI'),
      ],
    );
  }
}
