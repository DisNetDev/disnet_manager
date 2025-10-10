import 'package:disnet_manager/models/app_user.dart';
import 'package:disnet_manager/models/fish.dart';

class FishSuggestion {
  final String id;
  final String? createdAt;
  final String? commonName;
  final String? scientificName;
  final String? imageUrl;
  final AppUser? createdBy;
  final Fish? fish;

  FishSuggestion({
    required this.id,
    this.createdAt,
    this.commonName,
    this.scientificName,
    this.imageUrl,
    this.createdBy,
    this.fish,
  });

  factory FishSuggestion.fromJson(Map<String, dynamic> json) {
    return FishSuggestion(
      id: json['id'] as String,
      createdAt: json['created_at'] as String?,
      commonName: json['common_name'] as String?,
      scientificName: json['scientific_name'] as String?,
      imageUrl: json['image_url'] as String?,
      createdBy: json['created_by'] != null
          ? AppUser.fromMap(json['user'] as Map<String, dynamic>)
          : null,
      fish: json['fish'] != null
          ? Fish.fromJson(json['fish'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'common_name': commonName,
      'scientific_name': scientificName,
      'image_url': imageUrl,
      'created_by': createdBy?.toMap(),
      'fish': fish,
    };
  }
}
