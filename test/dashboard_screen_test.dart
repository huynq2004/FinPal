import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finpal/ui/screens/dashboard_screen.dart';
import 'package:finpal/ui/viewmodels/dashboard_viewmodel.dart';

void main() {
  testWidgets('Dashboard renders balance and recent transactions', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<DashboardViewModel>(
        create: (_) => DashboardViewModel()..loadSummary(DateTime.now().year, DateTime.now().month),
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Còn lại'), findsOneWidget);
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
    expect(find.text('Phân loại chi tiêu'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('FAB opens ManualTransactionScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<DashboardViewModel>(
        create: (_) => DashboardViewModel()..loadSummary(DateTime.now().year, DateTime.now().month),
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Tap FAB
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Expect Manual Transaction screen to appear
    expect(find.text('Thêm giao dịch'), findsOneWidget);
  });
}
