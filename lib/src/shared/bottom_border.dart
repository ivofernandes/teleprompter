import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BottomBorder extends StatelessWidget {
  const BottomBorder({super.key});

  @override
  Widget build(BuildContext context) => kIsWeb
      ? Container()
      : Container(
          height: 3,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.4),
                Theme.of(context).cardColor.withOpacity(0.4),
              ],
            ),
          ),
        );
}
