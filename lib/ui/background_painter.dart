import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'logo_path.dart';

const double _logoSize = 75;

class BackgroundPainter extends CustomPainter {
  final Offset motion;
  final double rotation;
  final double chaos;
  final List<Color> shades;

  final Path path = logoPath(const Size.square(_logoSize));

  final Random random = Random(2);
  late final List<Paint> paintShades = List.generate(shades.length, (i) {
    final Color shade1 = shades[random.nextInt(shades.length - 1)];
    return Paint()..color = shade1;
  });

  BackgroundPainter({
    required this.motion,
    required this.rotation,
    required this.chaos,
    required this.shades,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double logoSize = _logoSize;
    const double halfLogoSize = logoSize / 2;

    final double maxCountX = (size.width / logoSize).ceilToDouble();
    final double maxCountY = (size.height / logoSize).ceilToDouble();

    final double maxExtentX = maxCountX * logoSize;
    final double maxExtentY = maxCountY * logoSize;

    final double xLogoCount = maxCountX;
    final double yLogoCount = maxCountY * 2.1;

    canvas.translate(
      -halfLogoSize - (maxExtentX / 2 * motion.dx),
      -halfLogoSize - (maxExtentY / 2 * motion.dy),
    );

    // grid of logo
    for (int i = 0; i < xLogoCount; i++) {
      for (int j = 0; j < yLogoCount; j++) {
        final bool minor = j % 2 == 0;
        final double x = i * logoSize;
        final double y = j * halfLogoSize;
        final double scale = (minor ? 0.4 : 0.6);

        if (minor) {
          canvas.translate(halfLogoSize, 0);
        }

        canvas.translate(x, y);

        final double sign = random.nextBool() ? 1 : -1;
        final double rotChaos = random.nextDouble() * 20 * chaos;
        final double xChaos = random.nextDouble() * 50 * chaos;
        final double yChaos = random.nextDouble() * 50 * chaos;

        canvas.translate(halfLogoSize, halfLogoSize);
        canvas.scale(scale);
        canvas.translate(-halfLogoSize, -halfLogoSize);

        final int index = i + j;
        final int shadeIndex =
            ((index % maxCountX) % paintShades.length).toInt();

        canvas.translate(xChaos, yChaos);
        canvas.translate(halfLogoSize, halfLogoSize);
        canvas.rotate((rotation + rotChaos) * sign * pi / 180);
        canvas.translate(-halfLogoSize, -halfLogoSize);

        canvas.drawPath(path, paintShades[shadeIndex]);

        canvas.translate(halfLogoSize, halfLogoSize);
        canvas.rotate(-(rotation + rotChaos) * sign * pi / 180);
        canvas.translate(-halfLogoSize, -halfLogoSize);
        canvas.translate(-xChaos, -yChaos);

        // canvas.scale(1/scale);
        // final textSpan = TextSpan(
        //   text: '$i - $j',
        //   style: const TextStyle(color: Colors.black),
        // );
        // final textPainter = TextPainter(
        //   text: textSpan,
        //   textDirection: TextDirection.ltr,
        // );
        // textPainter.layout();
        // textPainter.paint(canvas, Offset.zero);
        // canvas.scale(scale);

        canvas.translate(halfLogoSize, halfLogoSize);
        canvas.scale(1 / scale);
        canvas.translate(-halfLogoSize, -halfLogoSize);

        canvas.translate(-x, -y);

        if (minor) {
          canvas.translate(-halfLogoSize, 0);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) =>
      motion != oldDelegate.motion ||
      rotation != oldDelegate.rotation ||
      shades != oldDelegate.shades;
}
