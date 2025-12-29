import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/smart_scan_permission_screen.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardScreen(),
      SmartScanPermissionScreen(
        onNavigateToDashboard: () => setState(() => _index = 0),
      ),
      const SavingJarScreen(),
      const AiCoachScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
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


class SmartScanScreen extends StatelessWidget {
  const SmartScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Scan')),
      body: const Center(
        child: Text('Smart Scan sẽ làm ở sprint sau.'),
      ),
    );
  }
}

class SavingJarScreen extends StatelessWidget {
  const SavingJarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hũ tiết kiệm')),
      body: const Center(
        child: Text('Hũ tiết kiệm sẽ làm ở sprint sau.'),
      ),
    );
  }
}

class AiCoachScreen extends StatelessWidget {
  const AiCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trợ lý AI')),
      body: const Center(
        child: Text('Trợ lý AI sẽ làm ở sprint sau.'),
      ),
    );
  }
}
