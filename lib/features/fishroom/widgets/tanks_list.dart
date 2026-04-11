import 'dart:convert';

import 'package:disnet_manager/features/fishroom/cubit/fishroom_cubit.dart';
import 'package:disnet_manager/features/loader/main_loader.dart';
import 'package:disnet_manager/models/app_user.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:disnet_manager/models/tank.dart';
import 'package:disnet_manager/models/tank_inhabitant.dart';
import 'package:disnet_manager/models/tank_target.dart';
import 'package:disnet_manager/widgets/custom_list_item.dart';
import 'package:disnet_manager/widgets/search_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class TanksList extends StatefulWidget {
  const TanksList({super.key});

  @override
  State<TanksList> createState() => _TanksListState();
}

class _TanksListState extends State<TanksList> {
  bool loading = false;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  FishroomCubit get cubit => context.read<FishroomCubit>();

  List<Tank> _filteredTanks(List<Tank> tanks) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return tanks;
    }

    return tanks.where((tank) {
      return (tank.name ?? '').toLowerCase().contains(query) ||
          (tank.tankType ?? '').toLowerCase().contains(query) ||
          (tank.ownerId ?? '').toLowerCase().contains(query) ||
          tank.id.toLowerCase().contains(query) ||
          _sizeLabel(tank).toLowerCase().contains(query) ||
          _inhabitantsSearchLabel(tank).contains(query) ||
          _targetsSearchLabel(tank).contains(query);
    }).toList();
  }

  String _inhabitantsSearchLabel(Tank tank) {
    return tank.inhabitants
        .expand((inhabitant) => [
              inhabitant.displayName,
              inhabitant.petName,
              inhabitant.scientificName,
            ])
        .whereType<String>()
        .join(' ')
        .toLowerCase();
  }

  String _targetsSearchLabel(Tank tank) {
    return tank.targets
        .expand(
            (target) => [target.label, target.rangeLabel, target.shortLabel])
        .join(' ')
        .toLowerCase();
  }

  Future<void> _refreshTanks() async {
    setState(() => loading = true);
    try {
      await Future.wait([
        cubit.getTanks(),
        cubit.getUsers(),
      ]);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  String _sizeLabel(Tank tank) {
    if (tank.tankSize == null) {
      return 'Unknown';
    }

    final unit = tank.tankMeasurement?.trim();
    final size = _formatNumber(tank.tankSize!);
    if (unit == null || unit.isEmpty) {
      return size;
    }

    return '$size $unit';
  }

  String _dateLabel(DateTime? value) {
    if (value == null) {
      return 'Unknown';
    }

    final localValue = value.toLocal();
    final month = localValue.month.toString().padLeft(2, '0');
    final day = localValue.day.toString().padLeft(2, '0');
    final hour = localValue.hour.toString().padLeft(2, '0');
    final minute = localValue.minute.toString().padLeft(2, '0');

    return '${localValue.year}-$month-$day $hour:$minute';
  }

  String _inhabitantPreview(Tank tank) {
    if (tank.inhabitants.isEmpty) {
      return 'None listed';
    }

    final preview = tank.inhabitants
        .take(2)
        .map((inhabitant) => inhabitant.displayName)
        .join(', ');

    if (tank.inhabitants.length <= 2) {
      return preview;
    }

    return '$preview +${tank.inhabitants.length - 2} more';
  }

  String _targetPreview(Tank tank) {
    if (tank.targets.isEmpty) {
      return 'No targets';
    }

    final preview = tank.targets
        .take(2)
        .map((target) => '${target.label} ${target.shortLabel}')
        .join(' • ');

    if (tank.targets.length <= 2) {
      return preview;
    }

    return '$preview +${tank.targets.length - 2} more';
  }

  Widget _buildTankDetails(Tank tank, AppUser? owner) {
    return _TankDetails(
      tank: tank,
      owner: owner,
      cubit: cubit,
      sizeLabel: _sizeLabel(tank),
      createdAtLabel: _dateLabel(tank.createdAt),
    );
  }

  @override
  void initState() {
    _refreshTanks();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: BlocBuilder<FishroomCubit, FishroomState>(
        builder: (context, state) {
          final itemsFlex = [2, 2, 1, 1, 1, 1, 2];
          final filteredTanks = _filteredTanks(state.tanks);
          final usersById = {
            for (final user in state.users) user.id: user,
          };

          return loading
              ? const Center(child: MainLoader())
              : state.tanks.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Text(
                          'No tanks found.',
                          style: Constants.textStyles.description,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          ' All Tanks',
                          style: Constants.textStyles.title,
                          textAlign: TextAlign.left,
                        ),
                        const Gap(20),
                        SearchField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() => searchQuery = value);
                          },
                          onClear: () {
                            searchController.clear();
                            setState(() => searchQuery = '');
                          },
                          hintText:
                              'Search by name, type, inhabitants, owner id, or size',
                        ),
                        const Gap(16),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Builder(
                            builder: (context) {
                              final headerStyle =
                                  Constants.textStyles.description.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              );
                              return Row(
                                spacing: 20,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: itemsFlex[0],
                                    child: Text('Name', style: headerStyle),
                                  ),
                                  Expanded(
                                    flex: itemsFlex[1],
                                    child: Text('Type', style: headerStyle),
                                  ),
                                  Expanded(
                                    flex: itemsFlex[2],
                                    child: Text('Size', style: headerStyle),
                                  ),
                                  Expanded(
                                    flex: itemsFlex[3],
                                    child: Text('Stock', style: headerStyle),
                                  ),
                                  Expanded(
                                    flex: itemsFlex[4],
                                    child: Text('Readings', style: headerStyle),
                                  ),
                                  Expanded(
                                    flex: itemsFlex[5],
                                    child: Text('Streak', style: headerStyle),
                                  ),
                                  Expanded(
                                    flex: itemsFlex[6],
                                    child: Text('Owner ID', style: headerStyle),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        if (filteredTanks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'No tanks match your search.',
                              style: Constants.textStyles.description,
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...List.generate(filteredTanks.length, (index) {
                            final tank = filteredTanks[index];
                            final owner = tank.ownerId == null
                                ? null
                                : usersById[tank.ownerId!];
                            return CustomListItem(
                              openedWidget: _buildTankDetails(tank, owner),
                              itemsFlex: itemsFlex,
                              items: [
                                tank.name ?? 'Unnamed tank',
                                tank.tankType ?? 'Unknown',
                                _sizeLabel(tank),
                                '${tank.totalInhabitantCount}',
                                '${tank.readingCount}',
                                tank.streak?.toString() ?? '0',
                                tank.ownerId ?? 'No owner',
                              ],
                              secondaryItems: [
                                _dateLabel(tank.createdAt),
                                tank.id,
                                owner?.email ??
                                    (tank.tankMeasurement ?? 'No unit'),
                                '${tank.speciesCount} species',
                                _targetPreview(tank),
                                '${tank.achievementIds.length} achievements',
                                _inhabitantPreview(tank),
                              ],
                              index: index,
                            );
                          }),
                      ],
                    );
        },
      ),
    );
  }
}

class _TankDetails extends StatefulWidget {
  const _TankDetails({
    required this.tank,
    required this.owner,
    required this.cubit,
    required this.sizeLabel,
    required this.createdAtLabel,
  });

  final Tank tank;
  final AppUser? owner;
  final FishroomCubit cubit;
  final String sizeLabel;
  final String createdAtLabel;

  @override
  State<_TankDetails> createState() => _TankDetailsState();
}

class _TankDetailsState extends State<_TankDetails> {
  bool showReadings = false;
  Future<List<Map<String, dynamic>>>? readingsFuture;

  void _toggleReadings() {
    setState(() {
      showReadings = !showReadings;
      if (showReadings && readingsFuture == null) {
        readingsFuture = widget.cubit.getTankReadings(widget.tank.id);
      }
    });
  }

  String _titleCase(String value) {
    return value
        .split('_')
        .where((segment) => segment.isNotEmpty)
        .map(
          (segment) =>
              '${segment[0].toUpperCase()}${segment.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value == null) {
      return 'Unknown';
    }

    if (value is DateTime) {
      final month = value.month.toString().padLeft(2, '0');
      final day = value.day.toString().padLeft(2, '0');
      final hour = value.hour.toString().padLeft(2, '0');
      final minute = value.minute.toString().padLeft(2, '0');
      return '${value.year}-$month-$day $hour:$minute';
    }

    if (value is List) {
      return value.isEmpty ? 'None' : value.join(', ');
    }

    if (value is Map) {
      return value.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join(', ');
    }

    return value.toString();
  }

  String _formatScalar(dynamic value) {
    if (value == null) {
      return 'Unknown';
    }

    if (value is num) {
      return value == value.roundToDouble()
          ? value.toInt().toString()
          : value
              .toStringAsFixed(2)
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '');
    }

    return _formatValue(value);
  }

  dynamic _decodeStructuredValue(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          return jsonDecode(trimmed);
        } catch (_) {
          return value;
        }
      }
    }

    return value;
  }

  String _readingLabel(String key) {
    switch (key) {
      case 'ph':
        return 'pH';
      case 'kh':
        return 'KH';
      case 'gh':
        return 'GH';
      case 'created_at':
        return 'Created At';
      case 'updated_at':
        return 'Updated At';
      default:
        return _titleCase(key);
    }
  }

  bool _isReadingMetric(String key) {
    const metricKeys = {
      'ph',
      'temperature',
      'ammonia',
      'nitrite',
      'nitrate',
      'salinity',
      'kh',
      'gh',
    };

    return metricKeys.contains(key);
  }

  Map<String, dynamic> _formattedReadingMap(Map<String, dynamic> reading) {
    final formatted = <String, dynamic>{};
    for (final entry in _readingEntries(reading)) {
      final key = _readingLabel(entry.key);
      final rawValue = _decodeStructuredValue(entry.value);
      final value = entry.key.endsWith('_at')
          ? DateTime.tryParse(rawValue.toString())?.toLocal() ?? rawValue
          : rawValue;
      if (value is Map) {
        formatted[key] = _formattedNestedMap(value);
      } else if (value is List) {
        formatted[key] = _formattedNestedList(value);
      } else {
        formatted[key] =
            value is num ? _formatScalar(value) : _formatValue(value);
      }
    }

    return formatted;
  }

  Map<String, dynamic> _formattedNestedMap(Map<dynamic, dynamic> value) {
    final formatted = <String, dynamic>{};
    for (final entry in value.entries) {
      final key = _titleCase(entry.key.toString());
      final nestedValue = _decodeStructuredValue(entry.value);
      if (nestedValue is Map) {
        formatted[key] = _formattedNestedMap(nestedValue);
      } else if (nestedValue is List) {
        formatted[key] = _formattedNestedList(nestedValue);
      } else if (nestedValue is num) {
        formatted[key] = _formatScalar(nestedValue);
      } else {
        formatted[key] = _formatValue(nestedValue);
      }
    }

    return formatted;
  }

  List<dynamic> _formattedNestedList(List<dynamic> value) {
    return value.map((item) {
      final nestedValue = _decodeStructuredValue(item);
      if (nestedValue is Map) {
        return _formattedNestedMap(nestedValue);
      }

      if (nestedValue is List) {
        return _formattedNestedList(nestedValue);
      }

      if (nestedValue is num) {
        return _formatScalar(nestedValue);
      }

      return _formatValue(nestedValue);
    }).toList();
  }

  String _prettyReadingJson(Map<String, dynamic> reading) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(_formattedReadingMap(reading));
  }

  bool _hasDataField(Map<String, dynamic> reading) {
    return reading['data'] != null;
  }

  dynamic _readingDataField(Map<String, dynamic> reading) {
    return _decodeStructuredValue(reading['data']);
  }

  String _prettyDataJson(dynamic value) {
    const encoder = JsonEncoder.withIndent('  ');
    final decoded = _decodeStructuredValue(value);
    if (decoded is Map) {
      return encoder.convert(_formattedNestedMap(decoded));
    }

    if (decoded is List) {
      return encoder.convert(_formattedNestedList(decoded));
    }

    return _formatValue(decoded);
  }

  Widget _buildReadingMetricChip(MapEntry<String, dynamic> entry) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Constants.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_readingLabel(entry.key),
              style: Constants.textStyles.description),
          const Gap(4),
          Text(
            _formatScalar(entry.value),
            style: Constants.textStyles.title4.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPrettyJsonBlock(Map<String, dynamic> reading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Constants.colors.border),
      ),
      child: SelectableText(
        _prettyReadingJson(reading),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDataFieldBlock(dynamic value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Constants.colors.border),
      ),
      child: SelectableText(
        _prettyDataJson(value),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  List<MapEntry<String, dynamic>> _readingEntries(
      Map<String, dynamic> reading) {
    const hiddenKeys = {'id', 'tank_id'};
    final preferredOrder = [
      'created_at',
      'updated_at',
      'ph',
      'temperature',
      'ammonia',
      'nitrite',
      'nitrate',
      'salinity',
      'kh',
      'gh',
    ];

    final entries = reading.entries
        .where((entry) =>
            !hiddenKeys.contains(entry.key) &&
            entry.key != 'data' &&
            entry.value != null)
        .toList();

    entries.sort((a, b) {
      final aIndex = preferredOrder.indexOf(a.key);
      final bIndex = preferredOrder.indexOf(b.key);
      if (aIndex == -1 && bIndex == -1) {
        return a.key.compareTo(b.key);
      }
      if (aIndex == -1) {
        return 1;
      }
      if (bIndex == -1) {
        return -1;
      }
      return aIndex.compareTo(bIndex);
    });

    return entries;
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: Constants.textStyles.title4);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Constants.textStyles.description),
          const Gap(2),
          SelectableText(value),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Constants.colors.primary.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Constants.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Constants.textStyles.description),
          const Gap(4),
          Text(value, style: Constants.textStyles.title4),
        ],
      ),
    );
  }

  String _inhabitantsHeadline(Tank tank) {
    if (tank.inhabitants.isEmpty) {
      return 'None listed';
    }

    final names = tank.inhabitants
        .take(3)
        .map((inhabitant) => inhabitant.displayName)
        .join(', ');

    if (tank.inhabitants.length <= 3) {
      return names;
    }

    return '$names +${tank.inhabitants.length - 3} more';
  }

  String _inhabitantIdLabel(String id) {
    if (id.length <= 8) {
      return id;
    }

    return id.substring(0, 8);
  }

  String _targetsHeadline(Tank tank) {
    if (tank.targets.isEmpty) {
      return 'None configured';
    }

    final names = tank.targets.take(3).map((target) => target.label).join(', ');
    if (tank.targets.length <= 3) {
      return names;
    }

    return '$names +${tank.targets.length - 3} more';
  }

  Widget _buildTargetChip(TankTarget target) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Constants.colors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Constants.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(target.label,
              style: Constants.textStyles.title4.copyWith(fontSize: 16)),
          const Gap(2),
          Text(target.shortLabel,
              style: Constants.textStyles.description
                  .copyWith(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildTargetsSection() {
    final targets = widget.tank.targets;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Constants.colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Water Targets'),
          const Gap(4),
          Text(
            targets.isEmpty
                ? 'No parameter targets have been configured for this tank.'
                : '${targets.length} target ranges configured for this tank.',
            style: Constants.textStyles.description,
          ),
          if (targets.isNotEmpty) ...[
            const Gap(16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: targets.map(_buildTargetChip).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInhabitantImage(TankInhabitant inhabitant) {
    final imageUrl = inhabitant.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 72,
        height: 72,
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInhabitantImageFallback();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Container(
                    color: Constants.colors.primary.withAlpha(12),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
            : _buildInhabitantImageFallback(),
      ),
    );
  }

  Widget _buildInhabitantImageFallback() {
    return Container(
      color: Constants.colors.primary.withAlpha(12),
      alignment: Alignment.center,
      child: Icon(
        Icons.phishing_outlined,
        color: Constants.colors.primary,
        size: 28,
      ),
    );
  }

  Widget _buildInhabitantCard(TankInhabitant inhabitant, int index) {
    final subtitleStyle = Constants.textStyles.description.copyWith(
      color: Colors.black87,
      fontStyle: FontStyle.italic,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            index.isEven ? Constants.colors.primary.withAlpha(8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Constants.colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInhabitantImage(inhabitant),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        inhabitant.displayName,
                        style: Constants.textStyles.title4.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Constants.colors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${inhabitant.count}',
                        style: Constants.textStyles.description.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (inhabitant.scientificName != null) ...[
                  const Gap(4),
                  Text(inhabitant.scientificName!, style: subtitleStyle),
                ],
                if (inhabitant.hasPetName) ...[
                  const Gap(8),
                  Text(
                    'Pet name: ${inhabitant.petName}',
                    style: Constants.textStyles.description.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ],
                const Gap(8),
                Text(
                  inhabitant.count == 1
                      ? '1 individual in this tank'
                      : '${inhabitant.count} individuals in this tank',
                  style: Constants.textStyles.description,
                ),
                const Gap(4),
                Text(
                  'Record ${_inhabitantIdLabel(inhabitant.id)}',
                  style: Constants.textStyles.data.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInhabitantsSection() {
    final inhabitants = widget.tank.inhabitants;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Constants.colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Tank Inhabitants'),
          const Gap(4),
          Text(
            inhabitants.isEmpty
                ? 'No inhabitants have been listed for this tank.'
                : '${widget.tank.totalInhabitantCount} total inhabitants across ${widget.tank.speciesCount} species entries.',
            style: Constants.textStyles.description,
          ),
          if (inhabitants.isNotEmpty) ...[
            const Gap(16),
            Column(
              children: List.generate(inhabitants.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == inhabitants.length - 1 ? 0 : 12,
                  ),
                  child: _buildInhabitantCard(inhabitants[index], index),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    final imageUrl = widget.tank.imageUrl?.trim();
    final hasImageUrl = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Constants.colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Tank Image'),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: hasImageUrl
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImageFallback(
                            'Image could not be loaded.');
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Container(
                          color: Constants.colors.primary.withAlpha(12),
                          alignment: Alignment.center,
                          child: const MainLoader(),
                        );
                      },
                    )
                  : _buildImageFallback(
                      'No remote image available for this tank.'),
            ),
          ),
          const Gap(12),
          _buildInfoRow('Image URL', widget.tank.imageUrl ?? 'No image URL'),
          _buildInfoRow(
            'Image Local Path',
            widget.tank.imageLocalPath ?? 'No local image path',
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback(String message) {
    return Container(
      color: Constants.colors.primary.withAlpha(12),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        message,
        style: Constants.textStyles.description,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOwnerCard() {
    final owner = widget.owner;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Constants.colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Owner Details'),
          const Gap(12),
          _buildInfoRow('Owner ID', widget.tank.ownerId ?? 'No owner assigned'),
          _buildInfoRow('Name', owner?.name ?? 'Unknown'),
          _buildInfoRow('Email', owner?.email ?? 'Owner record not loaded'),
          _buildInfoRow(
            'Subscription',
            owner == null ? 'Unknown' : (owner.isPro ? 'Active' : 'Inactive'),
          ),
          _buildInfoRow(
            'Next Subscription Check',
            owner?.nextProCheck == null
                ? 'Not scheduled'
                : _formatValue(owner!.nextProCheck!.toLocal()),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingCard(Map<String, dynamic> reading, int index) {
    final entries = _readingEntries(reading);
    final createdAt = reading['created_at'];
    final metricEntries =
        entries.where((entry) => _isReadingMetric(entry.key)).toList();
    final hasDataField = _hasDataField(reading);
    final dataField = _readingDataField(reading);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Constants.colors.border),
        borderRadius: BorderRadius.circular(16),
        color:
            index.isEven ? Constants.colors.primary.withAlpha(8) : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            createdAt == null
                ? 'Reading ${index + 1}'
                : 'Reading ${index + 1} • ${_formatValue(DateTime.tryParse(createdAt.toString())?.toLocal() ?? createdAt)}',
            style: Constants.textStyles.title4.copyWith(fontSize: 18),
          ),
          const Gap(12),
          if (entries.isEmpty)
            Text('No reading fields were returned.',
                style: Constants.textStyles.description)
          else ...[
            if (metricEntries.isNotEmpty) ...[
              Text(
                'Snapshot',
                style: Constants.textStyles.description.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: metricEntries.map(_buildReadingMetricChip).toList(),
              ),
              const Gap(16),
            ],
            if (hasDataField) ...[
              Text(
                'Data',
                style: Constants.textStyles.description.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(10),
              _buildDataFieldBlock(dataField),
              const Gap(16),
            ],
            Text(
              'Formatted JSON',
              style: Constants.textStyles.description.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(10),
            _buildPrettyJsonBlock(reading),
          ],
        ],
      ),
    );
  }

  Widget _buildReadingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Constants.colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Tank Readings'),
              TextButton(
                onPressed: _toggleReadings,
                child: Text(showReadings ? 'Hide' : 'Show recent'),
              ),
            ],
          ),
          const Gap(4),
          Text(
            'Recent reading snapshots are loaded on demand.',
            style: Constants.textStyles.description,
          ),
          if (showReadings) ...[
            const Gap(16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: readingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: MainLoader());
                }

                if (snapshot.hasError) {
                  return Text(
                    'Unable to load tank readings.',
                    style: Constants.textStyles.description.copyWith(
                      color: Constants.colors.error,
                    ),
                  );
                }

                final readings = snapshot.data ?? const [];
                if (readings.isEmpty) {
                  return Text(
                    'No readings found for this tank.',
                    style: Constants.textStyles.description,
                  );
                }

                return Column(
                  children: List.generate(readings.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: index == readings.length - 1 ? 0 : 12),
                      child: _buildReadingCard(readings[index], index),
                    );
                  }),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tank = widget.tank;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Constants.colors.border,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(50),
          Text(tank.name ?? 'Unnamed tank', style: Constants.textStyles.title3),
          const Gap(6),
          Text(
            '${tank.tankType ?? 'Unknown type'} • ${widget.sizeLabel}',
            style: Constants.textStyles.description,
          ),
          const Gap(20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatChip('Stock', '${tank.totalInhabitantCount}'),
              _buildStatChip('Species', '${tank.speciesCount}'),
              _buildStatChip('Readings', '${tank.readingCount}'),
              _buildStatChip('Targets', '${tank.targets.length}'),
              _buildStatChip('Achievements', '${tank.achievementIds.length}'),
              _buildStatChip('Streak', tank.streak?.toString() ?? '0'),
            ],
          ),
          const Gap(20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final metadataCard = Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Constants.colors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Tank Details'),
                    const Gap(12),
                    _buildInfoRow('Tank ID', tank.id),
                    _buildInfoRow('Created At', widget.createdAtLabel),
                    _buildInfoRow('Type', tank.tankType ?? 'Unknown'),
                    _buildInfoRow('Size', widget.sizeLabel),
                    _buildInfoRow(
                        'Owner ID', tank.ownerId ?? 'No owner assigned'),
                    _buildInfoRow(
                      'Population',
                      tank.inhabitants.isEmpty
                          ? 'None listed'
                          : '${tank.totalInhabitantCount} individuals across ${tank.speciesCount} species',
                    ),
                    _buildInfoRow(
                      'Featured Species',
                      _inhabitantsHeadline(tank),
                    ),
                    _buildInfoRow(
                      'Targets',
                      tank.targets.isEmpty
                          ? 'None configured'
                          : '${tank.targets.length} configured ranges',
                    ),
                    _buildInfoRow(
                      'Target Focus',
                      _targetsHeadline(tank),
                    ),
                    _buildInfoRow(
                      'Achievement IDs',
                      tank.achievementIds.isEmpty
                          ? 'None unlocked'
                          : tank.achievementIds.join(', '),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildImageCard()),
                    const Gap(16),
                    Expanded(child: metadataCard),
                    const Gap(16),
                    Expanded(child: _buildOwnerCard()),
                  ],
                );
              }

              return Column(
                children: [
                  _buildImageCard(),
                  const Gap(16),
                  metadataCard,
                  const Gap(16),
                  _buildOwnerCard(),
                ],
              );
            },
          ),
          const Gap(20),
          _buildTargetsSection(),
          const Gap(20),
          _buildInhabitantsSection(),
          const Gap(20),
          _buildReadingsSection(),
        ],
      ),
    );
  }
}
