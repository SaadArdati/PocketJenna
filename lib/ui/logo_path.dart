import 'dart:ui';

Path logoPath(Size size) {
  final Path path = Path();
  path.moveTo(size.width * 0.66, size.height * 0.8);
  path.cubicTo(size.width * 0.66, size.height * 0.8, size.width * 0.65,
      size.height * 0.8, size.width * 0.65, size.height * 0.8);
  path.cubicTo(size.width * 0.65, size.height * 0.8, size.width * 0.64,
      size.height * 0.81, size.width * 0.64, size.height * 0.81);
  path.cubicTo(size.width * 0.63, size.height * 0.88, size.width * 0.61,
      size.height * 0.93, size.width * 0.58, size.height * 0.96);
  path.cubicTo(size.width * 0.56, size.height, size.width * 0.54,
      size.height * 1.02, size.width * 0.52, size.height * 1.02);
  path.cubicTo(size.width * 0.49, size.height * 1.02, size.width * 0.47,
      size.height, size.width * 0.45, size.height * 0.96);
  path.cubicTo(size.width * 0.42, size.height * 0.93, size.width * 0.4,
      size.height * 0.88, size.width * 0.39, size.height * 0.81);
  path.cubicTo(size.width * 0.39, size.height * 0.81, size.width * 0.38,
      size.height * 0.8, size.width * 0.38, size.height * 0.8);
  path.cubicTo(size.width * 0.38, size.height * 0.8, size.width * 0.37,
      size.height * 0.8, size.width * 0.37, size.height * 0.8);
  path.cubicTo(size.width * 0.31, size.height * 0.82, size.width * 0.27,
      size.height * 0.81, size.width / 4, size.height * 0.78);
  path.cubicTo(size.width * 0.22, size.height * 0.76, size.width * 0.22,
      size.height * 0.72, size.width * 0.23, size.height * 0.66);
  path.cubicTo(size.width * 0.23, size.height * 0.66, size.width * 0.23,
      size.height * 0.65, size.width * 0.23, size.height * 0.65);
  path.cubicTo(size.width * 0.23, size.height * 0.65, size.width * 0.22,
      size.height * 0.64, size.width * 0.22, size.height * 0.64);
  path.cubicTo(size.width * 0.15, size.height * 0.63, size.width * 0.1,
      size.height * 0.61, size.width * 0.07, size.height * 0.58);
  path.cubicTo(size.width * 0.03, size.height * 0.56, size.width * 0.02,
      size.height * 0.54, size.width * 0.02, size.height * 0.52);
  path.cubicTo(size.width * 0.02, size.height * 0.49, size.width * 0.03,
      size.height * 0.47, size.width * 0.07, size.height * 0.45);
  path.cubicTo(size.width * 0.1, size.height * 0.42, size.width * 0.15,
      size.height * 0.4, size.width * 0.22, size.height * 0.39);
  path.cubicTo(size.width * 0.22, size.height * 0.39, size.width * 0.23,
      size.height * 0.38, size.width * 0.23, size.height * 0.38);
  path.cubicTo(size.width * 0.23, size.height * 0.38, size.width * 0.23,
      size.height * 0.37, size.width * 0.23, size.height * 0.37);
  path.cubicTo(size.width * 0.22, size.height * 0.31, size.width * 0.22,
      size.height * 0.27, size.width / 4, size.height / 4);
  path.cubicTo(size.width * 0.27, size.height * 0.22, size.width * 0.31,
      size.height * 0.22, size.width * 0.37, size.height * 0.23);
  path.cubicTo(size.width * 0.37, size.height * 0.23, size.width * 0.38,
      size.height * 0.23, size.width * 0.38, size.height * 0.23);
  path.cubicTo(size.width * 0.38, size.height * 0.23, size.width * 0.39,
      size.height * 0.22, size.width * 0.39, size.height * 0.22);
  path.cubicTo(size.width * 0.4, size.height * 0.15, size.width * 0.42,
      size.height * 0.1, size.width * 0.45, size.height * 0.07);
  path.cubicTo(size.width * 0.47, size.height * 0.03, size.width * 0.49,
      size.height * 0.02, size.width * 0.52, size.height * 0.02);
  path.cubicTo(size.width * 0.54, size.height * 0.02, size.width * 0.56,
      size.height * 0.03, size.width * 0.58, size.height * 0.07);
  path.cubicTo(size.width * 0.61, size.height * 0.1, size.width * 0.63,
      size.height * 0.15, size.width * 0.64, size.height * 0.22);
  path.cubicTo(size.width * 0.64, size.height * 0.22, size.width * 0.65,
      size.height * 0.23, size.width * 0.65, size.height * 0.23);
  path.cubicTo(size.width * 0.65, size.height * 0.23, size.width * 0.66,
      size.height * 0.23, size.width * 0.66, size.height * 0.23);
  path.cubicTo(size.width * 0.72, size.height * 0.22, size.width * 0.76,
      size.height * 0.22, size.width * 0.78, size.height / 4);
  path.cubicTo(size.width * 0.81, size.height * 0.27, size.width * 0.82,
      size.height * 0.31, size.width * 0.8, size.height * 0.37);
  path.cubicTo(size.width * 0.8, size.height * 0.37, size.width * 0.8,
      size.height * 0.38, size.width * 0.8, size.height * 0.38);
  path.cubicTo(size.width * 0.8, size.height * 0.38, size.width * 0.81,
      size.height * 0.39, size.width * 0.81, size.height * 0.39);
  path.cubicTo(size.width * 0.88, size.height * 0.4, size.width * 0.93,
      size.height * 0.42, size.width * 0.96, size.height * 0.45);
  path.cubicTo(size.width, size.height * 0.47, size.width * 1.02,
      size.height * 0.49, size.width * 1.02, size.height * 0.52);
  path.cubicTo(size.width * 1.02, size.height * 0.54, size.width,
      size.height * 0.56, size.width * 0.96, size.height * 0.58);
  path.cubicTo(size.width * 0.93, size.height * 0.61, size.width * 0.88,
      size.height * 0.63, size.width * 0.81, size.height * 0.64);
  path.cubicTo(size.width * 0.81, size.height * 0.64, size.width * 0.8,
      size.height * 0.65, size.width * 0.8, size.height * 0.65);
  path.cubicTo(size.width * 0.8, size.height * 0.65, size.width * 0.8,
      size.height * 0.66, size.width * 0.8, size.height * 0.66);
  path.cubicTo(size.width * 0.82, size.height * 0.72, size.width * 0.81,
      size.height * 0.76, size.width * 0.78, size.height * 0.78);
  path.cubicTo(size.width * 0.76, size.height * 0.81, size.width * 0.72,
      size.height * 0.82, size.width * 0.66, size.height * 0.8);
  path.cubicTo(size.width * 0.66, size.height * 0.8, size.width * 0.66,
      size.height * 0.8, size.width * 0.66, size.height * 0.8);
  path.close();

  return path;
}
