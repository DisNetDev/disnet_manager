import 'package:disnet_manager/features/fishroom/cubit/fishroom_cubit.dart';
import 'package:disnet_manager/features/loader/main_loader.dart';
import 'package:disnet_manager/models/app_user.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:disnet_manager/models/tank.dart';
import 'package:disnet_manager/widgets/custom_list_item.dart';
import 'package:disnet_manager/widgets/search_field.dart';
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
          _sizeLabel(tank).toLowerCase().contains(query);
    }).toList();
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
                          hintText: 'Search by name, type, owner id, or size',
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
                                    child: Text('Fish', style: headerStyle),
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
                                '${tank.inhabitants.length}',
                                '${tank.readingCount}',
                                tank.streak?.toString() ?? '0',
                                tank.ownerId ?? 'No owner',
                              ],
                              secondaryItems: [
                                _dateLabel(tank.createdAt),
                                tank.id,
                                owner?.email ??
                                    (tank.tankMeasurement ?? 'No unit'),
                                'Inhabitants',
                                'Readings Count',
                                '${tank.achievementIds.length} achievements',
                                'Tap to inspect',
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
        .where(
            (entry) => !hiddenKeys.contains(entry.key) && entry.value != null)
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
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: entries.map((entry) {
                return SizedBox(
                  width: 220,
                  child: _buildInfoRow(
                    _titleCase(entry.key),
                    _formatValue(entry.value),
                  ),
                );
              }).toList(),
            ),
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
              _buildStatChip('Fish', '${tank.inhabitants.length}'),
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
                      'Inhabitants',
                      tank.inhabitants.isEmpty
                          ? 'None listed'
                          : tank.inhabitants.join(', '),
                    ),
                    _buildInfoRow(
                      'Targets',
                      tank.targets.isEmpty
                          ? 'None configured'
                          : tank.targets.join(', '),
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
          _buildReadingsSection(),
        ],
      ),
    );
  }
}
