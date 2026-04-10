import 'package:disnet_manager/features/app/widgets/logo.dart';
import 'package:disnet_manager/features/debug/debug_screen.dart';
import 'package:disnet_manager/features/fishroom/views/fishroom_overview.dart';
import 'package:disnet_manager/features/homescreen/views/dashboard.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key, required this.onTileTap, required this.overview});

  final Function(Widget) onTileTap;
  final Widget overview;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Constants.colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: _Header(),
          ),
          _Tile(
            title: "Dashboard",
            subtitle: "Home",
            icon: Icons.home,
            onTap: () {
              widget.onTileTap(Dashboard());
            },
            isSelected: widget.overview is Dashboard,
          ),
          _Tile(
            title: "Fishroom",
            subtitle: "Home",
            onTap: () {
              widget.onTileTap(FishroomOverview());
            },
            isSelected: widget.overview is FishroomOverview,
          ),
          Expanded(child: SizedBox()),
          kDebugMode
              ? _Tile(
                  title: "Debug",
                  subtitle: "Debug",
                  icon: Icons.bug_report,
                  isSelected: widget.overview is DebugScreen,
                  onTap: () {
                    widget.onTileTap(DebugScreen());
                  },
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

class _Tile extends StatefulWidget {
  const _Tile({
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.isSelected = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final void Function()? onTap;
  final bool isSelected;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Constants.colors.primary.withAlpha(200),
      onHover: (value) {
        setState(() => isHovered = value);
      },
      onTap: widget.onTap,
      child: AnimatedContainer(
          padding: EdgeInsets.symmetric(vertical: 10),
          duration: Duration(milliseconds: 100),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Constants.colors.border, width: 0.5),
            ),
            color: isHovered || widget.isSelected
                ? Constants.colors.primary
                : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.icon != null)
                Expanded(
                  child: widget.icon != null
                      ? Icon(
                          widget.icon!,
                          color: widget.isSelected || isHovered
                              ? Colors.white
                              : Constants.colors.primary,
                        )
                      : SizedBox(),
                )
              else
                Gap(10),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Constants.textStyles.title4.copyWith(
                        color: widget.isSelected || isHovered
                            ? Colors.white
                            : Constants.colors.primary,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: Constants.textStyles.description.copyWith(
                          color: widget.isSelected || isHovered
                              ? Colors.white
                              : Constants.colors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Constants.colors.border),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Logo());
  }
}
