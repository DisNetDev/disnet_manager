import 'package:disnet_manager/features/fishroom/cubit/fishroom_cubit.dart';
import 'package:disnet_manager/features/loader/main_loader.dart';
import 'package:disnet_manager/models/constants.dart';
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

  FishroomCubit get cubit => context.read<FishroomCubit>();

  Future<void> _refreshBugReports() async {
    setState(() => loading = true);
    try {
      await cubit.getFishSuggestions();
    } catch (e) {
      setState(() => loading = false);
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    _refreshBugReports();

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
                              ],
                            );
                          },
                        ),
                      ),
                      ...List.generate(state.fishSuggestions.length, (index) {
                        return CustomListItem(
                          itemsFlex: itemsFlex,
                          items: [
                            state.fishSuggestions[index].createdBy?.email ??
                                "Unknown",
                            state.fishSuggestions[index].commonName ??
                                "Unknown",
                            state.fishSuggestions[index].scientificName ??
                                "Unknown",
                            state.fishSuggestions[index].imageUrl ?? "Unknown",
                          ],
                          secondaryItems: [
                            "Original Fish Entry:",
                            state.fishSuggestions[index].commonName ?? "",
                            state.fishSuggestions[index].scientificName ?? "",
                            state.fishSuggestions[index].imageUrl ?? "",
                          ],
                          index: index,
                        );
                      }),
                    ]);
        },
      ),
    );
  }
}
