import 'package:disnet_manager/enums/app.dart';
import 'package:disnet_manager/features/fishroom/widgets/bug_reports_list.dart';
import 'package:disnet_manager/features/fishroom/widgets/fish_suggestions.dart';
import 'package:disnet_manager/features/fishroom/widgets/tanks_list.dart';
import 'package:disnet_manager/features/fishroom/widgets/users_list.dart';
import 'package:disnet_manager/features/homescreen/cubit/dashboard_cubit.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:disnet_manager/widgets/action_button.dart';
import 'package:disnet_manager/widgets/counter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FishroomOverview extends StatefulWidget {
  const FishroomOverview({super.key});

  @override
  State<FishroomOverview> createState() => _FishroomOverviewState();
}

class _FishroomOverviewState extends State<FishroomOverview> {
  void _openBugReports() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text('Bug Reports', style: Constants.textStyles.title4),
          ),
          body: const Padding(
            padding: EdgeInsets.all(20),
            child: BugReportsList(),
          ),
        ),
      ),
    );
  }

  void _openFishSuggestions() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text('Fish Suggestions', style: Constants.textStyles.title4),
          ),
          body: const Padding(
            padding: EdgeInsets.all(20),
            child: FishSuggestions(),
          ),
        ),
      ),
    );
  }

  void _openUsers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text('All Users', style: Constants.textStyles.title4),
          ),
          body: const Padding(
            padding: EdgeInsets.all(20),
            child: UsersList(),
          ),
        ),
      ),
    );
  }

  void _openTanks() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text('All Tanks', style: Constants.textStyles.title4),
          ),
          body: const Padding(
            padding: EdgeInsets.all(20),
            child: TanksList(),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().getUsers(app: App.fishroom);
    context.read<DashboardCubit>().getSubscriptions(app: App.fishroom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Fishroom",
          style: Constants.textStyles.title,
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    CounterWidget(
                        count: state.userCount,
                        title: "Users",
                        subtitle: "on Fishroom"),
                    CounterWidget(
                        count: state.subscriptionCount,
                        title: "Subscriptions",
                        subtitle: "Active"),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 700;

                if (isNarrow) {
                  return Column(
                    children: [
                      ActionButton(
                        onPressed: _openBugReports,
                        icon: Icons.bug_report,
                        label: 'Bug Reports',
                        subtitle: 'Review and manage reported issues',
                      ),
                      const SizedBox(height: 12),
                      ActionButton(
                        onPressed: _openFishSuggestions,
                        icon: Icons.lightbulb_outline,
                        label: 'Fish Suggestions',
                        subtitle: 'Inspect suggestions from the community',
                      ),
                      const SizedBox(height: 12),
                      ActionButton(
                        onPressed: _openUsers,
                        icon: Icons.people_outline,
                        label: 'All Users',
                        subtitle: 'Review each Fishroom account and details',
                      ),
                      const SizedBox(height: 12),
                      ActionButton(
                        onPressed: _openTanks,
                        icon: Icons.water_outlined,
                        label: 'All Tanks',
                        subtitle: 'Inspect tank metadata and ownership',
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        onPressed: _openBugReports,
                        icon: Icons.bug_report,
                        label: 'Bug Reports',
                        subtitle: 'Review and manage reported issues',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionButton(
                        onPressed: _openFishSuggestions,
                        icon: Icons.lightbulb_outline,
                        label: 'Fish Suggestions',
                        subtitle: 'Inspect suggestions from the community',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionButton(
                        onPressed: _openUsers,
                        icon: Icons.people_outline,
                        label: 'All Users',
                        subtitle: 'Review each Fishroom account and details',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionButton(
                        onPressed: _openTanks,
                        icon: Icons.water_outlined,
                        label: 'All Tanks',
                        subtitle: 'Inspect tank metadata and ownership',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
