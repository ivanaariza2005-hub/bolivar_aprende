import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading || !isEnabled ? null : onPressed;

    if (isLoading) {
      return FilledButton(
        onPressed: null,
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    if (icon == null) {
      return FilledButton(onPressed: effectiveOnPressed, child: Text(label));
    }

    return FilledButton.icon(
      onPressed: effectiveOnPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
