import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../managers/auth/auth_manager.dart';
import '../../ui/switchers.dart';
import '../../ui/theme_extensions.dart';
import '../../ui/window_controls.dart';

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

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isSigningUp = false;

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
    if (formKey.currentState?.validate() == false) {
      await AuthManager.instance.signUp(
        emailController.text,
        passwordController.text,
      );
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
          isSigningUp ? 'Sign up' : 'Sign in',
          style: context.textTheme.titleMedium,
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
                      color: context.colorScheme.onSecondaryContainer,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Enter your email',
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      filled: true,
                      fillColor: context.colorScheme.secondaryContainer
                          .withOpacity(0.5),
                      hoverColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: const BorderSide(width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: BorderSide(
                          color: context.colorScheme.primary,
                          width: 1,
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
                  Text(
                    'Password',
                    style: context.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    maxLength: 10000,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textInputAction: isSigningUp
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
                      if (isSigningUp) {
                        Focus.of(context).nextFocus();
                      } else {
                        signIn();
                      }
                    },
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSecondaryContainer,
                    ),
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Enter a password',
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      filled: true,
                      fillColor: context.colorScheme.secondaryContainer
                          .withOpacity(0.5),
                      hoverColor: Colors.transparent,
                      suffixIcon: IconButton(
                        tooltip: 'Show password',
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
                          width: 1,
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
                  if (!isSigningUp) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (isSigningUp) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Confirm Password',
                      style: context.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
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

                        if (value != passwordController.text) {
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
                        color: context.colorScheme.onSecondaryContainer,
                      ),
                      obscureText: !showConfirmPassword,
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'Enter password again',
                        isDense: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: context.colorScheme.secondaryContainer
                            .withOpacity(0.5),
                        hoverColor: Colors.transparent,
                        suffixIcon: IconButton(
                          tooltip: 'Show password',
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
                            width: 1,
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
                  const SizedBox(height: 16),
                  CollapsableSwitcher(
                    open: error != null,
                    child: Text(
                      error ?? '',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: Text(
                            isSigningUp ? 'Log in instead' : 'Sign up instead'),
                        onPressed: () {
                          setState(() {
                            isSigningUp = !isSigningUp;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: () {
                          if (isSigningUp) {
                            signUp();
                          } else {
                            signIn();
                          }
                        },
                        icon: isLoading
                            ? const CupertinoActivityIndicator()
                            : const SizedBox.shrink(),
                        label: Text(isSigningUp ? 'Sign up' : 'Sign in'),
                      ),
                    ],
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
