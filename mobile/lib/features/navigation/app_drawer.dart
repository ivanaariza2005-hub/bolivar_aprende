import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../auth/presentation/auth_provider.dart';
import '../offers/presentation/saved_offers_screen.dart';
import '../profile/presentation/profile_screen.dart';

enum DrawerSection { home, saved, profile }

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.section});

  final DrawerSection section;

  void _navigate(BuildContext context, DrawerSection target) {
    final navigator = Navigator.of(context);
    navigator.pop();

    if (target == section) {
      return;
    }

    if (target == DrawerSection.home) {
      navigator.popUntil((route) => route.isFirst);
      return;
    }

    final route = target == DrawerSection.saved
        ? MaterialPageRoute<void>(builder: (_) => const SavedOffersScreen())
        : MaterialPageRoute<void>(builder: (_) => const ProfileScreen());

    if (section == DrawerSection.home) {
      navigator.push(route);
      return;
    }

    navigator.pushReplacement(route);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final auth = context.read<AuthProvider>();
    navigator.pop();

    final confirmed = await showConfirmDialog(
      navigator.context,
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
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Drawer(
      backgroundColor: AppColors.surface,
      width: 280,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.surfaceElevated,
                    child: Text(
                      user?.initials ?? '?',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user?.fullName ?? 'Usuario',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.home_outlined,
              label: 'Inicio',
              selected: section == DrawerSection.home,
              onTap: () => _navigate(context, DrawerSection.home),
            ),
            _DrawerItem(
              icon: Icons.bookmark_border,
              label: 'Mis ofertas guardadas',
              selected: section == DrawerSection.saved,
              onTap: () => _navigate(context, DrawerSection.saved),
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'Mi perfil',
              selected: section == DrawerSection.profile,
              onTap: () => _navigate(context, DrawerSection.profile),
            ),
            const Spacer(),
            const Divider(),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Cerrar sesión',
              isDestructive: true,
              onTap: () => _confirmLogout(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.danger
        : selected
            ? AppColors.accent
            : AppColors.textPrimary;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.accentSoft : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 22, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
