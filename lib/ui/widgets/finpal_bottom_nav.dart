import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Local SVG assets (place exported Figma icons here)
const _homeIconAsset = 'assets/icons/home.svg';
const _scanIconAsset = 'assets/icons/scan.svg';
const _savingsIconAsset = 'assets/icons/savings.svg';
const _aiIconAsset = 'assets/icons/ai.svg';

class FinPalBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FinPalBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 0.667,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              assetPath: _homeIconAsset,
              label: 'Tổng quan',
              index: 0,
              isActive: currentIndex == 0,
            ),
            _buildNavItem(
              assetPath: _scanIconAsset,
              label: 'Smart Scan',
              index: 1,
              isActive: currentIndex == 1,
            ),
            _buildNavItem(
              assetPath: _savingsIconAsset,
              label: 'Hũ tiết kiệm',
              index: 2,
              isActive: currentIndex == 2,
            ),
            _buildNavItem(
              assetPath: _aiIconAsset,
              label: 'Trợ lý AI',
              index: 3,
              isActive: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    String? assetPath,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: assetPath == null
                  ? Icon(
                      Icons.circle,
                      size: 24,
                      color: const Color(0xFF94A3B8),
                    )
                  : SvgPicture.asset(
                      assetPath,
                      width: 24,
                      height: 24,
                      // Icons are designed with grey strokes; keep original colors
                      placeholderBuilder: (_) => Icon(
                        Icons.circle,
                        size: 24,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? const Color(0xFF3E8AFF) : const Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
