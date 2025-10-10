import 'package:flutter/material.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:disnet_manager/usecases/is_dark_mode.dart';
import 'package:toastification/toastification.dart';
import 'dart:async';

void snack(
  BuildContext context, {
  required String title,
  String? description,
  required ToastType toastType,
}) {
  Duration autoCloseDuration = Duration(seconds: 5);
  if (toastType == ToastType.error) {
    autoCloseDuration = Duration(seconds: 15);
  }

  // Add a timer to manage the countdown

  toastification.showCustom(
    dismissDirection: DismissDirection.horizontal,
    alignment: Alignment.bottomCenter,
    autoCloseDuration: autoCloseDuration,
    builder: (BuildContext context, ToastificationItem holder) {
      return CountdownToast(
        duration: autoCloseDuration - Duration(seconds: 1),
        title: title,
        description: description,
        toastType: toastType,
      );
    },
  );
}

enum ToastType {
  error(),
  info(),
  success();

  const ToastType();
}

class CountdownToast extends StatefulWidget {
  const CountdownToast({
    super.key,
    required this.duration,
    required this.title,
    required this.description,
    required this.toastType,
  });

  final Duration duration;
  final String title;
  final String? description;
  final ToastType toastType;

  @override
  State<CountdownToast> createState() => _CountdownToastState();
}

class _CountdownToastState extends State<CountdownToast> {
  Duration get duration => widget.duration;
  String get title => widget.title;
  String? get description => widget.description;
  ToastType get toastType => widget.toastType;

  late Color color;

  int countdown = 0;

  double get borderRadius => 10;

  @override
  void initState() {
    if (toastType == ToastType.error) {
      color = Constants.colors.error;
    } else if (toastType == ToastType.info) {
      color = Constants.colors.info;
    } else if (toastType == ToastType.success) {
      color = Constants.colors.success;
    } else {
      color = Colors.grey;
    }
    countdown = duration.inMilliseconds;
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      if (countdown <= 0) {
        timer.cancel();
      } else {
        setState(() {
          countdown -= 10;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          bottom: 0,
          child: LinearProgressIndicator(
            borderRadius: BorderRadius.circular(borderRadius),
            value: countdown / duration.inMilliseconds,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.transparent),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                  color: isDarkMode(context) ? Colors.black : Colors.white),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: color),
                  color: isDarkMode(context) ? Colors.black : Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Constants.textStyles.title,
                  ),
                  if (description != null)
                    Text(
                      description!,
                    )
                ],
              ),
            ),
          ),
        ),
        // Countdown border
      ],
    );
  }
}
