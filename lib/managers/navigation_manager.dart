import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../main.dart';
import '../screens/auth_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding/macos_onboarding_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/prompt_creator/prompt_creation_body.dart';
import '../screens/prompt_creator/prompt_creation_meta.dart';
import '../screens/prompt_creator/prompt_creation_tester.dart';
import '../screens/prompt_market.dart';
import '../screens/settings_screen.dart';
import '../ui/window_drag_handle.dart';
import 'auth/auth_manager.dart';
import 'data/data_manager.dart';
import 'prompt_manager.dart';
import 'prompt_testing_manager.dart';

class NavigationManager {
  NavigationManager._();

  static final NavigationManager _instance = NavigationManager._();

  static NavigationManager get instance => _instance;

  factory NavigationManager() => _instance;

  final box = Hive.box(Constants.settings);

  late final router = GoRouter(
    // initialLocation: '/onboarding',
    initialLocation: box.get(Constants.isFirstTime, defaultValue: true)
        ? '/onboarding'
        : '/home',
    routes: [baseRoute],
  );

  FutureOr<String?> authGuard(BuildContext context, GoRouterState state) {
    if (!AuthManager.instance.isAuthenticated ||
        DataManager.instance.currentUser == null) {
      return '/auth';
    }

    return null;
  }

  final _promptCreationNavigatorKey = GlobalKey<NavigatorState>();

  late final baseRoute = ShellRoute(
    builder: (context, GoRouterState state, child) {
      return WindowDragHandle(
          child: NavigationBackground(state: state, child: child));
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (state, context) => const SizedBox.shrink(),
        redirect: (BuildContext context, GoRouterState state) {
          if (!AuthManager.instance.isAuthenticated) {
            return '/auth';
          }
          if (state.location == '/onboarding') {
            return '/onboarding/one';
          }
          return null;
        },
        routes: [
          ShellRoute(
            builder: (context, GoRouterState state, child) {
              return OnboardingScreen(child: child);
            },
            routes: [
              GoRoute(
                path: 'one',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: const OnboardingWelcome(),
                    opaque: false,
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return pocketJennaTransition(
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                        state: state,
                        comesFrom: AxisDirection.right,
                      );
                    },
                  );
                },
              ),
              // GoRoute(
              //   path: 'two',
              //   pageBuilder: (context, state) {
              //     return CustomTransitionPage(
              //       key: state.pageKey,
              //       child: const OpenAIKeyScreen(),
              //       opaque: false,
              //       transitionsBuilder:
              //           (context, animation, secondaryAnimation, child) {
              //         return pocketJennaTransition(
              //           context,
              //           animation,
              //           secondaryAnimation,
              //           child,
              //           state: state,
              //           comesFrom: AxisDirection.right,
              //         );
              //       },
              //     );
              //   },
              // ),
              GoRoute(
                path: 'two',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: const OnboardingDone(),
                    opaque: false,
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return pocketJennaTransition(
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                        state: state,
                        comesFrom: AxisDirection.right,
                      );
                    },
                  );
                },
                routes: [
                  GoRoute(
                    path: 'macos_onboarding',
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const MacOSOnboarding(),
                        opaque: false,
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return pocketJennaTransition(
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                            state: state,
                            comesFrom: AxisDirection.right,
                          );
                        },
                      );
                    },
                  ),
                  GoRoute(
                    path: 'tray_position',
                    builder: (context, state) {
                      final extras = state.extra;
                      final String id = extras != null && extras is Map
                          ? extras['instructionID']
                          : '';

                      return InstructionView(instructionID: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        redirect: authGuard,
        pageBuilder: (context, state) {
          final extra = state.extra;
          AxisDirection comesFrom = AxisDirection.right;
          if (extra != null && extra is Map) {
            final String? fromParam = extra['from'];
            if (fromParam == '/chat') {
              comesFrom = AxisDirection.left;
            }
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            opaque: false,
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return pocketJennaTransition(
                context,
                animation,
                secondaryAnimation,
                child,
                state: state,
                comesFrom: comesFrom,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/prompt-market',
        redirect: authGuard,
        pageBuilder: (context, state) {
          final extra = state.extra;
          AxisDirection comesFrom = AxisDirection.right;

          return CustomTransitionPage(
            key: state.pageKey,
            child: const PromptMarket(),
            opaque: false,
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return pocketJennaTransition(
                context,
                animation,
                secondaryAnimation,
                child,
                state: state,
                comesFrom: comesFrom,
              );
            },
          );
        },
      ),
      ShellRoute(
        navigatorKey: _promptCreationNavigatorKey,
        builder: (context, state, child) {
          return Provider(
            create: (BuildContext context) => PromptTestingManager(),
            child: Builder(builder: (context) {
              return child;
            }),
          );
        },
        routes: [
          GoRoute(
            path: '/prompt-creator/body',
            redirect: authGuard,
            parentNavigatorKey: _promptCreationNavigatorKey,
            pageBuilder: (context, state) {
              AxisDirection comesFrom = AxisDirection.right;

              return CustomTransitionPage(
                key: state.pageKey,
                child: const PromptCreationBody(),
                opaque: false,
                transitionDuration: const Duration(milliseconds: 600),
                reverseTransitionDuration: const Duration(milliseconds: 600),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return pocketJennaTransition(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                    state: state,
                    comesFrom: comesFrom,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/prompt-creator/test',
            parentNavigatorKey: _promptCreationNavigatorKey,
            redirect: (context, state) async {
              // final PromptTestingManager promptTestingManager =
              //     context.read<PromptTestingManager>();
              // if (promptTestingManager.prompt == null) {
              //   return '/prompt-creator/body';
              // }

              final String? authDirect = await authGuard(context, state);
              if (authDirect != null) {
                return authDirect;
              }

              return null;
            },
            pageBuilder: (context, state) {
              AxisDirection comesFrom = AxisDirection.right;
              return CustomTransitionPage(
                key: state.pageKey,
                child: const PromptCreationTesterWrapper(),
                opaque: false,
                transitionDuration: const Duration(milliseconds: 600),
                reverseTransitionDuration: const Duration(milliseconds: 600),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return pocketJennaTransition(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                    state: state,
                    comesFrom: comesFrom,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/prompt-creator/meta',
            parentNavigatorKey: _promptCreationNavigatorKey,
            redirect: (context, state) async {
              // final PromptTestingManager promptTestingManager =
              //     context.read<PromptTestingManager>();
              // if (promptTestingManager.prompt == null) {
              //   return '/prompt-creator/body';
              // }

              final String? authDirect = await authGuard(context, state);
              if (authDirect != null) {
                return authDirect;
              }

              return null;
            },
            pageBuilder: (context, state) {
              AxisDirection comesFrom = AxisDirection.right;

              return CustomTransitionPage(
                key: state.pageKey,
                child: const PromptCreationMeta(),
                opaque: false,
                transitionDuration: const Duration(milliseconds: 600),
                reverseTransitionDuration: const Duration(milliseconds: 600),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return pocketJennaTransition(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                    state: state,
                    comesFrom: comesFrom,
                  );
                },
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/chat',
        redirect: (context, state) async {
          final String? promptID = state.queryParams['promptID'];
          final String? chatID = state.queryParams['chatID'];

          if (chatID == null && promptID == null) {
            return '/home';
          }
          if (chatID != null && promptID != null) {
            return '/home';
          }

          final String? authDirect = await authGuard(context, state);
          if (authDirect != null) {
            return authDirect;
          }

          return null;
        },
        pageBuilder: (context, GoRouterState state) {
          final String? promptID = state.queryParams['promptID'];
          final String? chatID = state.queryParams['chatID'];

          final Widget child = ChatScreenWrapper(
            chatID: chatID,
            prompt: chatID != null
                ? null
                : PromptManager.instance.getPromptByID(promptID!),
          );

          return CustomTransitionPage(
            key: state.pageKey,
            child: child,
            opaque: false,
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return pocketJennaTransition(
                context,
                animation,
                secondaryAnimation,
                child,
                state: state,
                comesFrom: AxisDirection.right,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            opaque: false,
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return pocketJennaTransition(
                context,
                animation,
                secondaryAnimation,
                child,
                state: state,
                comesFrom: AxisDirection.left,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AuthScreen(),
            opaque: false,
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return pocketJennaTransition(
                context,
                animation,
                secondaryAnimation,
                child,
                state: state,
                comesFrom: AxisDirection.right,
              );
            },
          );
        },
      ),
    ],
  );

  Widget pocketJennaTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    required GoRouterState state,
    required AxisDirection comesFrom,
  }) {
    return SlideTransition(
      position: CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.linearToEaseOut,
        reverseCurve: Curves.easeInToLinear,
      ).drive(
        Tween<Offset>(
          begin: Offset.zero,
          end: comesFrom == AxisDirection.up || comesFrom == AxisDirection.down
              ? Offset(0.0, comesFrom == AxisDirection.up ? -1 : 1)
              : Offset(comesFrom == AxisDirection.left ? -1 : 1, 0.0),
        ),
      ),
      transformHitTests: false,
      child: SlideTransition(
        position: CurvedAnimation(
          parent: animation,
          curve: Curves.linearToEaseOut,
          reverseCurve: Curves.easeInToLinear,
        ).drive(
          Tween<Offset>(
            begin:
                comesFrom == AxisDirection.up || comesFrom == AxisDirection.down
                    ? Offset(0.0, comesFrom == AxisDirection.up ? -1 : 1)
                    : Offset(comesFrom == AxisDirection.left ? -1 : 1, 0.0),
            end: Offset.zero,
          ),
        ),
        child: child,
      ),
    );
  }
}
