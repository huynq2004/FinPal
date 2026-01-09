import 'package:flutter/material.dart';
import 'package:finpal/ui/screens/ai_insight_detail_screen.dart';
import 'package:finpal/domain/models/ai_insight.dart';
import 'package:finpal/domain/models/transaction.dart';

void main() {
  runApp(const AiInsightDetailDemo());
}

class AiInsightDetailDemo extends StatelessWidget {
  const AiInsightDetailDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final insight = AiInsight(
      id: '1',
      title: 'Chi ăn ngoài gần chạm hạn mức!',
      description: 'Bạn đã chi 70% hạn mức "Ăn ngoài" của tháng này. Còn 10 ngày nữa là hết tháng.',
      type: InsightType.warning,
      categoryName: 'Ăn uống',
      spentAmount: 3500000,
      limitAmount: 5000000,
      daysRemaining: 10,
      avgDailySpending: 350000,
      maxDailySpending: 150000,
      savingTips: const [
        SavingTip(
          id: '1',
          title: 'Giảm ăn ngoài',
          description: 'Mang cơm trưa 3 ngày/tuần',
          savingsAmount: 450000,
        ),
        SavingTip(
          id: '2',
          title: 'Hạn chế cafe',
          description: 'Từ 5 lần → 2 lần/tuần',
          savingsAmount: 360000,
        ),
        SavingTip(
          id: '3',
          title: 'Nấu ăn tối',
          description: 'Nấu ăn tối thay vì gọi đồ',
          savingsAmount: 600000,
        ),
      ],
    );

    final transactions = [
      Transaction(
        id: 1,
        amount: 120000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Ăn uống',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        note: 'THE COFFEE HOUSE',
        source: 'sms',
      ),
      Transaction(
        id: 2,
        amount: 85000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Ăn uống',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        note: 'GRAB FOOD',
        source: 'sms',
      ),
      Transaction(
        id: 3,
        amount: 65000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Ăn uống',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        note: 'PHO 24',
        source: 'sms',
      ),
      Transaction(
        id: 4,
        amount: 95000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Ăn uống',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 7)),
        note: 'HIGHLAND COFFEE',
        source: 'sms',
      ),
      Transaction(
        id: 5,
        amount: 110000,
        type: 'expense',
        categoryId: 1,
        categoryName: 'Ăn uống',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        note: 'LOTTERIA',
        source: 'sms',
      ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Insight Detail Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        fontFamily: 'Arimo',
      ),
      home: AiInsightDetailScreen(
        insight: insight,
        recentTransactions: transactions,
      ),
    );
  }
}
