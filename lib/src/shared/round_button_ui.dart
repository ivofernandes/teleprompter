import 'package:flutter/material.dart';

class RoundButtonUI extends StatelessWidget {
  final Widget? child;

  const RoundButtonUI({
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Theme.of(context).cardColor.withOpacity(0.75),
                Theme.of(context).cardColor.withOpacity(1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: foregroundColor.withOpacity(0.4),
                spreadRadius: 1,
              )
            ],
          ),
          width: 40,
          height: 40,
        ),
        ClipOval(
          child: SizedBox(
            width: 40,
            height: 40,
            child: child,
          ),
        )
      ],
    );
  }
}
