import 'package:disnet_manager/features/homescreen/views/dashboard.dart';
import 'package:disnet_manager/features/homescreen/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:disnet_manager/widgets/custom_title_bar.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Widget overview = Dashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom title bar
          const CustomTitleBar(),
          Expanded(
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Sidebar(
                          onTileTap: (widget) {
                            setState(() => overview = widget);
                          },
                          overview: overview)),
                  Expanded(flex: 4, child: overview)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
