class TankTarget {
  final int paramId;
  final double? minValue;
  final double? maxValue;

  const TankTarget({
    required this.paramId,
    this.minValue,
    this.maxValue,
  });

  factory TankTarget.fromDynamic(dynamic value) {
    if (value is TankTarget) {
      return value;
    }

    if (value is Map) {
      return TankTarget.fromMap(Map<String, dynamic>.from(value));
    }

    return const TankTarget(paramId: -1);
  }

  factory TankTarget.fromMap(Map<String, dynamic> map) {
    return TankTarget(
      paramId: _readInt(map['param_id']) ?? -1,
      minValue: _readDouble(map['min_value']),
      maxValue: _readDouble(map['max_value']),
    );
  }

  String get label => switch (paramId) {
        1 => 'pH',
        2 => 'Ammonia',
        3 => 'Nitrite',
        4 => 'Nitrate',
        5 => 'Salinity',
        6 => 'KH',
        7 => 'GH',
        _ => 'Parameter $paramId',
      };

  String? get unit => switch (paramId) {
        1 => null,
        2 || 3 || 4 => 'ppm',
        5 => 'ppt',
        6 => 'dKH',
        7 => 'ppm',
        _ => null,
      };

  bool get hasRange => minValue != null || maxValue != null;

  String get rangeLabel {
    final min = minValue;
    final max = maxValue;
    final unitSuffix = unit == null ? '' : ' $unit';

    if (min != null && max != null) {
      return '${_formatNumber(min)} to ${_formatNumber(max)}$unitSuffix';
    }

    if (min != null) {
      return 'Minimum ${_formatNumber(min)}$unitSuffix';
    }

    if (max != null) {
      return 'Maximum ${_formatNumber(max)}$unitSuffix';
    }

    return 'No range configured';
  }

  String get shortLabel {
    final min = minValue;
    final max = maxValue;
    if (min != null && max != null) {
      return '${_formatNumber(min)}-${_formatNumber(max)}${unit == null ? '' : ' $unit'}';
    }

    return rangeLabel;
  }

  static int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static double? _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  static String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
  }
}
