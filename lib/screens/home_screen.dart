import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../constants.dart';
import '../managers/asset_manager.dart';
import '../managers/data/data_manager.dart';
import '../managers/prompt_manager.dart';
import '../managers/version_manager.dart';
import '../models/prompt.dart';
import '../models/user_model.dart';
import '../ui/custom_scaffold.dart';
import '../ui/theme_extensions.dart';

bool didCheckForUpdates = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    if (!kIsWeb && Platform.isWindows) {
      runUpdateCheck();
    }
  }

  Future<void> runUpdateCheck() async {
    final box = Hive.box(Constants.settings);
    if (!box.get(Constants.checkForUpdates, defaultValue: true)) return;

    if (!didCheckForUpdates) {
      didCheckForUpdates = true;
    } else {
      return;
    }
    final Version? latestVersion =
        await VersionManager.instance.getLatestRelease();

    if (latestVersion == null) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = Version.parse(packageInfo.version);

    // enable this for testing update UI.
    // final latestVersion = Version(1, 0, 1);

    if (latestVersion > currentVersion) {
      showUpdateAvailableUI(latestVersion);
    }
  }

  void showUpdateAvailableUI(Version latestVersion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'A new version is available!',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onInverseSurface,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 34),
        showCloseIcon: true,
        duration: const Duration(days: 1),
        backgroundColor: context.colorScheme.inverseSurface,
        action: SnackBarAction(
          label: 'Download',
          textColor: context.colorScheme.inversePrimary,
          onPressed: () {
            launchUrlString(
                'https://github.com/SaadArdati/pocketjenna/releases/$latestVersion');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      automaticallyImplyLeading: false,
      leading: ScaffoldAction(
        tooltip: 'Settings',
        icon: Icons.settings,
        onTap: () {
          context.go('/settings', extra: {'from': '/home'});
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                const TokensTile(),
                const SizedBox(height: 16),
                const ExploreTile(),
                const SizedBox(height: 8),
                LayoutBuilder(builder: (context, constraints) {
                  final int crossAxisCount;

                  if (constraints.maxWidth <= 350) {
                    crossAxisCount = 1;
                  } else if (constraints.maxWidth <= 600) {
                    crossAxisCount = 2;
                  } else if (constraints.maxWidth <= 750) {
                    crossAxisCount = 3;
                  } else {
                    crossAxisCount = 4;
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    itemCount: PromptManager.instance.prompts.length,
                    itemBuilder: (context, index) {
                      final Prompt prompt =
                          PromptManager.instance.prompts.values.toList()[index];
                      // final bool isComingSoon;
                      // switch (type) {
                      //   case ChatType.general:
                      //   case ChatType.email:
                      //   case ChatType.documentCode:
                      //     isComingSoon = false;
                      //     break;
                      //   case ChatType.scientific:
                      //   case ChatType.analyze:
                      //   case ChatType.readMe:
                      //     isComingSoon = true;
                      //     break;
                      // }
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: GPTCard(
                          prompt: prompt,
                          isComingSoon: false,
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TokensTile extends StatelessWidget {
  const TokensTile({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
        stream: DataManager.instance.userStream,
        initialData: DataManager.instance.currentUser,
        builder: (context, snapshot) {
          final UserModel? user = snapshot.data;
          return Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.symmetric(horizontal: 64),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: context.colorScheme.surface,
              border: Border.all(
                color: context.colorScheme.primary,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.generating_tokens_outlined,
                  color: context.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  '${user?.tokens ?? 'No'} Tokens',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
                // const Spacer(),
                // Container(
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(8),
                //     gradient: LinearGradient(
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //       colors: [
                //         context.colorScheme.secondary,
                //         context.colorScheme.secondary,
                //       ],
                //     ),
                //   ),
                //   clipBehavior: Clip.antiAlias,
                //   child: Stack(
                //     children: [
                //       Padding(
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 8, vertical: 4),
                //         child: Text(
                //           'Buy Tokens',
                //           style: context.textTheme.bodySmall?.copyWith(
                //             color: context.colorScheme.onSecondary,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ),
                //       Positioned.fill(
                //         child: Material(
                //           color: Colors.transparent,
                //           child: InkWell(
                //             onTap: () {
                //               showComingSoonDialog(context, 'Buy Tokens');
                //             },
                //           ),
                //         ),
                //       )
                //     ],
                //   ),
                // ),
              ],
            ),
          );
        });
  }
}

class ExploreTile extends StatelessWidget {
  const ExploreTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minWidth: 175),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: context.colorScheme.surface,
                border: Border.all(
                  color: context.colorScheme.primary,
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  hoverColor: context.colorScheme.primary.withOpacity(0.1),
                  splashColor: context.colorScheme.primary.withOpacity(0.2),
                  onTap: () {
                    // showComingSoonDialog(context, 'Make a new prompt');
                    context.go('/prompt-creator');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: context.colorScheme.onSurface,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Make A New Prompt',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minWidth: 175),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: context.colorScheme.surface,
                border: Border.all(
                  color: context.colorScheme.primary,
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  hoverColor: context.colorScheme.primary.withOpacity(0.1),
                  splashColor: context.colorScheme.primary.withOpacity(0.2),
                  onTap: () {
                    // showComingSoonDialog(context, 'Make a new prompt');
                    context.go('/prompt-market');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          color: context.colorScheme.onSurface,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Prompt Market',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GPTCard extends StatelessWidget {
  final Prompt prompt;
  final bool isComingSoon;

  const GPTCard({
    super.key,
    required this.prompt,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.vertical(
      top: Radius.circular(18),
      bottom: Radius.circular(80),
    );
    return Center(
      child: Container(
        constraints:
            const BoxConstraints(maxHeight: 200, minWidth: 175, maxWidth: 175),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: context.colorScheme.surface.withOpacity(0.9),
          border: Border.all(
            color: context.colorScheme.primary,
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                // splashColor: context.colorScheme.secondary,
                // highlightColor: context.colorScheme.secondaryContainer,
                onTap: isComingSoon
                    ? null
                    : () => context.go('/chat',
                        extra: {'promptID': prompt.id, 'from': '/home'}),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary,
                      ),
                      child: Text(
                        prompt.title,
                        maxLines: 2,
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: context.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          prompt.prompts[1],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                          style: context.textTheme.bodySmall!.copyWith(
                              color: context.colorScheme.onSurface,
                              fontSize: 10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: AssetManager.getPromptIcon(
                        prompt,
                        color: context.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isComingSoon)
              Center(
                child: Transform.rotate(
                  angle: -35 * pi / 180,
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: context.colorScheme.inverseSurface,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Coming Soon',
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: context.colorScheme.onInverseSurface,
                        ),
                      )),
                ),
              )
          ],
        ),
      ),
    );
  }
}
