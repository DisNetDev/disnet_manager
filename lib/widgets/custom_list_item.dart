import 'package:disnet_manager/models/constants.dart';
import 'package:flutter/material.dart';

class CustomListItem extends StatefulWidget {
  const CustomListItem(
      {super.key,
      required this.items,
      this.secondaryItems = const [],
      required this.itemsFlex,
      this.openedWidget,
      this.index,
      this.trailingWidget,
      this.trailingFlex = 1});

  final List<String> items;
  final List<String> secondaryItems;
  final List<int> itemsFlex;
  final int? index;
  final Widget? openedWidget;
  final Widget? trailingWidget;
  final int trailingFlex;

  @override
  State<CustomListItem> createState() => _CustomListItemState();
}

class _CustomListItemState extends State<CustomListItem>
    with TickerProviderStateMixin {
  bool opened = false;
  bool hovering = false;

  Duration get animationDuration => const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: animationDuration,
      curve: Curves.ease,
      child: opened && widget.openedWidget != null
          ? Stack(
              children: [
                widget.openedWidget!,
                GestureDetector(
                  onTap: () => setState(() => opened = false),
                  child: Container(
                    height: 50,
                    color: Constants.colors.primary,
                  ),
                )
              ],
            )
          : InkWell(
              hoverColor: Constants.colors.primary,
              hoverDuration: animationDuration,
              onHover: (value) => setState(() => hovering = value),
              onTap: widget.openedWidget != null
                  ? () {
                      setState(
                        () {
                          opened = true;
                          hovering = false;
                        },
                      );
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: widget.index != null && widget.index!.isEven
                    ? Constants.colors.primary.withAlpha(10)
                    : Colors.transparent,
                child: Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...List.generate(
                      widget.items.length,
                      (i) {
                        final flex = (i < widget.itemsFlex.length)
                            ? widget.itemsFlex[i]
                            : 1;
                        return Expanded(
                          flex: flex,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: animationDuration -
                                    const Duration(milliseconds: 100),
                                curve: Curves.easeInOut,
                                style:
                                    Constants.textStyles.description.copyWith(
                                  color: hovering ? Colors.white : Colors.black,
                                ),
                                child: Text(
                                  widget.items[i],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (i < widget.secondaryItems.length)
                                AnimatedDefaultTextStyle(
                                  duration: animationDuration -
                                      const Duration(milliseconds: 100),
                                  curve: Curves.easeInOut,
                                  style: Constants.textStyles.data.copyWith(
                                    color:
                                        hovering ? Colors.white : Colors.black,
                                  ),
                                  child: Text(
                                    widget.secondaryItems[i],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (widget.trailingWidget != null)
                      Expanded(
                        flex: widget.trailingFlex,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: widget.trailingWidget!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
