import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class JennaButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const JennaButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<JennaButton> createState() => _JennaButtonState();
}

class _JennaButtonState extends State<JennaButton> {
  bool isHovering = false;
  bool isPressingDown = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovering = false;
        });
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            isPressingDown = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            isPressingDown = false;
            widget.onTap();
          });
        },
        onTapCancel: () {
          setState(() {
            isPressingDown = false;
          });
        },
        child: Animate(
                target: isPressingDown || isHovering ? 1 : 0,
                child: widget.child)
            .custom(
          curve: Curves.easeOutQuart,
          duration: 200.ms,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, value * -5),
              transformHitTests: false,
              child: child,
            );
          },
        ),
      ),
    );
  }
}
