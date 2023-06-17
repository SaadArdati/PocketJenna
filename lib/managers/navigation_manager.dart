import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../main.dart';
import '../models/prompt.dart';
import '../screens/auth_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/home_screen.dart';
import '../screens/loading_screen.dart';
import '../screens/onboarding/macos_onboarding_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/open_ai_key_screen.dart';
import '../screens/prompt_creator/prompt_creation_body.dart';
import '../screens/prompt_creator/prompt_creation_meta.dart';
import '../screens/prompt_creator/prompt_creation_preview.dart';
import '../screens/prompt_creator/prompt_creation_tester.dart';
import '../screens/prompt_market/prompt_market.dart';
import '../screens/prompt_market/prompt_market_page.dart';
import '../screens/prompt_market/prompt_market_page_try.dart';
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

  late final box = Hive.box(Constants.settings);

  late final router = GoRouter(
    initialLocation: '/loading',
    routes: [baseRoute],
  );

  FutureOr<String?> authGuard(BuildContext context, GoRouterState state) {
    if (!AuthManager.instance.isAuthenticated ||
        DataManager.instance.currentUser == null) {
      return '/auth';
    }

    final String key = box.get(Constants.openAIKey) ?? '';
    if (key.isEmpty) {
      return '/onboarding/openai';
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
        path: '/loading',
        builder: (state, context) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (state, context) => const SizedBox.shrink(),
        redirect: (BuildContext context, GoRouterState state) {
          if (state.location == '/onboarding') {
            return '/onboarding/hello';
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
                path: 'hello',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: const OnboardingWelcome(),
                    opaque: true,
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
                path: 'openai',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: const OpenAIKeyScreen(),
                    opaque: true,
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
                path: 'done',
                redirect: authGuard,
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: const OnboardingDone(),
                    opaque: true,
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
                        opaque: true,
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
            opaque: true,
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
          AxisDirection comesFrom = AxisDirection.right;

          return CustomTransitionPage(
            key: state.pageKey,
            child: const PromptMarket(),
            opaque: true,
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
        routes: [
          GoRoute(
              path: ':promptID',
              redirect: (context, state) async {
                final String? promptID = state.pathParameters['promptID'];
                if (promptID == null) {
                  return '/prompt-market';
                }

                final String? authDirect = await authGuard(context, state);
                if (authDirect != null) {
                  return authDirect;
                }

                return null;
              },
              pageBuilder: (context, state) {
                AxisDirection comesFrom = AxisDirection.right;

                final String? promptID = state.pathParameters['promptID'];

                return CustomTransitionPage(
                  key: state.pageKey,
                  child: PromptMarketPage(promptID: promptID!),
                  opaque: true,
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
              routes: [
                GoRoute(
                  path: 'try',
                  redirect: (context, state) async {
                    final dynamic prompt = state.extra;
                    if (prompt is! Prompt) {
                      return '/prompt-market';
                    }

                    final String? authDirect = await authGuard(context, state);
                    if (authDirect != null) {
                      return authDirect;
                    }

                    return null;
                  },
                  pageBuilder: (context, state) {
                    AxisDirection comesFrom = AxisDirection.right;

                    final prompt = state.extra as Prompt;

                    return CustomTransitionPage(
                      key: state.pageKey,
                      child: PromptMarketPageTrialWrapper(prompt: prompt),
                      opaque: true,
                      reverseTransitionDuration:
                          const Duration(milliseconds: 600),
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
              ]),
        ],
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
                opaque: true,
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
                opaque: true,
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
                opaque: true,
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
            path: '/prompt-creator/preview',
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
                child: const PromptCreationPreview(),
                opaque: true,
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
          final String? authDirect = await authGuard(context, state);
          if (authDirect != null) {
            return authDirect;
          }

          final String? promptID = state.queryParameters['promptID'];
          final String? chatID = state.queryParameters['chatID'];

          if (chatID == null && promptID == null) {
            return '/home';
          }
          if (chatID != null && promptID != null) {
            return '/home';
          }

          return null;
        },
        pageBuilder: (context, GoRouterState state) {
          final String? promptID = state.queryParameters['promptID'];
          final String? chatID = state.queryParameters['chatID'];

          final Widget child = ChatScreenWrapper(
            chatID: chatID,
            prompt: chatID != null
                ? null
                : PromptManager.instance.getPromptByID(promptID!),
          );

          return CustomTransitionPage(
            key: state.pageKey,
            child: child,
            opaque: true,
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
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            opaque: true,
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
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AuthScreen(),
            opaque: true,
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
