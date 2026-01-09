import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/db/database_provider.dart';
import 'data/repositories/smart_scan_config.dart';

import 'ui/screens/splash_screen.dart';

// ViewModels (Sprint 1)
import 'ui/viewmodels/dashboard_viewmodel.dart';
import 'ui/viewmodels/transaction_history_viewmodel.dart';
import 'ui/viewmodels/smart_scan_viewmodel.dart';
import 'ui/viewmodels/settings_viewmodel.dart';
import 'ui/viewmodels/budget_management_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Giữ DB init từ develop (Dev B / Dev C)
  await DatabaseProvider.instance.database;

  // Khởi tạo SmartScanConfig
  final smartScanConfig = await SmartScanConfig.create();

  runApp(FinPalApp(smartScanConfig: smartScanConfig));
}

class FinPalApp extends StatelessWidget {
  final SmartScanConfig smartScanConfig;
  
  const FinPalApp({super.key, required this.smartScanConfig});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Config provider (để share giữa các ViewModels)
        Provider<SmartScanConfig>.value(value: smartScanConfig),
        
        // ViewModels
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionHistoryViewModel()),
        ChangeNotifierProvider(create: (_) => SmartScanViewModel(smartScanConfig)),
        ChangeNotifierProvider(create: (_) => SettingsViewModel(smartScanConfig)),
        ChangeNotifierProvider(create: (_) => BudgetManagementViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FinPal',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const SplashScreen(),
      ),
    );
  }
}
