import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'theme_extensions.dart';

class BounceWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleStrength;
  final AxisDirection direction;

  const BounceWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.scaleStrength = 0.025,
    this.direction = AxisDirection.up,
  });

  @override
  State<BounceWrapper> createState() => _BounceWrapperState();
}

class _BounceWrapperState extends State<BounceWrapper> {
  bool isHovering = false;
  bool isHighlighting = false;
  bool isPressingDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() {
          isPressingDown = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressingDown = false;
          widget.onTap?.call();
        });
      },
      onTapCancel: () {
        setState(() {
          isPressingDown = false;
        });
      },
      child: FocusableActionDetector(
        onShowFocusHighlight: (bool highlight) {
          setState(() {
            isHighlighting = highlight;
          });
        },
        onShowHoverHighlight: (bool hover) {
          setState(() {
            isHovering = hover;
          });
        },
        actions: widget.onTap == null
            ? null
            : {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) => widget.onTap!.call(),
                ),
                ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
                  onInvoke: (_) => widget.onTap!.call(),
                ),
              },
        descendantsAreFocusable: false,
        descendantsAreTraversable: false,
        mouseCursor: SystemMouseCursors.click,
        child: Animate(
          target: isPressingDown ? 1 : 0,
          child: Animate(
            target: isHovering ? 1 : 0,
            child: widget.child,
          ).custom(
            curve: Curves.easeOutQuart,
            duration: 200.ms,
            builder: (context, value, child) {
              return Transform.translate(
                offset: switch (widget.direction) {
                  AxisDirection.up => Offset(0, value * -5),
                  AxisDirection.down => Offset(0, value * 5),
                  AxisDirection.left => Offset(value * -5, 0),
                  AxisDirection.right => Offset(value * 5, 0),
                },
                transformHitTests: false,
                child: child,
              );
            },
          ),
        ).custom(
          curve: Curves.easeOutQuart,
          duration: 200.ms,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1 + (value * widget.scaleStrength),
              transformHitTests: false,
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class FilledBounceButton extends StatefulWidget {
  final Widget label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final Color? primaryColor;
  final Color? onPrimaryColor;

  const FilledBounceButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.primaryColor,
    this.onPrimaryColor,
  });

  @override
  State<FilledBounceButton> createState() => _FilledBounceButtonState();
}

class _FilledBounceButtonState extends State<FilledBounceButton> {
  bool isHovering = false;
  bool isHighlighting = false;
  bool isPressingDown = false;

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: disabled
          ? null
          : (_) {
              setState(() {
                isPressingDown = true;
              });
            },
      onTapUp: disabled
          ? null
          : (_) {
              setState(() {
                isPressingDown = false;
                widget.onPressed?.call();
              });
            },
      onTapCancel: disabled
          ? null
          : () {
              setState(() {
                isPressingDown = false;
              });
            },
      child: FocusableActionDetector(
        onShowFocusHighlight: disabled
            ? null
            : (bool highlight) {
                setState(() {
                  isHighlighting = highlight;
                });
              },
        onShowHoverHighlight: disabled
            ? null
            : (bool hover) {
                setState(() {
                  isHovering = hover;
                });
              },
        actions: disabled
            ? null
            : {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) => widget.onPressed?.call(),
                ),
                ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
                  onInvoke: (_) => widget.onPressed?.call(),
                ),
              },
        descendantsAreFocusable: false,
        descendantsAreTraversable: false,
        mouseCursor: SystemMouseCursors.click,
        child: Animate(
          target: isPressingDown ? 1 : 0,
          child: Animate(
            target: isHovering ? 1 : 0,
            child: IconTheme.merge(
              data: IconThemeData(
                  color: widget.onPrimaryColor ?? context.colorScheme.onPrimary,
                  size: 22),
              child: DefaultTextStyle(
                style: context.textTheme.labelLarge!.copyWith(
                  color: widget.onPrimaryColor ?? context.colorScheme.onPrimary,
                ),
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (widget.primaryColor ?? context.colorScheme.primary)
                        .lighten(
                      isPressingDown || isHighlighting
                          ? 15
                          : isHovering
                              ? 5
                              : 0,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) widget.icon!,
                      if (widget.icon != null) const SizedBox(width: 8),
                      widget.label,
                    ],
                  ),
                ),
              ),
            ),
          ).custom(
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
        ).custom(
          curve: Curves.easeOutQuart,
          duration: 200.ms,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1 + value / 50,
              transformHitTests: false,
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class TextBounceButton extends StatefulWidget {
  final Widget? label;
  final Widget? icon;
  final Widget? child;
  final VoidCallback onPressed;
  final Color? primaryColor;
  final Color? onPrimaryColor;
  final BoxDecoration? decoration;

  const TextBounceButton({
    super.key,
    this.label,
    this.icon,
    this.child,
    this.primaryColor,
    this.onPrimaryColor,
    this.decoration,
    required this.onPressed,
  });

  @override
  State<TextBounceButton> createState() => _TextBounceButtonState();
}

class _TextBounceButtonState extends State<TextBounceButton> {
  bool isHovering = false;
  bool isHighlighting = false;
  bool isPressingDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressingDown = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressingDown = false;
          widget.onPressed();
        });
      },
      onTapCancel: () {
        setState(() {
          isPressingDown = false;
        });
      },
      child: FocusableActionDetector(
        onShowFocusHighlight: (bool highlight) {
          setState(() {
            isHighlighting = highlight;
          });
        },
        onShowHoverHighlight: (bool hover) {
          setState(() {
            isHovering = hover;
          });
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => widget.onPressed(),
          ),
          ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
            onInvoke: (_) => widget.onPressed(),
          ),
        },
        descendantsAreFocusable: false,
        descendantsAreTraversable: false,
        mouseCursor: SystemMouseCursors.click,
        child: Animate(
          target: isPressingDown ? 1 : 0,
          child: Animate(
            target: isHovering ? 1 : 0,
            child: IconTheme.merge(
              data: IconThemeData(
                  color: widget.primaryColor ?? context.colorScheme.primary,
                  size: 22),
              child: DefaultTextStyle(
                style: context.textTheme.labelLarge!.copyWith(
                  color: widget.primaryColor ?? context.colorScheme.primary,
                ),
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: widget.child != null
                      ? EdgeInsets.zero
                      : widget.icon != null && widget.label == null
                          ? const EdgeInsets.all(4)
                          : const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                  decoration: widget.decoration ??
                      BoxDecoration(
                        color: Colors.white.withOpacity(
                          isPressingDown || isHighlighting
                              ? 0.5
                              : isHovering
                                  ? 0.35
                                  : 0,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                  child: widget.child ??
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) widget.icon!,
                          if (widget.icon != null && widget.label != null)
                            const SizedBox(width: 8),
                          if (widget.label != null) widget.label!,
                        ],
                      ),
                ),
              ),
            ),
          ).custom(
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
        ).custom(
          curve: Curves.easeOutQuart,
          duration: 200.ms,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1 + value / 50,
              transformHitTests: false,
              child: child,
            );
          },
        ),
      ),
    );
  }
}
