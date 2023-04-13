import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../managers/auth/auth_manager.dart';
import '../../ui/switchers.dart';
import '../../ui/theme_extensions.dart';
import '../../ui/window_controls.dart';

enum AuthScreenMode {
  signIn('Sign In'),
  signUp('Sign Up'),
  forgotPassword('Forgot Password');

  final String label;

  const AuthScreenMode(this.label);

  bool get isSignIn => this == AuthScreenMode.signIn;

  bool get isSignUp => this == AuthScreenMode.signUp;

  bool get isForgotPassword => this == AuthScreenMode.forgotPassword;
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  AuthScreenMode mode = AuthScreenMode.signIn;

  bool showPassword = false;
  bool showConfirmPassword = false;

  bool isLoading = false;
  String? error;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    if (formKey.currentState?.validate() == true) {
      try {
        await AuthManager.instance.signIn(
          emailController.text,
          passwordController.text,
        );

        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        error = e.toString();
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> signUp() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    if (formKey.currentState?.validate() == true) {
      try {
        await AuthManager.instance.signUp(
          emailController.text,
          passwordController.text,
        );
      } catch (e) {
        error = e.toString();
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> forgotPassword() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    if (formKey.currentState?.validate() == true) {
      try {
        await AuthManager.instance.forgotPassword(emailController.text);
      } catch (e) {
        error = e.toString();
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode.label,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.onPrimary,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings),
          onPressed: () {
            context.go('/settings', extra: {'from': 'home'});
          },
        ),
        actions: const [WindowControls()],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: context.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    maxLength: 10000,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (_) {
                      setState(() {});
                    },
                    onFieldSubmitted: (_) {},
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Enter your email',
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      filled: true,
                      fillColor: context.colorScheme.primaryContainer,
                      hoverColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: const BorderSide(width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: BorderSide(
                          color: context.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    cursorRadius: const Radius.circular(4),
                  ),
                  const SizedBox(height: 16),
                  CollapsableSwitcher(
                    open: !mode.isForgotPassword,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
                          style: context.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          maxLength: 10000,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          textInputAction: mode.isSignUp
                              ? TextInputAction.next
                              : TextInputAction.send,
                          keyboardType: TextInputType.visiblePassword,
                          enabled: !isLoading,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid password';
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (_) {
                            setState(() {});
                          },
                          onFieldSubmitted: (_) {
                            if (mode.isSignUp) {
                              Focus.of(context).nextFocus();
                            } else {
                              signIn();
                            }
                          },
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'Enter a password',
                            isDense: true,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            filled: true,
                            fillColor: context.colorScheme.primaryContainer,
                            hoverColor: Colors.transparent,
                            suffixIcon: IconButton(
                              tooltip: 'Show password',
                              color: context.colorScheme.onPrimaryContainer,
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: borderRadius,
                              borderSide: const BorderSide(width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: borderRadius,
                              borderSide: BorderSide(
                                color: context.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: borderRadius,
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                          cursorRadius: const Radius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  CollapsableSwitcher(
                    open: mode.isSignIn,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      mode = AuthScreenMode.forgotPassword;
                                      passwordController.clear();
                                      confirmPasswordController.clear();
                                      error = null;
                                    });
                                  },
                            child: Text(
                              'Forgot Password?',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onBackground,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CollapsableSwitcher(
                    open: mode.isSignUp,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Confirm Password',
                          style: context.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: confirmPasswordController,
                          maxLength: 10000,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.visiblePassword,
                          autofillHints: const [AutofillHints.password],
                          enabled: !isLoading,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid password';
                            }

                            if (value != confirmPasswordController.text) {
                              return 'Passwords do not match';
                            }

                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (_) {
                            setState(() {});
                          },
                          onFieldSubmitted: (_) {},
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                          obscureText: !showConfirmPassword,
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'Enter password again',
                            isDense: true,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            filled: true,
                            fillColor: context.colorScheme.primaryContainer,
                            hoverColor: Colors.transparent,
                            suffixIcon: IconButton(
                              tooltip: 'Show password',
                              color: context.colorScheme.onPrimaryContainer,
                              icon: Icon(
                                showConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  showConfirmPassword = !showConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: borderRadius,
                              borderSide: const BorderSide(width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: borderRadius,
                              borderSide: BorderSide(
                                color: context.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: borderRadius,
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                          cursorRadius: const Radius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CollapsableSwitcher(
                    open: error != null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.colorScheme.errorContainer,
                            borderRadius: borderRadius,
                            border: Border.all(
                              color: context.colorScheme.error,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            error ?? '',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CollapsableSwitcher(
                              open: mode.isForgotPassword,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          mode = AuthScreenMode.signIn;
                                          passwordController.clear();
                                          confirmPasswordController.clear();
                                          error = null;
                                        });
                                      },
                                child: Text(
                                    '${AuthScreenMode.signIn.label} instead'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        mode = mode.isSignUp
                                            ? AuthScreenMode.signIn
                                            : AuthScreenMode.signUp;
                                        passwordController.clear();
                                        confirmPasswordController.clear();
                                        error = null;
                                      });
                                    },
                              child: Text(
                                mode.isSignUp
                                    ? 'Log in instead'
                                    : 'Sign up instead',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  switch (mode) {
                                    case AuthScreenMode.signIn:
                                      signIn();
                                      break;
                                    case AuthScreenMode.signUp:
                                      signUp();
                                      break;
                                    case AuthScreenMode.forgotPassword:
                                      forgotPassword();
                                      break;
                                  }
                                },
                          icon: isLoading
                              ? CupertinoActivityIndicator(
                                  color: context.colorScheme.primary,
                                )
                              : const SizedBox.shrink(),
                          label: Text(
                            mode.isForgotPassword
                                ? 'Send password reset email'
                                : mode.isSignUp
                                    ? 'Sign up'
                                    : 'Sign in',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
