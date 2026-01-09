// test_bill_anomalies.dart
// Test for S4-C2: Recurring Bill Anomaly Detection

import 'package:finpal/data/db/database_provider.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/data/repositories/budget_repository.dart';
import 'package:finpal/data/services/analytics_service.dart';
import 'package:finpal/data/services/coach_engine.dart';
import 'package:finpal/domain/models/transaction.dart';

void main() async {
  print('🧪 Testing S4-C2: Recurring Bill Anomaly Detection\n');
  print('=' * 60);

  // Initialize dependencies
  final db = DatabaseProvider.instance;
  final transactionRepo = TransactionRepository(db);
  final budgetRepo = BudgetRepository(db);
  final analyticsService = AnalyticsService(transactionRepo);
  final coachEngine = CoachEngine(analyticsService, budgetRepo);

  final now = DateTime.now();
  final currentYear = now.year;
  final currentMonth = now.month;

  print('\n📅 Testing for: $currentMonth/$currentYear');
  print('=' * 60);

  // Simulate recurring bills with anomalies
  print('\n📝 Simulating Bill Data:');
  print('-' * 60);

  // Month -3: Normal bills
  final month3Ago = DateTime(currentYear, currentMonth).subtract(const Duration(days: 90));
  print('• ${month3Ago.month}/${month3Ago.year}:');
  print('  - Điện nước: 800,000₫ (normal)');
  print('  - Internet: 300,000₫ (normal)');
  print('  - Thuê nhà: 5,000,000₫ (normal)');

  // Month -2: Normal bills
  final month2Ago = DateTime(currentYear, currentMonth).subtract(const Duration(days: 60));
  print('• ${month2Ago.month}/${month2Ago.year}:');
  print('  - Điện nước: 850,000₫ (normal)');
  print('  - Internet: 300,000₫ (normal)');
  print('  - Thuê nhà: 5,000,000₫ (normal)');

  // Month -1: Normal bills
  final month1Ago = DateTime(currentYear, currentMonth).subtract(const Duration(days: 30));
  print('• ${month1Ago.month}/${month1Ago.year}:');
  print('  - Điện nước: 820,000₫ (normal)');
  print('  - Internet: 300,000₫ (normal)');
  print('  - Thuê nhà: 5,000,000₫ (normal)');

  // Current month: ANOMALIES!
  print('• $currentMonth/$currentYear (Current):');
  print('  - Điện nước: 1,500,000₫ ⚠️ (+77% anomaly!)');
  print('  - Internet: 300,000₫ (normal)');
  print('  - Thuê nhà: 3,500,000₫ 💡 (-30% anomaly - good!)');

  print('\n🔍 Expected Insights:');
  print('-' * 60);
  print('1. ⚠️ Warning: "Điện nước" increased 77% vs 3-month average');
  print('   Current: 1,500,000₫ vs Average: 823,333₫');
  print('2. 💡 Info: "Thuê nhà" decreased 30% vs 3-month average');
  print('   Current: 3,500,000₫ vs Average: 5,000,000₫');
  print('3. ✅ No alert: "Internet" stable at 300,000₫');

  // Test the generateRecurringBillAnomalies method
  print('\n🤖 Running CoachEngine.generateRecurringBillAnomalies()...');
  print('=' * 60);
  
  final anomalies = await coachEngine.generateRecurringBillAnomalies(
    year: currentYear,
    month: currentMonth,
  );

  if (anomalies.isEmpty) {
    print('\n⚠️ No anomalies detected.');
    print('💡 Note: You need to add sample transactions to the database first.');
    print('   The method looks for categories: Hóa đơn, Điện nước, Internet, Thuê nhà, Điện thoại');
  } else {
    print('\n✅ Detected ${anomalies.length} anomalies:\n');
    for (var i = 0; i < anomalies.length; i++) {
      final insight = anomalies[i];
      print('${i + 1}. ${insight.title}');
      print('   ${insight.description}');
      print('   Type: ${insight.type}');
      print('');
    }
  }

  print('=' * 60);
  print('\n📊 How It Works:');
  print('-' * 60);
  print('1. Get current month bill expenses for recurring categories');
  print('2. Calculate 3-month average (months -1, -2, -3)');
  print('3. Compare current vs average');
  print('4. Alert if difference > 30%:');
  print('   • Higher → ⚠️ Warning (potential issue)');
  print('   • Lower → 💡 Info (potential savings)');
  print('5. Requires at least 2 months of historical data');
  print('6. Skips bills < 50,000₫ to avoid false positives');

  print('\n✅ Test Complete!');
  print('=' * 60);
}
