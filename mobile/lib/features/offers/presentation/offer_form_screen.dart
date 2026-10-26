import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/offer_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_error_banner.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/offer.dart';
import '../data/offer_draft.dart';
import 'offers_provider.dart';
import 'widgets/municipality_picker.dart';

class OfferFormScreen extends StatefulWidget {
  const OfferFormScreen({super.key, required this.provider, this.offer});

  final OffersProvider provider;
  final Offer? offer;

  bool get isEditing => offer != null;

  @override
  State<OfferFormScreen> createState() => _OfferFormScreenState();
}

class _OfferFormScreenState extends State<OfferFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _institutionController;
  late final TextEditingController _descriptionController;
  late OfferType _type;
  late OfferModality _modality;

  String? _municipality;
  String? _municipalityError;
  String? _formError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final offer = widget.offer;
    _titleController = TextEditingController(text: offer?.title ?? '');
    _institutionController = TextEditingController(
      text: offer?.institution ?? '',
    );
    _descriptionController = TextEditingController(
      text: offer?.description ?? '',
    );
    _type = offer?.type ?? OfferType.job;
    _modality = offer?.modality ?? OfferModality.onsite;
    _municipality = offer?.municipality;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _institutionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickMunicipality() async {
    final result = await showMunicipalityPicker(
      context,
      selected: _municipality,
    );

    if (result == null) {
      return;
    }

    setState(() {
      _municipality = result;
      _municipalityError = null;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    final municipality = _municipality;

    setState(() {
      _municipalityError =
          municipality == null ? 'Selecciona un municipio de Bolívar.' : null;
      _formError = null;
    });

    if (!isValid || municipality == null) {
      return;
    }

    final draft = OfferDraft(
      title: _titleController.text,
      description: _descriptionController.text,
      type: _type,
      institution: _institutionController.text,
      municipality: municipality,
      modality: _modality,
    );

    setState(() => _isSaving = true);

    final existingOffer = widget.offer;
    final result = existingOffer == null
        ? await widget.provider.createOffer(draft)
        : await widget.provider.updateOffer(existingOffer.id, draft);

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    if (result == null) {
      setState(() {
        _formError = widget.provider.errorMessage ??
            'No fue posible guardar la oferta. Intenta de nuevo.';
      });
      return;
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar oferta' : 'Publicar oferta'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: <Widget>[
              if (_formError != null) ...<Widget>[
                FormErrorBanner(message: _formError!),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppTextField(
                label: 'Título de la oferta',
                controller: _titleController,
                validator: Validators.title,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 120,
                enabled: !_isSaving,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Institución',
                helper: 'Empresa o institución educativa que publica.',
                controller: _institutionController,
                validator: Validators.institution,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                maxLength: 120,
                enabled: !_isSaving,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Tipo de oferta', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SelectableCard(
                      icon: OfferType.job.icon,
                      label: OfferType.job.label,
                      selected: _type == OfferType.job,
                      onTap: () => setState(() => _type = OfferType.job),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _SelectableCard(
                      icon: OfferType.academic.icon,
                      label: OfferType.academic.label,
                      selected: _type == OfferType.academic,
                      onTap: () => setState(() => _type = OfferType.academic),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Modalidad', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SelectableCard(
                      icon: OfferModality.onsite.icon,
                      label: OfferModality.onsite.label,
                      selected: _modality == OfferModality.onsite,
                      onTap: () =>
                          setState(() => _modality = OfferModality.onsite),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _SelectableCard(
                      icon: OfferModality.remote.icon,
                      label: OfferModality.remote.label,
                      selected: _modality == OfferModality.remote,
                      onTap: () =>
                          setState(() => _modality = OfferModality.remote),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _SelectableCard(
                      icon: OfferModality.hybrid.icon,
                      label: OfferModality.hybrid.label,
                      selected: _modality == OfferModality.hybrid,
                      onTap: () =>
                          setState(() => _modality = OfferModality.hybrid),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              InkWell(
                onTap: _isSaving ? null : _pickMunicipality,
                borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
                child: InputDecorator(
                  isEmpty: _municipality == null,
                  decoration: InputDecoration(
                    labelText: 'Municipio',
                    errorText: _municipalityError,
                    suffixIcon: const Icon(Icons.expand_more),
                  ),
                  child: Text(
                    _municipality ?? 'Selecciona un municipio',
                    style: TextStyle(
                      fontSize: 16,
                      color: _municipality == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Descripción',
                helper: 'Incluye requisitos, duración y beneficios.',
                controller: _descriptionController,
                validator: Validators.description,
                maxLines: 6,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
                enabled: !_isSaving,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: widget.isEditing ? 'Guardar cambios' : 'Publicar oferta',
                isLoading: _isSaving,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Las ofertas se publican a nombre de la institución indicada.',
                style: theme.textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textSecondary;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentSoft : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 22, color: color),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
