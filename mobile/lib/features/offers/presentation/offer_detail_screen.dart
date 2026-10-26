import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/offer.dart';
import 'offer_form_screen.dart';
import 'offers_provider.dart';

class OfferDetailScreen extends StatefulWidget {
  const OfferDetailScreen({
    super.key,
    required this.offer,
    required this.provider,
  });

  final Offer offer;
  final OffersProvider provider;

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  late Offer _offer = widget.offer;
  bool _isSaving = false;

  Future<void> _toggleSaved() async {
    setState(() => _isSaving = true);

    final saved = await widget.provider.toggleSaved(_offer);

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    if (saved == null) {
      showAppSnackBar(
        context,
        widget.provider.errorMessage ?? 'No fue posible actualizar la oferta.',
      );
      return;
    }

    setState(() => _offer = _offer.copyWith(isSaved: saved));
    showAppSnackBar(
      context,
      saved ? 'Oferta guardada.' : 'Oferta eliminada de guardadas.',
    );
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<Offer>(
      MaterialPageRoute<Offer>(
        builder: (_) =>
            OfferFormScreen(provider: widget.provider, offer: _offer),
      ),
    );

    if (updated == null || !mounted) {
      return;
    }

    setState(() => _offer = updated);
    showAppSnackBar(context, 'Oferta actualizada.');
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar oferta',
      message:
          'Esta acción no se puede deshacer. La oferta dejará de estar disponible para todos los usuarios.',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );

    if (!confirmed || !mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final deleted = await widget.provider.deleteOffer(_offer.id);

    if (!mounted) {
      return;
    }

    if (!deleted) {
      showAppSnackBar(
        context,
        widget.provider.errorMessage ?? 'No fue posible eliminar la oferta.',
      );
      return;
    }

    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Oferta eliminada.')));
  }

  Future<void> _selectAction(String action) async {
    if (action == 'edit') {
      await _edit();
      return;
    }

    await _delete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: 'Opciones de la oferta',
            icon: const Icon(Icons.more_vert),
            onSelected: _selectAction,
            itemBuilder: (menuContext) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: AppSpacing.md),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.danger,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text('Eliminar', style: TextStyle(color: AppColors.danger)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                AppTag(
                  icon: _offer.type.icon,
                  label: _offer.type.label,
                  isHighlighted: true,
                ),
                AppTag(
                  icon: _offer.modality.icon,
                  label: _offer.modality.label,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(_offer.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(_offer.institution, style: theme.textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.md),
            AppMetaRow(icon: Icons.place_outlined, text: _offer.municipality),
            const SizedBox(height: AppSpacing.xs),
            AppMetaRow(
              icon: Icons.calendar_today_outlined,
              text: 'Publicada el ${DateFormatter.long(_offer.createdAt)}',
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Semantics(
              header: true,
              child: Text('Descripción', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _offer.description,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Última actualización: ${DateFormatter.long(_offer.updatedAt)}',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: _offer.isSaved ? 'Quitar de guardadas' : 'Guardar oferta',
              icon: _offer.isSaved ? Icons.bookmark : Icons.bookmark_border,
              isLoading: _isSaving,
              onPressed: _toggleSaved,
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _edit,
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: const Text('Editar oferta'),
            ),
          ],
        ),
      ),
    );
  }
}
