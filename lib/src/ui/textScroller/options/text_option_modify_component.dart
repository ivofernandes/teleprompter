import 'package:flutter/material.dart';
import 'package:teleprompter/src/shared/round_button_ui.dart';
import 'package:teleprompter/src/ui/textScroller/options/text_option_navigator_icon_component.dart';

class TextOptionModifyComponent extends StatelessWidget {
  final int index;
  final num value;
  final int minValue;
  final int maxValue;
  final GestureTapCallback decrease;
  final GestureTapCallback increase;
  final GestureTapCallback? hit;

  const TextOptionModifyComponent({
    required this.index,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.decrease,
    required this.increase,
    required this.hit,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoundButtonUI(
            child: IconButton(
                onPressed: () => value > minValue ? decrease() : null,
                icon: const Icon(Icons.exposure_minus_1)),
          ),
          InkWell(
            onTap: hit,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(value.toStringAsPrecision(2)),
                  TextOptionNavigatorIconComponent(
                    index: index,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                ],
              ),
            ),
          ),
          RoundButtonUI(
            child: IconButton(
              onPressed: () => value < maxValue ? increase() : null,
              icon: const Icon(Icons.exposure_plus_1),
            ),
          )
        ],
      );
}
