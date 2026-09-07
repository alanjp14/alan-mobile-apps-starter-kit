import 'package:amds_core/amds_core.dart';
import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _formError;
  int _shake = 0;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _formError = null);
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final error = await ref
        .read(authControllerProvider.notifier)
        .signIn(_email.text, _password.text);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _formError = error;
      if (error != null) _shake++;
    });
    // On success the router redirect sends us to the item list.
  }

  @override
  Widget build(BuildContext context) {
    final c = context.amds.colors;

    return AmdsScaffold(
      scrollable: false,
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AmdsSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AmdsShake(
              trigger: _shake,
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AmdsSpacing.lg),
                    Text('Welcome back', style: context.text.headlineSmall),
                    const SizedBox(height: AmdsSpacing.xs),
                    Text(
                      'Use any email and a password of 8+ characters.',
                      style: AmdsTextStyles.bodySmall
                          .copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: AmdsSpacing.xl),
                    AmdsTextField(
                      label: 'Email',
                      controller: _email,
                      required: true,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.alternate_email,
                      validator: Validators.all([
                        Validators.required(),
                        Validators.email(),
                      ]),
                    ),
                    const SizedBox(height: AmdsSpacing.md),
                    AmdsPasswordField(
                      label: 'Password',
                      controller: _password,
                      required: true,
                      validator: Validators.all([
                        Validators.required(),
                        Validators.minLength(8),
                      ]),
                    ),
                    if (_formError != null) ...[
                      const SizedBox(height: AmdsSpacing.md),
                      AmdsBanner(
                          message: _formError!, tone: AmdsStatusTone.danger),
                    ],
                    const SizedBox(height: AmdsSpacing.xl),
                    AmdsButton(
                      label: 'Sign in',
                      fullWidth: true,
                      size: AmdsButtonSize.lg,
                      loading: _submitting,
                      onPressed: _submitting ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
