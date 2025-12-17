import 'package:flutter/material.dart';

class CategoryStat {
  final String name;
  final Color color;
  final double percent; // 0..1
  final int amount; // VND

  const CategoryStat({
    required this.name,
    required this.color,
    required this.percent,
    required this.amount,
  });
}
