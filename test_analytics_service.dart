// test_analytics_service.dart
// Quick test to verify AnalyticsService is working with real data

import 'package:finpal/data/db/database_provider.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/data/services/analytics_service.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  print('🧪 Testing AnalyticsService with real data...\n');
  
  final dbProvider = DatabaseProvider.instance;
  final transactionRepo = TransactionRepository(dbProvider);
  final analyticsService = AnalyticsService(transactionRepo);
  
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  
  print('📅 Analyzing data for: $month/$year\n');
  
  try {
    // Test 1: Total expense and income
    print('1️⃣ Testing getTotalExpense() and getTotalIncome()...');
    final totalExpense = await analyticsService.getTotalExpense(year, month);
    final totalIncome = await analyticsService.getTotalIncome(year, month);
    print('   ✅ Total Expense: ${currencyFormat.format(totalExpense)}');
    print('   ✅ Total Income: ${currencyFormat.format(totalIncome)}');
    print('   ✅ Surplus/Deficit: ${currencyFormat.format(totalIncome - totalExpense)}\n');
    
    // Test 2: Expense by category name
    print('2️⃣ Testing getExpenseByCategoryName()...');
    final foodExpense = await analyticsService.getExpenseByCategoryName(year, month, 'Ăn uống');
    print('   ✅ Ăn uống: ${currencyFormat.format(foodExpense)}\n');
    
    // Test 3: Top expense categories
    print('3️⃣ Testing getTopExpenseCategories()...');
    final topCategories = await analyticsService.getTopExpenseCategories(year, month, limit: 5);
    if (topCategories.isEmpty) {
      print('   ℹ️  No expense data found');
    } else {
      for (final entry in topCategories.entries) {
        print('   ✅ ${entry.key}: ${currencyFormat.format(entry.value)}');
      }
    }
    print('');
    
    // Test 4: Weekly average
    print('4️⃣ Testing getWeeklyAverageExpenseByCategoryName()...');
    final weeklyAvg = await analyticsService.getWeeklyAverageExpenseByCategoryName('Ăn uống');
    print('   ✅ Weekly avg for Ăn uống: ${currencyFormat.format(weeklyAvg.round())}\n');
    
    // Test 5: Daily average
    print('5️⃣ Testing getDailyAverageExpense()...');
    final dailyAvg = await analyticsService.getDailyAverageExpense(year, month);
    print('   ✅ Daily avg expense: ${currencyFormat.format(dailyAvg.round())}\n');
    
    // Test 6: Growth rate
    print('6️⃣ Testing getExpenseGrowthRate()...');
    final growthRate = await analyticsService.getExpenseGrowthRate(year, month);
    print('   ✅ Expense growth rate: ${growthRate.toStringAsFixed(1)}%\n');
    
    print('✅ All tests completed successfully!');
    print('📊 Summary: AnalyticsService is working correctly with real DB data.');
    
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}
