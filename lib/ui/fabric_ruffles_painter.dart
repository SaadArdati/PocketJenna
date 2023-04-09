import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class FabricRufflesPainter extends CustomPainter {
  final Color color;
  final Color shade;
  final Color highlight;

  late final Paint mainPaint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  FabricRufflesPainter({
    required this.color,
    required this.shade,
    required this.highlight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()
      ..lineTo(0, 0)
      ..lineTo(0, size.height / 1.25)
      ..lineTo(size.width / 5, size.height)
      ..quadraticBezierTo(
          size.width / 2.8, size.height, size.width / 3, size.height / 2)
      ..lineTo(size.width / 2.5, 0)
      ..close();

    late final Paint shadePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height/ 2),
        [shade, shade.withOpacity(0)],
        [0.0, 1.0],
        TileMode.clamp,
        Matrix4.rotationZ(45 * pi / 180).storage,
      );

    canvas.drawPath(path, shadePaint);

    // path = Path()
    //   ..lineTo(size.width / 6, size.height)
    //   ..lineTo(size.width / 4, size.height)
    //   ..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
