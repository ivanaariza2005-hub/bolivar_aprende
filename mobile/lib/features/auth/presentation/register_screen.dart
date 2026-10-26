import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_error_banner.dart';
import '../../../core/widgets/primary_button.dart';
import 'auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await context.read<AuthProvider>().register(
          fullName: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          passwordConfirmation: _confirmationController.text,
        );

    if (!success || !mounted) {
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isSubmitting = auth.isSubmitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: <Widget>[
              if (auth.errorMessage != null) ...<Widget>[
                FormErrorBanner(message: auth.errorMessage!),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppTextField(
                label: 'Nombre completo',
                controller: _fullNameController,
                validator: Validators.fullName,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const <String>[AutofillHints.name],
                enabled: !isSubmitting,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Correo electrónico',
                controller: _emailController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                enabled: !isSubmitting,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Contraseña',
                helper:
                    'Mínimo 8 caracteres, con al menos una letra y un número.',
                controller: _passwordController,
                validator: Validators.password,
                obscureText: true,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.newPassword],
                enabled: !isSubmitting,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Confirmar contraseña',
                controller: _confirmationController,
                validator: (value) => Validators.passwordConfirmation(
                  value,
                  _passwordController.text,
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                enabled: !isSubmitting,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Registrarme',
                isLoading: isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed:
                    isSubmitting ? null : () => Navigator.of(context).pop(),
                child: const Text('Ya tengo cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
