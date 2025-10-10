import 'package:disnet_manager/enums/app.dart';
import 'package:disnet_manager/features/homescreen/cubit/dashboard_cubit.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:disnet_manager/widgets/counter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, this.app});

  final App? app;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().getUsers(app: widget.app);
    context.read<DashboardCubit>().getSubscriptions(app: widget.app);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
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
                        subtitle: "across all apps"),
                    CounterWidget(
                        count: state.subscriptionCount,
                        title: "Subscriptions",
                        subtitle: "Active"),
                    // CounterWidget(
                    //     count: state.projectedRevenue?.toInt(),
                    //     prefix: "\$",
                    //     title: "Projected",
                    //     subtitle: "Monthly Revenue"),
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
