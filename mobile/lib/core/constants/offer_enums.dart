import 'package:flutter/material.dart';

enum OfferType {
  job,
  academic;

  String get label {
    switch (this) {
      case OfferType.job:
        return 'Laboral';
      case OfferType.academic:
        return 'Académica';
    }
  }

  IconData get icon {
    switch (this) {
      case OfferType.job:
        return Icons.work_outline;
      case OfferType.academic:
        return Icons.school_outlined;
    }
  }

  static OfferType fromApi(String value) => OfferType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => OfferType.job,
      );
}

enum OfferModality {
  onsite,
  remote,
  hybrid;

  String get label {
    switch (this) {
      case OfferModality.onsite:
        return 'Presencial';
      case OfferModality.remote:
        return 'Remoto';
      case OfferModality.hybrid:
        return 'Híbrido';
    }
  }

  IconData get icon {
    switch (this) {
      case OfferModality.onsite:
        return Icons.apartment_outlined;
      case OfferModality.remote:
        return Icons.wifi;
      case OfferModality.hybrid:
        return Icons.compare_arrows;
    }
  }

  static OfferModality fromApi(String value) => OfferModality.values.firstWhere(
        (modality) => modality.name == value,
        orElse: () => OfferModality.onsite,
      );
}
