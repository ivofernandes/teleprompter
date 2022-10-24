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
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 3))
                ],
              ),
              width: 40,
              height: 40),
          ClipOval(
            child: Container(
              color: Theme.of(context).cardColor,
              width: 40,
              height: 40,
              child: child,
            ),
          )
        ],
      );
}
