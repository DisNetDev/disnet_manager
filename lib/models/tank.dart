class Tank {
  final String id;
  final DateTime? createdAt;
  final double? tankSize;
  final String? tankMeasurement;
  final String? imageUrl;
  final String? ownerId;
  final String? name;
  final String? tankType;
  final String? imageLocalPath;
  final List<dynamic> inhabitants;
  final List<dynamic> targets;
  final List<String> achievementIds;
  final int? streak;

  Tank({
    required this.id,
    this.createdAt,
    this.tankSize,
    this.tankMeasurement,
    this.imageUrl,
    this.ownerId,
    this.name,
    this.tankType,
    this.imageLocalPath,
    this.inhabitants = const [],
    this.targets = const [],
    this.achievementIds = const [],
    this.streak,
  });

  factory Tank.fromMap(Map<String, dynamic> map) {
    return Tank(
      id: map['id'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      tankSize: (map['tank_size'] as num?)?.toDouble(),
      tankMeasurement: map['tank_measurement'] as String?,
      imageUrl: map['image_url'] as String?,
      ownerId: map['owner_id'] as String?,
      name: map['name'] as String?,
      tankType: map['tank_type'] as String?,
      imageLocalPath: map['image_local_path'] as String?,
      inhabitants: (map['inhabitants'] as List?)?.toList() ?? const [],
      targets: (map['targets'] as List?)?.toList() ?? const [],
      achievementIds: ((map['achievement_ids'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(),
      streak: (map['streak'] as num?)?.toInt(),
    );
  }
}
