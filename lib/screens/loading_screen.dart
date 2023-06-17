import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../constants.dart';
import '../managers/asset_manager.dart';
import '../managers/auth/auth_manager.dart';
import '../managers/data/data_manager.dart';
import '../managers/prompt_manager.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final box = Hive.box(Constants.settings);

  late final Future<bool> loadFuture = load().then((success) {
    if (!mounted || !success) return false;

    final route = box.get(Constants.isFirstTime, defaultValue: true)
        ? '/onboarding'
        : '/home';

    context.go(route);

    return true;
  });

  Future<bool> load() async {
    await AuthManager.instance.init();
    await AssetManager.instance.init();
    await DataManager.instance.init().catchError((e) {});
    PromptManager.instance.init();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadFuture,
      initialData: false,
      builder: (context, snapshot) {
        return const Center(child: CupertinoActivityIndicator());
      },
    );
  }
}
