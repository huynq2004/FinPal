import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/db/database_provider.dart';

import 'ui/root_scaffold.dart';

// ViewModels (Sprint 1)
import 'ui/viewmodels/dashboard_viewmodel.dart';
import 'ui/viewmodels/transaction_history_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Giữ DB init từ develop (Dev B / Dev C)
  await DatabaseProvider.instance.database;

  runApp(const FinPalApp());
}

class FinPalApp extends StatelessWidget {
  const FinPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionHistoryViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FinPal',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const RootScaffold(),
      ),
    );
  }
}
