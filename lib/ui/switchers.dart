import 'package:flutter/material.dart';

class CollapsableSwitcher extends StatefulWidget {
  final Widget child;
  final bool open;

  const CollapsableSwitcher({
    super.key,
    required this.child,
    required this.open,
  });

  @override
  State<CollapsableSwitcher> createState() => _CollapsableSwitcherState();
}

class _CollapsableSwitcherState extends State<CollapsableSwitcher> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInQuart,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: widget.open
          ? widget.child
          : const SizedBox.shrink(key: ValueKey('collapsed state')),
    );
  }
}
