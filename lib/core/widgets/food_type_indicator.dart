import 'package:flutter/material.dart';

/// Indian-style veg / non-veg markers (matches Android icon_veg / icon_non_veg).
class FoodTypeIndicator extends StatelessWidget {
  const FoodTypeIndicator({
    super.key,
    required this.isVeg,
    this.size = 20,
  });

  final bool isVeg;
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderColor = isVeg ? const Color(0xFF017505) : const Color(0xFFE40000);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Center(
        child: isVeg
            ? Container(
                width: size * 0.35,
                height: size * 0.35,
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                ),
              )
            : CustomPaint(
                size: Size(size * 0.45, size * 0.45),
                painter: _NonVegTrianglePainter(borderColor),
              ),
      ),
    );
  }
}

class _NonVegTrianglePainter extends CustomPainter {
  _NonVegTrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
