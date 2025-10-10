import 'package:disnet_manager/features/fishroom/widgets/bug_reports_list.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FishroomOverview extends StatelessWidget {
  const FishroomOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              " Bug Reports",
              style: Constants.textStyles.title,
              textAlign: TextAlign.left,
            ),
            Gap(20),
            BugReportsList()
          ],
        ),
      ),
    );
  }
}
