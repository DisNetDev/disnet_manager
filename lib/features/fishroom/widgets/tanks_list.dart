import 'package:disnet_manager/features/fishroom/cubit/fishroom_cubit.dart';
import 'package:disnet_manager/features/loader/main_loader.dart';
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
      await cubit.getTanks();
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

    return value.toLocal().toString();
  }

  Widget _buildTankDetails(Tank tank) {
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
          Text('Tank Details', style: Constants.textStyles.title4),
          const Gap(16),
          Text('Name', style: Constants.textStyles.title4),
          Text(tank.name ?? 'Unnamed tank'),
          const Gap(12),
          Text('Tank ID', style: Constants.textStyles.title4),
          Text(tank.id),
          const Gap(12),
          Text('Owner ID', style: Constants.textStyles.title4),
          Text(tank.ownerId ?? 'No owner assigned'),
          const Gap(12),
          Text('Type', style: Constants.textStyles.title4),
          Text(tank.tankType ?? 'Unknown'),
          const Gap(12),
          Text('Size', style: Constants.textStyles.title4),
          Text(_sizeLabel(tank)),
          const Gap(12),
          Text('Created At', style: Constants.textStyles.title4),
          Text(_dateLabel(tank.createdAt)),
          const Gap(12),
          Text('Inhabitants', style: Constants.textStyles.title4),
          Text('${tank.inhabitants.length}'),
          const Gap(12),
          Text('Targets', style: Constants.textStyles.title4),
          Text('${tank.targets.length}'),
          const Gap(12),
          Text('Achievements', style: Constants.textStyles.title4),
          Text('${tank.achievementIds.length}'),
          const Gap(12),
          Text('Streak', style: Constants.textStyles.title4),
          Text(tank.streak?.toString() ?? '0'),
          const Gap(12),
          Text('Image URL', style: Constants.textStyles.title4),
          Text(tank.imageUrl ?? 'No image URL'),
          const Gap(12),
          Text('Image Local Path', style: Constants.textStyles.title4),
          Text(tank.imageLocalPath ?? 'No local image path'),
        ],
      ),
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
          final itemsFlex = [2, 2, 1, 1, 1, 2];
          final filteredTanks = _filteredTanks(state.tanks);

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
                                    child: Text('Streak', style: headerStyle),
                                  ),
                                  Expanded(
                                    flex: itemsFlex[5],
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
                            return CustomListItem(
                              openedWidget: _buildTankDetails(tank),
                              itemsFlex: itemsFlex,
                              items: [
                                tank.name ?? 'Unnamed tank',
                                tank.tankType ?? 'Unknown',
                                _sizeLabel(tank),
                                '${tank.inhabitants.length}',
                                tank.streak?.toString() ?? '0',
                                tank.ownerId ?? 'No owner',
                              ],
                              secondaryItems: [
                                _dateLabel(tank.createdAt),
                                tank.id,
                                tank.tankMeasurement ?? 'No unit',
                                '${tank.targets.length} targets',
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
