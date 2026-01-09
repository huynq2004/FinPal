// test_coach_engine.dart
// Test file to demonstrate CoachEngine generating insights

import 'package:finpal/data/db/database_provider.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/data/repositories/budget_repository.dart';
import 'package:finpal/data/services/analytics_service.dart';
import 'package:finpal/data/services/coach_engine.dart';

Future<void> main() async {
  print('🤖 Testing CoachEngine...\n');
  
  final dbProvider = DatabaseProvider.instance;
  final transactionRepo = TransactionRepository(dbProvider);
  final budgetRepo = BudgetRepository(dbProvider);
  final analyticsService = AnalyticsService(transactionRepo);
  final coachEngine = CoachEngine(analyticsService, budgetRepo);
  
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;
  
  print('📅 Generating insights for: $month/$year\n');
  
  try {
    // Test S3-C2: Budget warnings
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('S3-C2: Budget Limit Warnings (70% threshold)');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    final budgetWarnings = await coachEngine.generateBudgetWarnings(
      year: year,
      month: month,
    );
    
    if (budgetWarnings.isEmpty) {
      print('ℹ️  No budget warnings (all spending < 70% of limits)');
    } else {
      for (final warning in budgetWarnings) {
        print('${warning.type == 'warning' ? '⚠️' : '📊'} ${warning.title}');
        print('   ${warning.description}\n');
      }
    }
    print('');
    
    // Test S4-C1: Savings suggestions
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('S4-C1: Savings Suggestions Based on Habits');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    final savingsSuggestions = await coachEngine.generateSavingsSuggestions(
      year: year,
      month: month,
    );
    
    if (savingsSuggestions.isEmpty) {
      print('ℹ️  No savings suggestions (weekly spending < 100k)');
    } else {
      for (final suggestion in savingsSuggestions) {
        print('💡 ${suggestion.title}');
        print('   ${suggestion.description}\n');
      }
    }
    print('');
    
    // Test high spending alerts
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('High Spending Alerts');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    final highSpendingAlerts = await coachEngine.generateHighSpendingAlerts(
      year: year,
      month: month,
    );
    
    if (highSpendingAlerts.isEmpty) {
      print('ℹ️  No high spending alerts');
    } else {
      for (final alert in highSpendingAlerts) {
        print('📈 ${alert.title}');
        print('   ${alert.description}\n');
      }
    }
    print('');
    
    // Test balance alerts
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Balance Alerts (Surplus/Deficit)');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    final balanceAlerts = await coachEngine.generateBalanceAlerts(
      year: year,
      month: month,
    );
    
    if (balanceAlerts.isEmpty) {
      print('ℹ️  No balance alerts');
    } else {
      for (final alert in balanceAlerts) {
        print('${alert.type == 'warning' ? '⚠️' : '🎯'} ${alert.title}');
        print('   ${alert.description}\n');
      }
    }
    print('');
    
    // Test growth warnings
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Growth Rate Warnings');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    final growthWarnings = await coachEngine.generateGrowthWarnings(
      year: year,
      month: month,
    );
    
    if (growthWarnings.isEmpty) {
      print('ℹ️  No growth warnings (increase < 20%)');
    } else {
      for (final warning in growthWarnings) {
        print('📊 ${warning.title}');
        print('   ${warning.description}\n');
      }
    }
    print('');
    
    // Test monthly summary
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Monthly Summary');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    final summary = await coachEngine.generateMonthlySummary(
      year: year,
      month: month,
    );
    
    if (summary.isNotEmpty) {
      for (final msg in summary) {
        print('📊 ${msg.title}');
        print('   ${msg.description}\n');
      }
    }
    print('');
    
    // Test all insights combined
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('ALL INSIGHTS (Priority Ordered)');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    final allInsights = await coachEngine.generateAllInsights(
      year: year,
      month: month,
    );
    
    print('Total insights generated: ${allInsights.length}\n');
    for (int i = 0; i < allInsights.length; i++) {
      final insight = allInsights[i];
      print('${i + 1}. ${insight.title}');
      print('   Type: ${insight.type}');
      print('   ${insight.description}\n');
    }
    
    print('✅ CoachEngine test completed successfully!');
    print('');
    print('📊 Summary:');
    print('   - Budget Warnings: ${budgetWarnings.length}');
    print('   - Savings Suggestions: ${savingsSuggestions.length}');
    print('   - High Spending Alerts: ${highSpendingAlerts.length}');
    print('   - Balance Alerts: ${balanceAlerts.length}');
    print('   - Growth Warnings: ${growthWarnings.length}');
    print('   - Total Insights: ${allInsights.length}');
    
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}
