// lib/domain/models/ai_insight.dart

enum InsightType { warning, suggestion, info }

class AiInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final String categoryName;
  final double? spentAmount;
  final double? limitAmount;
  final int? daysRemaining;
  final double? avgDailySpending;
  final double? maxDailySpending;
  final List<SavingTip>? savingTips;

  const AiInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.categoryName,
    this.spentAmount,
    this.limitAmount,
    this.daysRemaining,
    this.avgDailySpending,
    this.maxDailySpending,
    this.savingTips,
  });

  double get usagePercentage {
    if (spentAmount == null || limitAmount == null || limitAmount == 0) {
      return 0;
    }
    return (spentAmount! / limitAmount!) * 100;
  }

  double get remainingAmount {
    if (spentAmount == null || limitAmount == null) return 0;
    return limitAmount! - spentAmount!;
  }
}

class SavingTip {
  final String id;
  final String title;
  final String description;
  final double savingsAmount;
  final bool isApplied;

  const SavingTip({
    required this.id,
    required this.title,
    required this.description,
    required this.savingsAmount,
    this.isApplied = false,
  });
}
