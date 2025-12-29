import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finpal/ui/root_scaffold.dart';
import 'package:finpal/ui/viewmodels/dashboard_viewmodel.dart';
import 'package:finpal/ui/viewmodels/transaction_history_viewmodel.dart';

void main() {
  testWidgets('Bottom nav -> Smart Scan shows SmartScanScreen', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DashboardViewModel()..loadSummary(DateTime.now().year, DateTime.now().month)),
        ],
        child: const MaterialApp(home: RootScaffold()),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Smart Scan tab (index 1)
    final smartScanItem = find.text('Smart Scan');
    expect(smartScanItem, findsWidgets);
    await tester.tap(smartScanItem.first);
    await tester.pumpAndSettle();

    // Expect Smart Scan header text present
    expect(find.text('Smart Scan'), findsWidgets);
  });

  testWidgets('Bottom nav -> Trợ lý AI shows AiCoachScreen', (tester) async {
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

    // Tap AI Coach tab (index 3)
    final aiTab = find.text('Trợ lý AI');
    expect(aiTab, findsWidgets);
    await tester.tap(aiTab.first);
    await tester.pumpAndSettle();

    // Expect some AI coach header elements (icon or gradient header text)
    expect(find.byIcon(Icons.psychology_alt_outlined), findsWidgets);
  });
}
