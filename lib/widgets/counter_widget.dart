import 'package:disnet_manager/models/constants.dart';
import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  const CounterWidget(
      {super.key,
      required this.count,
      required this.title,
      this.subtitle,
      this.prefix = ""});

  final int? count;
  final String title;
  final String? subtitle;
  final String prefix;

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.count?.toDouble() ?? 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(CounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _animation = Tween<double>(
        begin: oldWidget.count?.toDouble() ?? 0,
        end: widget.count?.toDouble() ?? 0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                widget.count == null
                    ? "--"
                    : widget.prefix +
                        formatNumber(_animation.value.toInt()).toString(),
                style: Constants.textStyles.title
                    .copyWith(fontWeight: FontWeight.w700),
              );
            },
          ),
          Text(
            wrapText(widget.title, 10),
            maxLines: 2,
            textAlign: TextAlign.center,
            style: Constants.textStyles.title2.copyWith(height: 1),
          ),
          SizedBox(height: 10),
          if (widget.subtitle != null)
            Text(
              widget.subtitle!,
              textAlign: TextAlign.center,
              style: Constants.textStyles.description
                  .copyWith(fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}

String formatNumber(int number) {
  if (number >= 1000000) {
    double value = number / 1000000;
    return '${value.toStringAsFixed(2)}m';
  } else if (number >= 1000) {
    double value = number / 1000;
    return '${value.toStringAsFixed(2)}k';
  }
  return number.toString();
}

String wrapText(String text, int maxLineLength) {
  text = text.trim();
  if (text.isEmpty || maxLineLength <= 0) return text;

  List<String> words = text.split(' ');
  StringBuffer buffer = StringBuffer();
  int currentLineLength = 0;

  for (int i = 0; i < words.length; i++) {
    String word = words[i].trim();

    // If adding the word would exceed the line length, wrap to new line
    if (currentLineLength + word.length > maxLineLength) {
      if (currentLineLength > 0) {
        buffer.write('\n');
        currentLineLength = 0;
      }
    } else if (currentLineLength > 0) {
      buffer.write(' ');
      currentLineLength += 1;
    }

    buffer.write(word);
    currentLineLength += word.length;
  }

  return buffer.toString().trim();
}
