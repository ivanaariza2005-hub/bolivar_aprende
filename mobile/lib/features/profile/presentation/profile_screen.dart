import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_view.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../navigation/app_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final auth = context.read<AuthProvider>();

    final confirmed = await showConfirmDialog(
      context,
      title: 'Cerrar sesión',
      message:
          '¿Quieres salir de tu cuenta? Podrás volver a ingresar cuando quieras.',
      confirmLabel: 'Cerrar sesión',
      isDestructive: true,
    );

    if (!confirmed) {
      return;
    }

    navigator.popUntil((route) => route.isFirst);
    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (headerContext) => IconButton(
            tooltip: 'Abrir menú',
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(headerContext).openDrawer(),
          ),
        ),
        title: const Text('Mi perfil'),
      ),
      drawer: const AppDrawer(section: DrawerSection.profile),
      body: user == null
          ? StateView.empty(
              icon: Icons.person_off_outlined,
              title: 'No hay una sesión activa',
              message: 'Inicia sesión para consultar tu perfil.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.surfaceElevated,
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    user.fullName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _InfoRow(
                          label: 'Nombre completo',
                          value: user.fullName,
                        ),
                        const Divider(height: AppSpacing.xl),
                        _InfoRow(
                          label: 'Correo electrónico',
                          value: user.email,
                        ),
                        const Divider(height: AppSpacing.xl),
                        _InfoRow(
                          label: 'Miembro desde',
                          value: DateFormatter.long(user.createdAt),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'La edición de perfil no está disponible en esta versión.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
