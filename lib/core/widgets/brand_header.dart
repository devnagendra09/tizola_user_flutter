import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TriangleClipper(),
      child: Container(
        width: double.infinity,
        color: AppColors.brand,
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        child: child,
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
