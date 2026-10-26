import '../../../core/constants/offer_enums.dart';

class Offer {
  const Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.institution,
    required this.municipality,
    required this.modality,
    required this.isSaved,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final OfferType type;
  final String institution;
  final String municipality;
  final OfferModality modality;
  final bool isSaved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Offer copyWith({bool? isSaved}) => Offer(
        id: id,
        title: title,
        description: description,
        type: type,
        institution: institution,
        municipality: municipality,
        modality: modality,
        isSaved: isSaved ?? this.isSaved,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: OfferType.fromApi(json['type'] as String),
        institution: json['institution'] as String,
        municipality: json['municipality'] as String,
        modality: OfferModality.fromApi(json['modality'] as String),
        isSaved: json['isSaved'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      );
}
