import 'package:disnet_manager/features/fishroom/cubit/fishroom_cubit.dart';
import 'package:disnet_manager/features/loader/main_loader.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:disnet_manager/widgets/button.dart';
import 'package:disnet_manager/widgets/custom_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class FishSuggestions extends StatefulWidget {
  const FishSuggestions({super.key});

  @override
  State<FishSuggestions> createState() => _FishSuggestionsState();
}

class _FishSuggestionsState extends State<FishSuggestions> {
  bool loading = false;
  final Set<String> _acceptingSuggestionIds = <String>{};
  final Set<String> _removingSuggestionIds = <String>{};

  FishroomCubit get cubit => context.read<FishroomCubit>();

  Future<void> _refreshFishSuggestions() async {
    setState(() => loading = true);
    try {
      await cubit.getFishSuggestions();
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _acceptSuggestion(String suggestionId) async {
    final shouldAccept = await _confirmAcceptSuggestion();
    if (!shouldAccept) {
      return;
    }

    if (_acceptingSuggestionIds.contains(suggestionId)) {
      return;
    }

    setState(() => _acceptingSuggestionIds.add(suggestionId));
    try {
      await cubit.acceptFishSuggestion(suggestionId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Suggestion accepted successfully.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to accept suggestion. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _acceptingSuggestionIds.remove(suggestionId));
      }
    }
  }

  Future<void> _removeSuggestion(String suggestionId) async {
    final shouldRemove = await _confirmRemoveSuggestion();
    if (!shouldRemove) {
      return;
    }

    if (_removingSuggestionIds.contains(suggestionId)) {
      return;
    }

    setState(() => _removingSuggestionIds.add(suggestionId));
    try {
      await cubit.removeFishSuggestion(suggestionId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Suggestion removed successfully.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to remove suggestion. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _removingSuggestionIds.remove(suggestionId));
      }
    }
  }

  Future<bool> _confirmAcceptSuggestion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Accept Suggestion'),
          content: const Text(
            'This will upsert the suggested fish into your dataset. Continue?',
          ),
          actions: [
            Button(
              text: 'Cancel',
              secondary: true,
              callback: () => Navigator.of(context).pop(false),
            ),
            Button(
              text: 'Accept',
              callback: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<bool> _confirmRemoveSuggestion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Suggestion'),
          content: const Text(
            'This will permanently remove the suggestion entry. Continue?',
          ),
          actions: [
            Button(
              text: 'Cancel',
              secondary: true,
              callback: () => Navigator.of(context).pop(false),
            ),
            Button(
              text: 'Remove',
              callback: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  void initState() {
    _refreshFishSuggestions();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: BlocBuilder<FishroomCubit, FishroomState>(
        builder: (context, state) {
          List<int> itemsFlex = [1, 1, 1, 2];
          return loading
              ? Center(child: MainLoader())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      Text(
                        " Fish Suggestions",
                        style: Constants.textStyles.title,
                        textAlign: TextAlign.left,
                      ),
                      Gap(20),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Builder(
                          builder: (context) {
                            TextStyle headerStyle =
                                Constants.textStyles.description.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            );
                            return Row(
                              spacing: 20,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: itemsFlex[0],
                                    child: Text("User", style: headerStyle)),
                                Expanded(
                                    flex: itemsFlex[1],
                                    child: Text("Common Name",
                                        style: headerStyle)),
                                Expanded(
                                    flex: itemsFlex[2],
                                    child: Text("Scientific Name",
                                        style: headerStyle)),
                                Expanded(
                                    flex: itemsFlex[3],
                                    child:
                                        Text("Image URL", style: headerStyle)),
                                Expanded(
                                  flex: 2,
                                  child: Text("Actions", style: headerStyle),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      ...List.generate(state.fishSuggestions.length, (index) {
                        final suggestion = state.fishSuggestions[index];
                        final isAccepting =
                            _acceptingSuggestionIds.contains(suggestion.id);
                        final isRemoving =
                            _removingSuggestionIds.contains(suggestion.id);
                        final isBusy = isAccepting || isRemoving;

                        return CustomListItem(
                          itemsFlex: itemsFlex,
                          items: [
                            suggestion.createdBy?.email ?? "Unknown",
                            suggestion.commonName ?? "Unknown",
                            suggestion.scientificName ?? "Unknown",
                            suggestion.imageUrl ?? "Unknown",
                          ],
                          secondaryItems: [
                            "Original Fish Entry:",
                            suggestion.commonName ?? "",
                            suggestion.scientificName ?? "",
                            suggestion.imageUrl ?? "",
                          ],
                          index: index,
                          trailingFlex: 2,
                          trailingWidget: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Opacity(
                                opacity: isBusy && !isAccepting ? 0.5 : 1,
                                child: IgnorePointer(
                                  ignoring: isBusy && !isAccepting,
                                  child: Button(
                                    text: 'Accept',
                                    loading: isAccepting,
                                    callback: () =>
                                        _acceptSuggestion(suggestion.id),
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: isBusy && !isRemoving ? 0.5 : 1,
                                child: IgnorePointer(
                                  ignoring: isBusy && !isRemoving,
                                  child: Button(
                                    text: 'Remove',
                                    secondary: true,
                                    loading: isRemoving,
                                    callback: () =>
                                        _removeSuggestion(suggestion.id),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ]);
        },
      ),
    );
  }
}
