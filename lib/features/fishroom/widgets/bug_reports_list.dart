import 'package:disnet_manager/features/fishroom/cubit/fishroom_cubit.dart';
import 'package:disnet_manager/features/loader/main_loader.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:disnet_manager/widgets/custom_list_item.dart';
import 'package:disnet_manager/widgets/opened_bug_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BugReportsList extends StatefulWidget {
  const BugReportsList({super.key});

  @override
  State<BugReportsList> createState() => _BugReportsListState();
}

class _BugReportsListState extends State<BugReportsList> {
  bool loading = false;

  Future<void> _refreshBugReports() async {
    setState(() => loading = true);
    await context.read<FishroomCubit>().getBugReports();
    setState(() => loading = false);
  }

  @override
  void initState() {
    _refreshBugReports();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FishroomCubit, FishroomState>(
      builder: (context, state) {
        List<int> itemsFlex = [2, 5, 1, 2, 1, 1];
        return loading
            ? Center(child: MainLoader())
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Builder(builder: (context) {
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
                                child: Text("Description", style: headerStyle)),
                            Expanded(
                              flex: itemsFlex[2],
                              child: Text("App Version", style: headerStyle),
                            ),
                            Expanded(
                                flex: itemsFlex[3],
                                child: Text("Created At", style: headerStyle)),
                            Expanded(
                                flex: itemsFlex[4],
                                child: Text("Updated At", style: headerStyle)),
                            Expanded(
                                flex: itemsFlex[5],
                                child: Text("Status", style: headerStyle)),
                          ],
                        );
                      }),
                    ),
                    ...List.generate(state.bugReports.length, (index) {
                      final report = state.bugReports[index];
                      return CustomListItem(
                        openedWidget:
                            OpenedBugReport(bugReport: state.bugReports[index]),
                        itemsFlex: itemsFlex,
                        items: [
                          report.user.email,
                          report.description,
                          report.appVersion,
                          report.createdAt?.toString() ?? '',
                          report.updatedAt?.toString() ?? '',
                          report.isResolved ? 'Resolved' : 'Unresolved',
                        ],
                        secondaryItems: [
                          report.user.name ?? 'No Name',
                        ],
                        index: index,
                      );
                    }),
                  ]);
      },
    );
  }
}
