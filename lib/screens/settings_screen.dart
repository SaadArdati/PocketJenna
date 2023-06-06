import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../constants.dart';
import '../managers/auth/auth_manager.dart';
import '../managers/system_manager.dart';
import '../ui/custom_scaffold.dart';
import '../ui/theme_extensions.dart';
import 'open_ai_key_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: Text(
        'Settings',
        textAlign: TextAlign.center,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [
        ScaffoldAction(
          onTap: () {
            final box = Hive.box(Constants.settings);
            final bool onboarding =
                box.get(Constants.isFirstTime, defaultValue: true);
            context.go(onboarding ? '/onboarding' : '/home',
                extra: {'from': 'settings'});
          },
          icon: Icons.arrow_forward,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
      ],
      body: Builder(builder: (context) {
        return SizedBox.expand(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const AppSettingsTile(),
                  const SizedBox(height: 16),
                  const OpenAIKeyTile(),
                  const SizedBox(height: 16),
                  const AccountSettingsTile(),
                  const SizedBox(height: 16),
                  buildAboutTile(context),
                  const SizedBox(height: 32)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildAboutTile(BuildContext context) {
    return JennaTile(
      title: 'About'.toUpperCase(),
      icon: const Icon(Icons.info_outlined),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ContactCard(
                asset: 'assets/hyperdesigned_banner.png',
                name: 'Hyperdesigned',
                url: 'https://hyperdesigned.dev/',
              ),
              ContactCard(
                asset: 'assets/profile_256x.png',
                name: 'Saad Ardati',
                url: 'https://saad-ardati.dev/',
              ),
              ContactCard(
                asset: 'assets/birju.png',
                name: 'Birju Vachhani',
                url: 'https://birju.dev/',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      return Text(
                        'Version: $version',
                        textAlign: TextAlign.center,
                      );
                    }),
                const SizedBox(height: 8),
                Text(
                  'Copyright © 2020-2021. All Rights Reserved',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        launchUrlString(
                            'https://hyperdesigned.dev/pocket-jenna/privacy-policy');
                      },
                      child: Text(
                        'View Privacy Policy',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showLicensePage(context: context);
                      },
                      child: Text(
                        'View Licenses',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContactCard extends StatefulWidget {
  final String asset;
  final String name;
  final String url;

  const ContactCard({
    super.key,
    required this.asset,
    required this.name,
    required this.url,
  });

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
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
            launchUrlString(widget.url);
          });
        },
        onTapCancel: () {
          setState(() {
            isPressingDown = false;
          });
        },
        child: Container(
          height: 72,
          width: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colorScheme.primary,
                width: 3,
              ),
            ),
            child: Animate(
              target: isPressingDown
                  ? 1
                  : isHovering
                      ? 0.5
                      : 0,
              child: Image.asset(
                widget.asset,
                fit: BoxFit.cover,
              ),
            ).custom(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutQuart,
              builder: (context, value, child) => Transform.scale(
                scale: 1 + (value / 8),
                child: child,
              ),
            ),
          ),
        ),
      ),
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
              JennaTile(
                title: 'App Settings'.toUpperCase(),
                icon: const Icon(Icons.settings),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                              color: context.colorScheme.onSurface,
                            ),
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
                    if (!kIsWeb && Platform.isWindows) ...[
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
                            color:
                                context.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        onChanged: (bool? value) {
                          box.put(
                            Constants.checkForUpdates,
                            value ?? !box.get(Constants.checkForUpdates),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(height: 16),
                JennaTile(
                  title: 'Desktop Settings'.toUpperCase(),
                  icon: const Icon(Icons.desktop_windows_outlined),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                            defaultValue: false),
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
                          box.put(Constants.launchOnStartup, value ?? false);
                          final shouldLaunchAtStartup = box.get(
                              Constants.launchOnStartup,
                              defaultValue: false);
                          SystemManager.instance.handleLaunchAtStartup(
                            shouldLaunchAtStartup: shouldLaunchAtStartup,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // CheckboxListTile(
                      //   value: box.get(Constants.showTitleBar,
                      //       defaultValue: false),
                      //   title: Text(
                      //     'Show window title bar',
                      //     style: context.textTheme.titleSmall,
                      //   ),
                      //   subtitle: Text(
                      //     'Shows the minimize, maximize, and close buttons from the system. (Restart required)',
                      //     style: context.textTheme.bodySmall?.copyWith(
                      //       fontSize: 12,
                      //       color:
                      //           context.colorScheme.onSurface.withOpacity(0.7),
                      //     ),
                      //   ),
                      //   onChanged: (bool? value) {
                      //     SystemManager.instance
                      //         .toggleTitleBar(show: value ?? false);
                      //
                      //     // Force user to restart app.
                      //     showDialog(
                      //       context: context,
                      //       barrierDismissible: false,
                      //       builder: (context) {
                      //         return WillPopScope(
                      //           onWillPop: () async => false,
                      //           child: AlertDialog(
                      //             title: const Text('Restart required'),
                      //             content: const Text(
                      //               'You will need to restart the app for changes to take effect.',
                      //             ),
                      //             actions: [
                      //               TextButton(
                      //                 onPressed: () {
                      //                   Navigator.pop(context);
                      //                 },
                      //                 child: Text(
                      //                   'Dismiss',
                      //                   style: context.textTheme.labelMedium
                      //                       ?.copyWith(
                      //                     color: context.colorScheme.onSurface,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         );
                      //       },
                      //     );
                      //   },
                      // ),
                      // const SizedBox(height: 8),
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
                    ],
                  ),
                ),
              ],
            ],
          );
        });
  }
}

class JennaTile extends StatelessWidget {
  final String? title;
  final Widget? icon;
  final Widget child;
  final EdgeInsets padding;
  final Color? surfaceColor;
  final Color? borderColor;

  const JennaTile({
    super.key,
    this.title,
    this.icon,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.surfaceColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: surfaceColor ?? context.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? context.colorScheme.primary,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || icon != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: borderColor ?? context.colorScheme.primary),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconTheme(
                          data: Theme.of(context).iconTheme.copyWith(
                                color: context.colorScheme.onPrimary,
                                size: 24,
                              ),
                          child: icon!,
                        ),
                      ),
                    ),
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        title!,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  if (icon != null && title != null) const Spacer(),
                ],
              ),
            ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
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
    return JennaTile(
      title: 'Account Settings'.toUpperCase(),
      icon: const Icon(Icons.person),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Reset Password'),
            dense: true,
            minLeadingWidth: 32,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const ResetPasswordDialog();
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            dense: true,
            minLeadingWidth: 32,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const SignOutDialog();
                },
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: context.colorScheme.error,
            ),
            title: Text(
              'Delete account',
              style: TextStyle(color: context.colorScheme.error),
            ),
            dense: true,
            minLeadingWidth: 32,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const DeleteAccountDialog();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class ResetPasswordDialog extends StatelessWidget {
  const ResetPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    if (AuthManager.instance.currentAuth?.email == null) {
      return AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
          'This account does not have an email associated with it. Please sign in with an email account to reset your password.',
          style: context.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Reset Password'),
      content: Text(
        'Are you sure you want to reset your password?\n\nYou will be sent an email with a link to reset your password.',
        style: context.textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Dismiss'),
        ),
        TextButton(
          onPressed: () {
            AuthManager.instance.sendPasswordResetEmail(
                AuthManager.instance.currentAuth!.email!);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'A password reset email has been sent to your account'),
                showCloseIcon: true,
              ),
            );
          },
          child: const Text('Reset'),
        ),
      ],
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
      content: Text(
        'Are you sure you want to sign out of your account?',
        style: context.textTheme.bodyMedium,
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

  Future<void> deleteAccount() async {
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
      content: Text(
        'Are you sure you want to sign out of your account?',
        style: context.textTheme.bodyMedium,
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
                  deleteAccount();
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
