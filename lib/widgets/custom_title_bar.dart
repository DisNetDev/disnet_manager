import 'package:disnet_manager/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) async {
        await windowManager.startDragging();
      },
      child: Container(
        height: 35,
        color: Constants.colors.primary,
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Text(
              'DisNet Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // Minimize button
            IconButton(
              icon: const Icon(Icons.minimize, color: Colors.white, size: 20),
              tooltip: 'Minimize',
              onPressed: () async {
                await windowManager.minimize();
              },
            ),
            // Maximize/Restore button
            IconButton(
              icon:
                  const Icon(Icons.crop_square, color: Colors.white, size: 18),
              tooltip: 'Maximize/Restore',
              onPressed: () async {
                bool isMaximized = await windowManager.isMaximized();
                if (isMaximized) {
                  await windowManager.restore();
                } else {
                  await windowManager.maximize();
                }
              },
            ),
            // Close button
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              tooltip: 'Close',
              onPressed: () async {
                await windowManager.close();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
