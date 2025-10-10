import 'package:disnet_manager/features/loader/main_loader.dart';
import 'package:disnet_manager/models/constants.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.text,
    required this.callback,
    this.color,
    this.secondary = false,
    this.loading = false,
  });

  final String text;
  final Color? color;
  final VoidCallback callback;
  final bool secondary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            border: Border.all(color: Constants.colors.primary, width: 2),
            color: !secondary ? color ?? Constants.colors.primary : null,
            borderRadius: BorderRadius.circular(8)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              text,
              style: Constants.textStyles.description.copyWith(
                  color: secondary
                      ? loading
                          ? Colors.white
                          : Constants.colors.primary
                      : loading
                          ? Constants.colors.primary
                          : Colors.white,
                  fontWeight: FontWeight.w700),
            ),
            if (loading)
              SizedBox(
                  height: 20,
                  child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          secondary ? Constants.colors.primary : Colors.white,
                          BlendMode.srcIn),
                      child: MainLoader()))
          ],
        ),
      ),
    );
  }
}
