import 'package:disnet_manager/models/tank_inhabitant.dart';
import 'package:disnet_manager/models/tank_target.dart';

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
  final List<TankInhabitant> inhabitants;
  final List<TankTarget> targets;
  final List<String> achievementIds;
  final int? streak;
  final int readingCount;

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
    this.readingCount = 0,
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
      inhabitants: _parseInhabitants(map['inhabitants']),
      targets: _parseTargets(map['targets']),
      achievementIds: ((map['achievement_ids'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(),
      streak: (map['streak'] as num?)?.toInt(),
      readingCount: (map['reading_count'] as num?)?.toInt() ?? 0,
    );
  }

  int get totalInhabitantCount =>
      inhabitants.fold(0, (sum, inhabitant) => sum + inhabitant.count);

  int get speciesCount => inhabitants.length;

  static List<TankInhabitant> _parseInhabitants(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.map(TankInhabitant.fromDynamic).toList();
  }

  static List<TankTarget> _parseTargets(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.map(TankTarget.fromDynamic).toList();
  }
}
