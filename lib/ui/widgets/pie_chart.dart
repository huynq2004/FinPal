import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  final List data;
  final double size;

  const PieChart({super.key, required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    // Minimal placeholder - real implementation should render a chart
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Center(child: Text('${data.length}')),
    );
  }
}