import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finpal/ui/screens/transaction_history_screen.dart';
import 'package:finpal/ui/viewmodels/transaction_history_viewmodel.dart';

void main() {
  testWidgets('TransactionHistoryScreen shows transactions from viewmodel', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TransactionHistoryViewModel(),
        child: const MaterialApp(home: TransactionHistoryScreen()),
      ),
    );

    // allow post-frame callback to run and load fake data
    await tester.pumpAndSettle();

    expect(find.text('Lịch sử giao dịch'), findsOneWidget);

    // fake data contains 'GRAB' and 'Salary'
    expect(find.text('GRAB'), findsWidgets);
    expect(find.textContaining('Salary'), findsWidgets);

    // search action exists (appbar + text field prefix)
    expect(find.byIcon(Icons.search), findsWidgets);
    // search input and filter chips exist
    expect(find.byKey(const Key('history_search')), findsOneWidget);
    expect(find.byKey(const Key('chip_all')), findsOneWidget);
    // FAB to add transaction exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // Tap a transaction to open detail
    await tester.tap(find.text('GRAB').first);
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết giao dịch'), findsOneWidget);
    // The list item may still be present; ensure detail screen buttons show
    expect(find.text('Chỉnh sửa'), findsOneWidget);
    expect(find.textContaining('GRAB'), findsWidgets);
  });
}
