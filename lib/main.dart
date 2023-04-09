import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'dart:ui' as ui;

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:dart_openai/openai.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_io/io.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

import 'constants.dart';
import 'managers/asset_manager.dart';
import 'managers/auth/auth_manager.dart';
import 'managers/data/data_manager.dart';
import 'managers/navigation_manager.dart';
import 'managers/system_manager.dart';
import 'ui/background_painter.dart';
import 'ui/color_schemes.g.dart';
import 'ui/theme_extensions.dart';

void main() async {
  await PocketJenna.initPocketJenna();
  final mode = await AdaptiveTheme.getThemeMode() ?? AdaptiveThemeMode.system;
  runApp(PocketJenna(mode: mode));
}

class PocketJenna extends StatefulWidget {
  final AdaptiveThemeMode mode;

  const PocketJenna({super.key, required this.mode});

  static Future<bool> initPocketJenna() async {
    await Hive.initFlutter('PocketJenna');
    await Hive.openBox(Constants.history);

    final EncryptedSharedPreferences encryptedPrefs =
        EncryptedSharedPreferences();
    String key = await encryptedPrefs.getString(Constants.encryptionKey);
    final List<int> encryptionKeyData;
    if (key.isEmpty) {
      log('Generating a new encryption key');
      encryptionKeyData = Hive.generateSecureKey();
      log('Saving the encryption key');
      await encryptedPrefs.setString(
        Constants.encryptionKey,
        base64UrlEncode(encryptionKeyData),
      );
    } else {
      log('Found an existing encryption key');
      encryptionKeyData = base64Url.decode(key);
    }
    log('Encryption key: $key');

    await Hive.openBox(
      Constants.settings,
      encryptionCipher: HiveAesCipher(encryptionKeyData),
    );

    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await SystemManager.instance.init();

        final box = Hive.box(Constants.settings);
        if (box.get(Constants.launchOnStartup, defaultValue: true)) {
          final packageInfo = await PackageInfo.fromPlatform();
          LaunchAtStartup.instance.setup(
            appName: packageInfo.appName,
            appPath: Platform.resolvedExecutable,
          );
          await LaunchAtStartup.instance.enable();
        }
      }
      setPathUrlStrategy();
    }

    await AuthManager.instance.init();
    await AssetManager.instance.init();
    await DataManager.instance.init();

    OpenAI.apiKey =
        Hive.box(Constants.settings).get(Constants.openAIKey, defaultValue: '');

    return true;
  }

  @override
  State<PocketJenna> createState() => _PocketJennaState();
}

class _PocketJennaState extends State<PocketJenna> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    SystemManager.instance.dispose();
    super.dispose();
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);
    return AdaptiveTheme(
      light: FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: Color(0xff6c4ab0),
          primaryContainer: Color(0xffa58dd7),
          secondary: Color(0xff82bcff),
          secondaryContainer: Color(0xfff2fbff),
          tertiary: Color(0xffceefff),
          tertiaryContainer: Color(0xffdef8fb),
          appBarColor: Color(0xfff2fbff),
          error: Color(0xffb00020),
        ),
        onPrimaryContainer: Colors.white,
        scaffoldBackground: Colors.transparent,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        // To use the playground font, add GoogleFonts package and uncomment
        fontFamily: GoogleFonts.poppins().fontFamily,
      ).copyWith(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemStatusBarContrastEnforced: false,
            systemNavigationBarContrastEnforced: false,
            systemNavigationBarColor: Colors.transparent,
            statusBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      dark: FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xff352c48),
          primaryContainer: Color(0xff1f1c26),
          secondary: Color(0xff00314b),
          secondaryContainer: Color(0xff6f96ad),
          tertiary: Color(0xff007eb6),
          tertiaryContainer: Color(0xff00344e),
          appBarColor: Color(0xff6f96ad),
          error: Color(0xffcf6679),
        ),
        scaffoldBackground: Colors.transparent,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        // To use the Playground font, add GoogleFonts package and uncomment
        fontFamily: GoogleFonts.poppins().fontFamily,
      ).copyWith(
        appBarTheme: const AppBarTheme(
          // backgroundColor: Colors.transparent,
          // surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            systemStatusBarContrastEnforced: false,
            systemNavigationBarContrastEnforced: false,
            systemNavigationBarColor: Colors.transparent,
            statusBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      initial: widget.mode,
      builder: (theme, darkTheme) {
        return MaterialApp.router(
          title: 'PocketJenna',
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          routerConfig: NavigationManager.instance.router,
        );
      },
    );
  }
}

class NavigationBackground extends StatefulWidget {
  final Widget child;
  final GoRouterState state;

  const NavigationBackground({
    super.key,
    required this.state,
    required this.child,
  });

  @override
  State<NavigationBackground> createState() => _NavigationBackgroundState();
}

class _NavigationBackgroundState extends State<NavigationBackground>
    with TickerProviderStateMixin {
  late final AnimationController transitionController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  late final AnimationController waveController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 100),
  )..repeat(reverse: true);

  late final AnimationController rotationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
    upperBound: 360,
    value: isOnboardingPage ? 150 : 130,
  );

  late final AnimationController loopController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
    value: 0,
  )..repeat(reverse: true);

  late final AnimationController logoController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..forward();

  late final Animation<double> transitionAnimation = CurvedAnimation(
    parent: transitionController,
    curve: Curves.easeInOutQuart,
  );

  late final Animation<double> waveAnimation = CurvedAnimation(
    parent: waveController,
    curve: Curves.linear,
  );

  late final Animation<double> logoAnimation = CurvedAnimation(
    parent: logoController,
    curve: Curves.easeInOutQuart,
  );

  late final Animation<double> loopAnimation = CurvedAnimation(
    parent: loopController,
    curve: Curves.easeInOutQuart,
  );

  bool get isHomePage => widget.state.location == '/home';

  bool get isChatPage => widget.state.location == '/chat';

  bool get isOnboardingPage => widget.state.location.startsWith('/onboarding');

  bool get isSettingsPage => widget.state.location == '/settings';

  final ui.Image logoFilledBlack = AssetManager
      .instance.logoFilledBlackPicInfo.picture
      .toImageSync(100, 100);

  bool isTransitioning() =>
      transitionController.status != AnimationStatus.completed &&
      transitionController.status != AnimationStatus.dismissed;

  @override
  void didUpdateWidget(covariant NavigationBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state == oldWidget.state) return;

    transitionController
      ..reset()
      ..forward();

    if (isChatPage) {
      rotationController.animateTo(
        230,
        curve: Curves.easeInOutQuart,
        duration: const Duration(seconds: 1),
      );
    } else if (isSettingsPage) {
      rotationController.animateTo(
        20,
        curve: Curves.easeInOutQuart,
        duration: const Duration(seconds: 1),
      );
    } else if (isOnboardingPage) {
      final bool isStep1 = widget.state.location == '/onboarding/one';
      final bool isStep2 = widget.state.location == '/onboarding/two';
      rotationController.animateTo(
        isStep1
            ? 150
            : isStep2
                ? 230
                : 300,
        curve: Curves.easeInOutQuart,
        duration: const Duration(seconds: 1),
      );
    } else {
      rotationController.animateTo(
        130,
        curve: Curves.easeInOutQuart,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void transitionListener() {
    if (isTransitioning()) {
      // [0, 1]
      final time = transitionAnimation.value;

      // [-1, 0, 1]
      final normalizedTime = time * 2 - 1;

      // [1, 0, 1]
      final vTime = normalizedTime.abs();

      // [0, 1, 0]
      final reversedTime = 1 - vTime;

      waveController.value = (waveController.value + (reversedTime / 90)) % 1;
    } else {
      waveController.repeat(reverse: true);
    }
  }

  final Random random = Random(2);
  List<Color>? colors;

  @override
  void initState() {
    super.initState();

    transitionAnimation.addListener(transitionListener);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      generateColors();
      final manager = AdaptiveTheme.of(context);
      manager.modeChangeNotifier.addListener(onThemeChange);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    transitionAnimation.removeListener(transitionListener);
    transitionController.dispose();
    waveController.dispose();
    rotationController.dispose();
    logoController.dispose();
    loopController.dispose();
    logoFilledBlack.dispose();

    final manager = AdaptiveTheme.of(context);
    manager.modeChangeNotifier.removeListener(onThemeChange);

    super.dispose();
  }

  void onThemeChange() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      generateColors();
      setState(() {});
    });
  }

  void generateColors() {
    colors = List.generate(
      8,
      (index) {
        final HSVColor color = HSVColor.fromColor(
          context.colorScheme.secondary,
        );
        final HSVColor newColor = color
            .withSaturation(
              color.saturation + ((random.nextDouble() - 0.5 * 2) * 0.2),
            )
            .withValue(
              color.value - (random.nextDouble() * 0.15),
            )
            .withHue(
              color.hue + ((random.nextDouble() - 0.5 * 2) * 10),
            );
        return newColor.toColor();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: loopAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: BackgroundPainter(
                    anim: loopAnimation.value,
                    asset: logoFilledBlack,
                    shades: colors ?? [context.colorScheme.secondary],
                  ),
                );
              },
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              color: context.colorScheme.background.withOpacity(
                isChatPage ? 0.65 : 0.35,
              ),
            ),
            widget.child,
          ],
        );
      }),
    );
  }
}
