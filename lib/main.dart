import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/root_app.dart';
import 'ui/viewmodels/dashboard_viewmodel.dart';
import 'ui/viewmodels/transaction_history_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionHistoryViewModel()),
      ],
      child: const FinPalApp(),
    ),
  );
}
