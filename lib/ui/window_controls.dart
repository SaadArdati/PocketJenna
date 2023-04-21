import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import '../constants.dart';
import '../managers/system_manager.dart';

class WindowControls extends StatelessWidget {
  const WindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = defaultTargetPlatform;
    final bool isWindows = !kIsWeb && platform == TargetPlatform.windows;
    final bool isDesktop = !kIsWeb &&
        (platform == TargetPlatform.windows ||
            platform == TargetPlatform.linux ||
            platform == TargetPlatform.macOS);

    final double? buttonSize = isDesktop ? 20 : null;
    return ValueListenableBuilder(
        valueListenable: Hive.box(Constants.settings).listenable(),
        builder: (context, box, child) {
          final bool showTitleBar = !isWindows && !kIsWeb;
          return Row(
            children: [
              if (isDesktop) ...[
                IconButton(
                  iconSize: buttonSize,
                  tooltip: 'Toggle window bounds',
                  icon: const Icon(Icons.reset_tv_outlined),
                  onPressed: SystemManager.instance.toggleWindowMemory,
                ),
                if (!showTitleBar) ...[
                  IconButton(
                    iconSize: buttonSize,
                    tooltip: 'Minimize',
                    icon: const Icon(Icons.minimize),
                    onPressed: SystemManager.instance.closeWindow,
                  ),
                  IconButton(
                    iconSize: buttonSize,
                    tooltip: 'Maximize',
                    icon: const Icon(Icons.maximize),
                    onPressed: SystemManager.instance.maximizeOrRestoreWindow,
                  ),
                  IconButton(
                    iconSize: buttonSize,
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: SystemManager.instance.closeWindow,
                  ),
                  // IconButton(
                  //   iconSize: buttonSize,
                  //   tooltip: 'Quit',
                  //   icon: const Icon(Icons.close),
                  //   onPressed: SystemManager.instance.quitApp,
                  // ),
                ],
                const SizedBox(width: 8),
              ],
            ],
          );
        });
  }
}
