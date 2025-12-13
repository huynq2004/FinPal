import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/db/database_provider.dart';

import 'ui/screens/transaction_history_screen.dart';
import 'ui/viewmodels/transaction_history_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Giữ init DB từ develop
  final db = await DatabaseProvider.instance.database;
  // ignore: avoid_print
  print('DB path: ${db.path}');

  runApp(const FinPalApp());
}

class FinPalApp extends StatelessWidget {
  const FinPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionHistoryViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FinPal',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
        ),
        home: const TransactionHistoryScreen(),
      ),
    );
  }
}
