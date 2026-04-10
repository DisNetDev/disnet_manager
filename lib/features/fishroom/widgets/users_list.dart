import 'package:disnet_manager/features/fishroom/cubit/fishroom_cubit.dart';
import 'package:disnet_manager/features/loader/main_loader.dart';
import 'package:disnet_manager/models/app_user.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:disnet_manager/widgets/custom_list_item.dart';
import 'package:disnet_manager/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  bool loading = false;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  FishroomCubit get cubit => context.read<FishroomCubit>();

  List<AppUser> _filteredUsers(List<AppUser> users) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return users;
    }

    return users.where((user) {
      return user.id.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.name ?? '').toLowerCase().contains(query) ||
          (user.isPro ? 'active' : 'inactive').contains(query) ||
          (user.isPro ? 'subscription' : '').contains(query);
    }).toList();
  }

  Future<void> _refreshUsers() async {
    setState(() => loading = true);
    try {
      await cubit.getUsers();
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void initState() {
    _refreshUsers();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _buildUserDetails(AppUser user) {
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
          Text('User Details', style: Constants.textStyles.title4),
          const Gap(16),
          Text('ID', style: Constants.textStyles.title4),
          Text(user.id),
          const Gap(12),
          Text('Name', style: Constants.textStyles.title4),
          Text(user.name ?? 'No Name'),
          const Gap(12),
          Text('Email', style: Constants.textStyles.title4),
          Text(user.email),
          const Gap(12),
          Text('Subscription', style: Constants.textStyles.title4),
          Text(user.isPro ? 'Active' : 'Inactive'),
          const Gap(12),
          Text('Next Subscription Check', style: Constants.textStyles.title4),
          Text(user.nextProCheck?.toString() ?? 'Not scheduled'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: BlocBuilder<FishroomCubit, FishroomState>(
        builder: (context, state) {
          final itemsFlex = [2, 4, 1, 2, 2];
          final filteredUsers = _filteredUsers(state.users);

          return loading
              ? const Center(child: MainLoader())
              : state.users.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Text(
                          'No users found.',
                          style: Constants.textStyles.description,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          ' All Users',
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
                              'Search by name, email, id, or subscription',
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
                                    child: Text('Email', style: headerStyle),
                                  ),
                                  Expanded(
                                    flex: itemsFlex[2],
                                    child: Text('Subscription',
                                        style: headerStyle),
                                  ),
                                  Expanded(
                                    flex: itemsFlex[3],
                                    child:
                                        Text('Next Check', style: headerStyle),
                                  ),
                                  Expanded(
                                    flex: itemsFlex[4],
                                    child: Text('User ID', style: headerStyle),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        if (filteredUsers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'No users match your search.',
                              style: Constants.textStyles.description,
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...List.generate(filteredUsers.length, (index) {
                            final user = filteredUsers[index];
                            return CustomListItem(
                              openedWidget: _buildUserDetails(user),
                              itemsFlex: itemsFlex,
                              items: [
                                user.name ?? 'No Name',
                                user.email,
                                user.isPro ? 'Active' : 'Inactive',
                                user.nextProCheck?.toString() ??
                                    'Not scheduled',
                                user.id,
                              ],
                              secondaryItems: [
                                'Display Name',
                                'Contact Email',
                                'Subscription',
                                'Billing Check',
                                'Unique Identifier',
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
