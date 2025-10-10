import 'package:disnet_manager/models/constants.dart';
import 'package:flutter/material.dart';

class BlockButton extends StatelessWidget {
  const BlockButton(
      {super.key, this.onPressed, required this.text, this.count = 0});

  final VoidCallback? onPressed;
  final String text;
  final int count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      hoverColor: Constants.colors.primary.withAlpha(100),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Constants.colors.primary, width: 2),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: Constants.textStyles.title2
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              count.toString(),
              style: Constants.textStyles.description
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
