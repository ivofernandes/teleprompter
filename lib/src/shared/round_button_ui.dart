import 'package:flutter/material.dart';

class RoundButtonUI extends StatelessWidget {
  final Widget? child;

  const RoundButtonUI({
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Theme.of(context).cardColor.withOpacity(0.75),
                  Theme.of(context).cardColor.withOpacity(1),
                ],
                radius: 1.0,
                center: Alignment.center,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .color!
                      .withOpacity(0.4),
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
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
