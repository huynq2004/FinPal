import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screens/dashboard_screen.dart';
import 'screens/ai_coach_screen.dart';
import 'screens/savings_goals_screen.dart';
import 'screens/smart_scan_screen.dart';
import 'screens/smart_scan_permission_screen.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;
  bool _hasSmsPermission = false;

  @override
  void initState() {
    super.initState();
    _checkSmsPermission();
  }

  Future<void> _checkSmsPermission() async {
    final status = await Permission.sms.status;
    setState(() {
      _hasSmsPermission = status.isGranted;
    });
  }

  void _handleTabChange(int newIndex) async {
    // Always refresh SMS permission when switching to Smart Scan tab
    if (newIndex == 1) {
      await _checkSmsPermission();
    }
    setState(() => _index = newIndex);
  }

  Widget _getPageAtIndex(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        // Show permission screen if no SMS permission, otherwise show Smart Scan
        return _hasSmsPermission 
            ? const SmartScanScreen()
            : SmartScanPermissionScreen(
                onNavigateToDashboard: () async {
                  // Re-check permission before navigating back
                  await _checkSmsPermission();
                  
                  if (_hasSmsPermission) {
                    // Permission granted, stay on Smart Scan tab to show scan screen
                    setState(() {});
                  } else {
                    // Permission not granted, go back to Dashboard
                    setState(() => _index = 0);
                  }
                },
              );
      case 2:
        return const SavingsGoalsScreen();
      case 3:
        return const AiCoachScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPageAtIndex(_index),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _handleTabChange,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Smart Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            activeIcon: Icon(Icons.savings),
            label: 'Hũ tiết kiệm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'Trợ lý AI',
          ),
        ],
      ),
    );
  }
}


