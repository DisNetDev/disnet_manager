import 'package:disnet_manager/features/fishroom/cubit/fishroom_cubit.dart';
import 'package:disnet_manager/models/bug_report.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:disnet_manager/usecases/snack.dart';
import 'package:disnet_manager/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class OpenedBugReport extends StatefulWidget {
  const OpenedBugReport({super.key, required this.bugReport});

  final BugReport bugReport;

  @override
  State<OpenedBugReport> createState() => _OpenedBugReportState();
}

class _OpenedBugReportState extends State<OpenedBugReport> {
  FishroomCubit get fishroomCubit => context.read<FishroomCubit>();
  bool loadingResolvedButton = false;
  bool loadingUpdateButton = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        width: 1,
        color: Constants.colors.border,
      ))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(50),
          Text(
            "Reporter:",
            style: Constants.textStyles.title4,
          ),
          Text(widget.bugReport.user.email),
          Gap(16),
          Text(
            "Description:",
            style: Constants.textStyles.title4,
          ),
          Text(widget.bugReport.description),
          Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                text: widget.bugReport.isResolved
                    ? "Mark as Unresolved "
                    : "Mark as Resolved",
                secondary: true,
                loading: loadingResolvedButton,
                callback: () async {
                  try {
                    setState(() => loadingResolvedButton = true);
                    await fishroomCubit
                        .toggleResolvedBugReport(widget.bugReport);
                    setState(() => loadingResolvedButton = false);
                  } catch (e) {
                    setState(() => loadingResolvedButton = false);

                    if (context.mounted) {
                      snack(context,
                          title: "Something went wrong",
                          toastType: ToastType.error,
                          description: e.toString());
                    }
                  }
                },
              ),
              Gap(8),
              Button(
                text: "Save",
                loading: loadingUpdateButton,
                callback: () async {
                  try {
                    setState(() => loadingUpdateButton = true);
                    fishroomCubit.updateBugReport(widget.bugReport);
                    setState(() => loadingUpdateButton = true);
                  } catch (e) {
                    setState(() => loadingUpdateButton = true);

                    if (context.mounted) {
                      snack(context,
                          title: "Something went wrong",
                          toastType: ToastType.error,
                          description: e.toString());
                    }
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
