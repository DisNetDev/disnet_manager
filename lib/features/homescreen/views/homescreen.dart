import 'package:disnet_manager/features/homescreen/views/dashboard.dart';
import 'package:disnet_manager/features/homescreen/widgets/sidebar.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:disnet_manager/widgets/custom_title_bar.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Widget overview = const Dashboard();

  bool get _showDesktopTitleBar {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows =>
        true,
      _ => false,
    };
  }

  void _setOverview(Widget widget) {
    setState(() => overview = widget);
  }

  void _openNavigationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.82,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withAlpha(35),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Sidebar(
                  onTileTap: (widget) {
                    _setOverview(widget);
                    Navigator.of(context).pop();
                  },
                  overview: overview,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F8),
      body: Stack(
        children: [
          const _Backdrop(),
          SafeArea(
            top: !_showDesktopTitleBar,
            bottom: false,
            child: Column(
              children: [
                if (_showDesktopTitleBar) const CustomTitleBar(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 900;

                      if (isCompact) {
                        return _CompactHomeLayout(
                          overview: overview,
                          onOpenMenu: () => _openNavigationSheet(context),
                        );
                      }

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 18 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 300,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(220),
                                    borderRadius: BorderRadius.circular(26),
                                    border: Border.all(
                                      color: const Color(0xFFD7BDD8),
                                      width: 1.2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x2E2D1530),
                                        blurRadius: 28,
                                        offset: Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: Sidebar(
                                      onTileTap: _setOverview,
                                      overview: overview,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 22),
                              Expanded(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(210),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(120),
                                      width: 1.2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1F2D1530),
                                        blurRadius: 30,
                                        offset: Offset(0, 16),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 260),
                                      switchInCurve: Curves.easeOut,
                                      switchOutCurve: Curves.easeIn,
                                      child: KeyedSubtree(
                                        key: ValueKey(overview.runtimeType),
                                        child: overview,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactHomeLayout extends StatelessWidget {
  const _CompactHomeLayout({
    required this.overview,
    required this.onOpenMenu,
  });

  final Widget overview;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDCC7DE)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onOpenMenu,
                  icon: Icon(
                    Icons.menu_rounded,
                    color: Constants.colors.primary,
                  ),
                ),
                Text(
                  'DisNet Manager',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: Constants.colors.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEDAF0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Live',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF341539),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(215),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withAlpha(160)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x262D1530),
                    blurRadius: 22,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: KeyedSubtree(
                    key: ValueKey(overview.runtimeType),
                    child: overview,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF2E6F2),
            Color(0xFFFBF6FB),
            Color(0xFFF0E2F0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: -120,
            right: -70,
            child: _GlowOrb(
              diameter: 330,
              color: Color(0x5C6B2C73),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -110,
            child: _GlowOrb(
              diameter: 360,
              color: Color(0x5C9A4DA4),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
