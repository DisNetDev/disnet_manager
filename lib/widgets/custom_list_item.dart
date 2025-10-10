import 'package:disnet_manager/models/constants.dart';
import 'package:flutter/material.dart';

class CustomListItem extends StatefulWidget {
  const CustomListItem(
      {super.key,
      required this.items,
      this.secondaryItems = const [],
      required this.itemsFlex,
      this.openedWidget,
      this.index});

  final List<String> items;
  final List<String> secondaryItems;
  final List<int> itemsFlex;
  final int? index;
  final Widget? openedWidget;

  @override
  State<CustomListItem> createState() => _CustomListItemState();
}

class _CustomListItemState extends State<CustomListItem>
    with TickerProviderStateMixin {
  bool opened = false;
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 500),
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
              hoverDuration: Duration(milliseconds: 200),
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
                  children: List.generate(
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
                            Text(
                              widget.items[i],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Constants.textStyles.description.copyWith(
                                color: hovering ? Colors.white : Colors.black,
                              ),
                            ),
                            if (i < widget.secondaryItems.length)
                              Text(
                                widget.secondaryItems[i],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Constants.textStyles.data.copyWith(
                                  color: hovering ? Colors.white : Colors.black,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
