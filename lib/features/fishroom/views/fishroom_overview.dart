import 'package:disnet_manager/features/fishroom/widgets/bug_reports_list.dart';
import 'package:flutter/material.dart';

class FishroomOverview extends StatelessWidget {
  const FishroomOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [BugReportsList()],
        ),
      ),
    );
  }
}
