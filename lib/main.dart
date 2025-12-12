import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/screens/transaction_history_screen.dart';
import 'ui/viewmodels/transaction_history_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const TransactionHistoryScreen(),
      ),
    );
  }
}
