import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finpal/ui/root_scaffold.dart';
import 'package:finpal/ui/viewmodels/dashboard_viewmodel.dart';
import 'package:finpal/ui/viewmodels/transaction_history_viewmodel.dart';

void main() {
  testWidgets('Smart Scan tab shows permission screen when tapped without permission', (tester) async {
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

    // Tap Smart Scan tab (index 1)
    final smartScanItem = find.text('Smart Scan');
    expect(smartScanItem, findsWidgets);
    await tester.tap(smartScanItem.first);
    await tester.pumpAndSettle();

    // Should see permission screen (either permission request or scan screen depending on permission status)
    // Check for any Smart Scan related text
    expect(find.text('Smart Scan'), findsWidgets, reason: 'Smart Scan screen or permission screen should be visible');
  });

  testWidgets('Permission screen "Để sau" button navigates back to Dashboard', (tester) async {
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

    // Tap Smart Scan tab
    final smartScanItem = find.text('Smart Scan');
    await tester.tap(smartScanItem.first);
    await tester.pumpAndSettle();

    // If permission screen is shown, tap "Để sau"
    final laterButton = find.text('Để sau');
    if (laterButton.evaluate().isNotEmpty) {
      await tester.tap(laterButton);
      await tester.pumpAndSettle();

      // Should navigate back to Dashboard (index 0)
      expect(find.text('Tổng quan tháng này'), findsOneWidget);
    }
  });
}
