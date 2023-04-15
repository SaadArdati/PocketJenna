import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';

import '../../constants.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/theme_extensions.dart';

class OnboardingScreen extends StatefulWidget {
  final Widget child;

  const OnboardingScreen({
    super.key,
    required this.child,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final bool viewingImage =
        GoRouter.of(context).location.contains('tray_position');
    return CustomScaffold(
      automaticallyImplyLeading: false,
      leading: viewingImage
          ? ScaffoldAction(
              onTap: () {
                context.go('/onboarding/two');
              },
              icon: Icons.arrow_back,
              tooltip: 'Back',
            )
          : ScaffoldAction(
              tooltip: 'Onboarding',
              icon: Icons.settings,
              onTap: () {
                context.go('/settings', extra: {'from': '/onboarding'});
              },
            ),
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: WillPopScope(
        onWillPop: () async => false,
        child: widget.child,
      ),
    );
  }
}

final Map<String, String> instructionIDs = {
  'windows_1': 'assets/instructions/windows_arrow_1.png',
  'windows_2': 'assets/instructions/windows_arrow_2.png',
  'macos': 'assets/instructions/macos_arrow.png',
};

class OnboardingWelcome extends StatelessWidget {
  const OnboardingWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            'Welcome to',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
            'Pocket Jenna',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.75,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            "Let's get you set up",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Material(
            color: context.colorScheme.primaryContainer,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              tooltip: 'Next',
              onPressed: () {
                context.go('/auth');
              },
              iconSize: 32,
              icon: const Icon(Icons.navigate_next),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class OnboardingDone extends StatelessWidget {
  const OnboardingDone({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "You're all set!",
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows ||
                  defaultTargetPlatform == TargetPlatform.macOS ||
                  defaultTargetPlatform == TargetPlatform.linux) ...[
                Text(
                  "The app will naturally live in your system's tray.",
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium,
                ),
                if (defaultTargetPlatform == TargetPlatform.windows) ...[
                  const SizedBox(height: 32),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: buildImage(context, 'windows_1'),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: buildImage(context, 'windows_2'),
                  ),
                ],
                if (defaultTargetPlatform == TargetPlatform.macOS) ...[
                  const SizedBox(height: 32),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: buildImage(context, 'macos'),
                  ),
                ],
              ],
              const SizedBox(height: 32),
              Material(
                color: context.colorScheme.primaryContainer,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  tooltip: 'Finish',
                  onPressed: () {
                    Hive.box(Constants.settings).put(
                      Constants.isFirstTime,
                      false,
                    );
                    if (!kIsWeb &&
                        defaultTargetPlatform == TargetPlatform.macOS) {
                      context.go('/onboarding/two/macos_onboarding');
                    } else {
                      context.go('/home', extra: {'from': '/onboarding'});
                    }
                  },
                  iconSize: 32,
                  icon: const Icon(Icons.navigate_next),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImage(BuildContext context, String id) {
    return Stack(
      children: [
        Image.asset(instructionIDs[id]!),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // Show full screen image in a dialog
                context.go(
                  '/onboarding/two/tray_position',
                  extra: {'instructionID': id},
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class InstructionView extends StatelessWidget {
  final String instructionID;

  const InstructionView({super.key, required this.instructionID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.background,
      body: Builder(builder: (context) {
        if (!instructionIDs.containsKey(instructionID)) {
          return const SizedBox.expand(
            child: Center(
              child: Text('Image not found'),
            ),
          );
        }

        return SizedBox.expand(
          child: InteractiveViewer(
            maxScale: 6,
            child: Image.asset(instructionIDs[instructionID]!),
          ),
        );
      }),
    );
  }
}
