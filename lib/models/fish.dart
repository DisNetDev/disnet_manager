class Fish {
  final String id;
  final String? commonName;
  final String? scientificName;
  final String? imageUrl;

  Fish({
    required this.id,
    this.commonName,
    this.scientificName,
    this.imageUrl,
  });

  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      id: json['id'] as String,
      commonName: json['common_name'] as String?,
      scientificName: json['scientific_name'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'common_name': commonName,
      'scientific_name': scientificName,
      'image_url': imageUrl,
    };
  }
}
