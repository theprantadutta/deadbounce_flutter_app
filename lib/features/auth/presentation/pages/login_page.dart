import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/db_button.dart';
import '../../../../core/widgets/db_logo.dart';
import '../../../../core/widgets/db_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthCubit>().signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _showAppleComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Sign in with Apple is coming soon, partner.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
        } else if (state is AuthAuthenticated) {
          context.go(Routes.home);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading ? state.action : null;
        final anyLoading = loading != null;

        return AuthScaffold(
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: DbLogoLockup(logoSize: 72)),
                  const SizedBox(height: AppSpacing.xl),
                  DbTextField(
                    label: 'Email',
                    controller: _emailController,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.alternate_email,
                    enabled: !anyLoading,
                    autofillHints: const [AutofillHints.email],
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DbTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hint: '••••••••',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_outline,
                    enabled: !anyLoading,
                    autofillHints: const [AutofillHints.password],
                    validator: _validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DbPrimaryButton(
                    label: 'SIGN IN',
                    icon: Icons.login,
                    loading: loading == AuthAction.email,
                    onPressed: anyLoading ? null : _submitEmail,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text('OR RIDE WITH', style: textTheme.labelSmall),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DbSecondaryButton(
                    label: 'CONTINUE WITH GOOGLE',
                    icon: Icons.g_mobiledata,
                    loading: loading == AuthAction.google,
                    onPressed: anyLoading
                        ? null
                        : () => context.read<AuthCubit>().signInWithGoogle(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DbSecondaryButton(
                    label: 'CONTINUE WITH APPLE',
                    icon: Icons.apple,
                    onPressed: anyLoading ? null : _showAppleComingSoon,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DbSecondaryButton(
                    label: 'CONTINUE AS GUEST',
                    icon: Icons.person_outline,
                    loading: loading == AuthAction.guest,
                    onPressed: anyLoading
                        ? null
                        : () => context.read<AuthCubit>().signInAsGuest(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('New in town?', style: textTheme.bodyMedium),
                      TextButton(
                        onPressed: anyLoading
                            ? null
                            : () => context.push(Routes.signup),
                        child: const Text('CREATE ACCOUNT'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }
}
