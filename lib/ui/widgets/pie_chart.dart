import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/models/category_stat.dart';

class PieChart extends StatelessWidget {
  final List<CategoryStat> data;
  final double size;

  const PieChart({
    super.key,
    required this.data,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PiePainter(data),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<CategoryStat> data;

  _PiePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    double startRadian = -pi / 2; // bắt đầu từ đỉnh trên

    for (final item in data) {
      final sweepRadian = item.percent * 2 * pi;
      paint.color = item.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startRadian,
        sweepRadian,
        true, // true => hình quạt (kín)
        paint,
      );

      startRadian += sweepRadian;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
