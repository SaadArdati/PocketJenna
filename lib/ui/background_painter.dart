import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'logo_path.dart';

class BackgroundPainter extends CustomPainter {
  final double anim;
  final ui.Image asset;
  final List<Color> shades;

  final Path path = logoPath(const Size.square(100));

  final Random random = Random(2);
  late final List<Paint> paintShades = List.generate(shades.length, (i) {
    final Color shade1 = shades[random.nextInt(shades.length)];
    final Color shade2 = shades[random.nextInt(shades.length)];
    return Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(0, 100),
        [shade1, shade2],
        [0.0, 1.0],
        TileMode.clamp,
        Matrix4.rotationZ((random.nextInt(360) * pi / 180)).storage,
      );
  });

  BackgroundPainter({
    required this.anim,
    required this.asset,
    required this.shades,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double logoSize = 75;
    const double halfLogoSize = logoSize / 2;
    const double multiplier = 1.1; // makes it so edge logos are not cut off

    final double xLogoCount = (size.width / logoSize) * multiplier;
    final double yLogoCount = (size.height / halfLogoSize) * multiplier * 2;

    // Translate logos by half to center the overflowing grid.
    canvas.translate(
      -((xLogoCount * logoSize) / 2) + (size.width / 2) - (halfLogoSize),
      -((yLogoCount * halfLogoSize) / 2) + (size.height / 2) - (logoSize / 4),
    );

    // grid of logo
    for (int i = 0; i < xLogoCount; i++) {
      for (int j = 0; j < yLogoCount; j++) {
        final bool minor = j % 2 == 0;
        final double x = i * logoSize;
        final double y = j * halfLogoSize;
        final double scale = minor ? 0.35 : 0.5;

        if (minor) {
          canvas.translate(halfLogoSize, 0);
        }

        canvas.translate(x, y);

        canvas.translate(halfLogoSize, halfLogoSize);
        canvas.scale(scale);
        canvas.translate(-halfLogoSize, -halfLogoSize);

        canvas.drawPath(path, paintShades[(i + j) % paintShades.length]);
        // canvas.drawImage(asset, Offset.zero, patternShade1);

        // final textSpan = TextSpan(
        //   text: '${i + j}',
        //   style: const TextStyle(color: Colors.black),
        // );
        // final textPainter = TextPainter(
        //   text: textSpan,
        //   textDirection: TextDirection.ltr,
        // );
        // textPainter.layout();
        // canvas.translate(
        //   halfLogoSize - (textPainter.width / 2),
        //   halfLogoSize - (textPainter.height / 2),
        // );
        // textPainter.paint(canvas, Offset.zero);
        // canvas.translate(
        //   -halfLogoSize + (textPainter.width / 2),
        //   -halfLogoSize + (textPainter.height / 2),
        // );

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
      anim != oldDelegate.anim;
}
