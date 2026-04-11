class TankInhabitant {
  final String id;
  final int count;
  final String? petName;
  final String? imageUrl;
  final String? commonName;
  final String? scientificName;

  const TankInhabitant({
    required this.id,
    this.count = 1,
    this.petName,
    this.imageUrl,
    this.commonName,
    this.scientificName,
  });

  factory TankInhabitant.fromDynamic(dynamic value) {
    if (value is TankInhabitant) {
      return value;
    }

    if (value is Map) {
      return TankInhabitant.fromMap(Map<String, dynamic>.from(value));
    }

    final fallback = _readString(value) ?? 'Unknown inhabitant';
    return TankInhabitant(
      id: fallback,
      commonName: fallback,
    );
  }

  factory TankInhabitant.fromMap(Map<String, dynamic> map) {
    return TankInhabitant(
      id: _readString(map['id']) ?? 'unknown-inhabitant',
      count: _readCount(map['count']),
      petName: _readString(map['pet_name']),
      imageUrl: _readString(map['image_url']),
      commonName: _readString(map['common_name']),
      scientificName: _readString(map['scientific_name']),
    );
  }

  String get displayName => commonName ?? petName ?? scientificName ?? id;

  bool get hasPetName => petName != null && petName!.isNotEmpty;

  static String? _readString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static int _readCount(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed == null || parsed < 0) {
      return 1;
    }

    return parsed;
  }
}
