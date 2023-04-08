import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../constants.dart';
import '../managers/auth/auth_manager.dart';
import '../managers/system_manager.dart';
import '../ui/theme_extensions.dart';
import '../ui/window_controls.dart';
import 'open_ai_key_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  )..forward();

  late final Animation<double> blurAnimation = CurvedAnimation(
    parent: animationController,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go('/home', extra: {'from': 'settings'});
          },
          icon: const Icon(Icons.arrow_forward),
        ),
        centerTitle: false,
        title: Text(
          'Settings',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.onPrimaryContainer,
          ),
        ),
        actions: const [WindowControls()],
      ),
      extendBodyBehindAppBar: true,
      body: Builder(builder: (context) {
        return SizedBox.expand(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 350),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                SizedBox(
                  height: (Scaffold.of(context).appBarMaxHeight ?? 48) + 16,
                ),
                const AppSettingsTile(),
                const SizedBox(height: 16),
                const OpenAIKeyTile(),
                const SizedBox(height: 16),
                const AccountSettingsTile(),
                const SizedBox(height: 16),
                buildInfoTile(context),
                const SizedBox(height: 32)
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget buildInfoTile(BuildContext context) {
    return SettingsTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: context.colorScheme.primary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outlined,
                  size: 20,
                  color: context.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'About'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: context.colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildContactTile(
                  title: 'Website',
                  icon: 'assets/profile_256x.png',
                  url: 'https://saad-ardati.dev/',
                  avatar: true,
                ),
                const SizedBox(height: 8),
                buildContactTile(
                  title: 'Twitter',
                  icon: 'assets/twitter_256x.png',
                  url: 'https://twitter.com/SaadArdati',
                ),
                const SizedBox(height: 8),
                buildContactTile(
                  title: 'Github',
                  icon: Theme.of(context).brightness == Brightness.dark
                      ? 'assets/github_dark_256x.png'
                      : 'assets/github_light_256x.png',
                  url: 'https://github.com/SaadArdati',
                ),
                const SizedBox(height: 8),
                buildContactTile(
                  title: 'Discord',
                  icon: 'assets/discord_256x.png',
                  url: 'https://discord.gg/ARxJzxU',
                ),
                const SizedBox(height: 8),
                buildContactTile(
                  title: 'LinkedIn',
                  icon: 'assets/linked_in_256x.png',
                  url: 'https://www.linkedin.com/in/saad-ardati',
                ),
                const SizedBox(height: 8),
                buildContactTile(
                  title: 'Instagram',
                  icon: 'assets/instagram_256x.png',
                  url: 'https://www.instagram.com/saad_ardati',
                ),
                const SizedBox(height: 16),
                FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (BuildContext context,
                        AsyncSnapshot<PackageInfo> snapshot) {
                      final String version;
                      if (snapshot.hasError) {
                        version = snapshot.error.toString();
                      } else if (snapshot.hasData) {
                        version = snapshot.data!.version;
                      } else {
                        version = 'Checking...';
                      }
                      return Text('Version: $version');
                    }),
                const SizedBox(height: 8),
                Text(
                  'Copyright © 2020-2021. All Rights Reserved',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        launchUrlString(
                            'https://saad-ardati.dev/pocketjenna/privacy-policy');
                      },
                      child: const Text('View Privacy Policy'),
                    ),
                    TextButton(
                      onPressed: () {
                        showLicensePage(context: context);
                      },
                      child: const Text('View Licenses'),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Row buildContactTile({
    required String icon,
    required String title,
    required String url,
    bool avatar = false,
  }) {
    return Row(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colorScheme.inverseSurface,
            shape: BoxShape.circle,
          ),
          padding: avatar ? EdgeInsets.zero : const EdgeInsets.all(8),
          child: Image.asset(
            icon,
            width: avatar ? 32 : 18,
            height: avatar ? 32 : 18,
            fit: avatar ? BoxFit.cover : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium,
            TextSpan(
              text: '$title: ',
              children: [
                TextSpan(
                  text: url,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrlString(url);
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AppSettingsTile extends StatefulWidget {
  const AppSettingsTile({super.key});

  @override
  State<AppSettingsTile> createState() => _AppSettingsTileState();
}

class _AppSettingsTileState extends State<AppSettingsTile> {
  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform = defaultTargetPlatform;
    final bool isDesktop = !kIsWeb &&
        (platform == TargetPlatform.windows ||
            platform == TargetPlatform.linux ||
            platform == TargetPlatform.macOS);

    return ValueListenableBuilder(
        valueListenable: Hive.box(Constants.settings).listenable(),
        builder: (context, box, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SettingsTile(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: context.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 16),
                          Icon(
                            Icons.settings,
                            size: 20,
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'App Settings'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.onPrimaryContainer,
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: context.colorScheme.onSurface.withOpacity(0.2),
                    ),
                    const SizedBox(height: 8),
                    Builder(builder: (context) {
                      final manager = AdaptiveTheme.of(context);

                      return ListTile(
                        title: Text(
                          'Theme Mode',
                          style: context.textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          'Controls the behavior of the light and dark theme.',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color:
                                context.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        trailing: SizedBox(
                          height: 36,
                          child: DropdownButton<AdaptiveThemeMode>(
                            value: manager.mode,
                            style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onPrimaryContainer),
                            underline: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(8),
                            icon: const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.arrow_drop_down),
                            ),
                            selectedItemBuilder: (context) => [
                              for (final mode in AdaptiveThemeMode.values)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 8, 4, 8),
                                  child: Text(mode.modeName),
                                ),
                            ],
                            items: [
                              for (final mode in AdaptiveThemeMode.values)
                                DropdownMenuItem<AdaptiveThemeMode>(
                                  value: mode,
                                  child: Text(mode.modeName),
                                ),
                            ],
                            onChanged: (AdaptiveThemeMode? value) {
                              if (value != null) {
                                manager.setThemeMode(value);
                              }
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: box.get(Constants.checkForUpdates,
                          defaultValue: true),
                      title: Text(
                        'Automatically check for updates',
                        style: context.textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        'Checks for updates when the app starts and notifies you if there is an update available.',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: context.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      onChanged: (bool? value) {
                        box.put(
                          Constants.checkForUpdates,
                          value ?? !box.get(Constants.checkForUpdates),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(height: 16),
                SettingsTile(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        color: context.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 16),
                            Icon(
                              Icons.desktop_windows_outlined,
                              size: 20,
                              color: context.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Desktop Settings'.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context.colorScheme.onPrimaryContainer,
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: context.colorScheme.onSurface.withOpacity(0.2),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value:
                            box.get(Constants.alwaysOnTop, defaultValue: true),
                        title: Text(
                          'Always on top',
                          style: context.textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          'The window will always be on top of all other windows.',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color:
                                context.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        onChanged: (bool? value) {
                          box.put(
                            Constants.alwaysOnTop,
                            value ??
                                !box.get(
                                  Constants.alwaysOnTop,
                                  defaultValue: true,
                                ),
                          );
                          SystemManager.instance.setAlwaysOnTop(value ?? true);
                        },
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: box.get(Constants.shouldPreserveWindowPosition,
                            defaultValue: true),
                        title: Text(
                          'Preserve window position',
                          style: context.textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          'Remembers the position of the window when you close it.',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color:
                                context.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        onChanged: (bool? value) {
                          box.put(
                            Constants.shouldPreserveWindowPosition,
                            value ??
                                !box.get(
                                  Constants.shouldPreserveWindowPosition,
                                  defaultValue: true,
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: box.get(Constants.launchOnStartup,
                            defaultValue: true),
                        title: Text(
                          'Launch app on startup',
                          style: context.textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          'Launches the app when you start your computer.',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color:
                                context.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        onChanged: (bool? value) {
                          box.put(
                            Constants.launchOnStartup,
                            value ??
                                !box.get(
                                  Constants.launchOnStartup,
                                  defaultValue: true,
                                ),
                          );
                          if (value == false) {
                            LaunchAtStartup.instance.disable();
                          } else {
                            LaunchAtStartup.instance.enable();
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: box.get(Constants.showTitleBar,
                            defaultValue: false),
                        title: Text(
                          'Show window title bar',
                          style: context.textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          'Shows the minimize, maximize, and close buttons from the system. (Restart required)',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color:
                                context.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        onChanged: (bool? value) {
                          SystemManager.instance
                              .toggleTitleBar(show: value ?? false);

                          // Force user to restart app.
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return WillPopScope(
                                onWillPop: () async => false,
                                child: AlertDialog(
                                  title: const Text('Restart required'),
                                  content: const Text(
                                    'You will need to restart the app for changes to take effect.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Dismiss'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: box.get(Constants.moveToSystemDock,
                            defaultValue: false),
                        title: Text(
                          'Move to system dock',
                          style: context.textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          'Puts the app in the system dock as if it were a full app.',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color:
                                context.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        onChanged: (bool? value) {
                          SystemManager.instance
                              .toggleSystemDock(show: value ?? false);
                        },
                      ),
                      if (defaultTargetPlatform == TargetPlatform.macOS) ...[
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          value: box.get(
                            Constants.macOSLeftClickOpensApp,
                            defaultValue: false,
                          ),
                          title: Text(
                            'Open app on left-click',
                            style: context.textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            'Left-clicking on the menu bar icon will open the app, right-clicking will open the options menu.',
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: context.colorScheme.onSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                          onChanged: (bool? value) {
                            box.put(
                              Constants.macOSLeftClickOpensApp,
                              value ??
                                  !box.get(
                                    Constants.macOSLeftClickOpensApp,
                                    defaultValue: false,
                                  ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ],
          );
        });
  }
}

class SettingsTile extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const SettingsTile({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: padding,
        clipBehavior: Clip.antiAlias,
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.colorScheme.surface,
        ),
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}

class AccountSettingsTile extends StatefulWidget {
  const AccountSettingsTile({super.key});

  @override
  State<AccountSettingsTile> createState() => _AccountSettingsTileState();
}

class _AccountSettingsTileState extends State<AccountSettingsTile> {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: context.colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.person,
                  size: 20,
                  color: context.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Account Settings'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                )
              ],
            ),
          ),
          Divider(
            height: 1,
            color: context.colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const SignOutDialog();
                },
              );
            },
          ),
          ColoredBox(
            color: context.colorScheme.error,
            child: ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: context.colorScheme.onError,
              ),
              title: Text(
                'Delete account',
                style: TextStyle(color: context.colorScheme.onError),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const DeleteAccountDialog();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SignOutDialog extends StatefulWidget {
  const SignOutDialog({super.key});

  @override
  State<SignOutDialog> createState() => _SignOutDialogState();
}

class _SignOutDialogState extends State<SignOutDialog> {
  bool isLoading = false;

  Future<void> signOut() async {
    setState(() {
      isLoading = true;
    });

    await AuthManager.instance.signOut().whenComplete(() {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Navigator.pop(context);
        context.go('/auth');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign out'),
      content: const Text(
        'Are you sure you want to sign out of your account?',
      ),
      actions: [
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        TextButton.icon(
          onPressed: isLoading
              ? null
              : () {
                  signOut();
                },
          icon: isLoading
              ? CupertinoActivityIndicator(color: context.colorScheme.primary)
              : const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
      ],
    );
  }
}

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => DeleteAccountDialogState();
}

class DeleteAccountDialogState extends State<DeleteAccountDialog> {
  bool isLoading = false;

  Future<void> signOut() async {
    setState(() {
      isLoading = true;
    });

    await AuthManager.instance.deleteAccount().whenComplete(() {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Navigator.pop(context);
        context.go('/auth');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign out'),
      content: const Text(
        'Are you sure you want to sign out of your account?',
      ),
      actions: [
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: context.colorScheme.error,
          ),
          onPressed: isLoading
              ? null
              : () {
                  signOut();
                },
          icon: isLoading
              ? CupertinoActivityIndicator(color: context.colorScheme.onError)
              : Icon(Icons.delete_forever, color: context.colorScheme.onError),
          label: Text('Delete account',
              style: TextStyle(color: context.colorScheme.onError)),
        ),
      ],
    );
  }
}
