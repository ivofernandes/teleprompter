import 'package:flutter/material.dart';

/// A widget that draws a bottom border.
class BottomBorder extends StatelessWidget {
  const BottomBorder({super.key});

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    return Container(
      height: 3,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            foregroundColor.withOpacity(0.4),
            Theme.of(context).cardColor.withOpacity(0.4),
          ],
        ),
      ),
    );
  }
}
