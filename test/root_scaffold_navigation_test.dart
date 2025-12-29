import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finpal/ui/root_scaffold.dart';
import 'package:finpal/ui/viewmodels/dashboard_viewmodel.dart';
import 'package:finpal/ui/viewmodels/transaction_history_viewmodel.dart';

void main() {
  testWidgets('RootScaffold -> Dashboard -> open TransactionHistoryScreen', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DashboardViewModel()..loadSummary(DateTime.now().year, DateTime.now().month)),
          ChangeNotifierProvider(create: (_) => TransactionHistoryViewModel()..loadFakeData()),
        ],
        child: const MaterialApp(home: RootScaffold()),
      ),
    );

    await tester.pumpAndSettle();

    // Tap history icon in dashboard header
    final historyIcon = find.byIcon(Icons.history);
    expect(historyIcon, findsWidgets);
    await tester.tap(historyIcon.first);
    await tester.pumpAndSettle();

    expect(find.text('Lịch sử giao dịch'), findsOneWidget);
  });
}
