import '../../../core/constants/offer_enums.dart';
import 'offer.dart';

class OfferDraft {
  const OfferDraft({
    required this.title,
    required this.description,
    required this.type,
    required this.institution,
    required this.municipality,
    required this.modality,
  });

  final String title;
  final String description;
  final OfferType type;
  final String institution;
  final String municipality;
  final OfferModality modality;

  factory OfferDraft.fromOffer(Offer offer) => OfferDraft(
        title: offer.title,
        description: offer.description,
        type: offer.type,
        institution: offer.institution,
        municipality: offer.municipality,
        modality: offer.modality,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title.trim(),
        'description': description.trim(),
        'type': type.name,
        'institution': institution.trim(),
        'municipality': municipality,
        'modality': modality.name,
      };
}
