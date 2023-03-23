import 'package:flutter/material.dart';
import 'package:teleprompter/src/shared/round_button_ui.dart';
import 'package:teleprompter/src/ui/textScroller/options/text_option_navigator_icon_component.dart';

/// This widget imports the necessary packages and defines the
/// TextOptionModifyComponent class, which is a StatelessWidget that
/// displays a row of UI elements to modify a specific text option.
class TextOptionModifyComponent extends StatelessWidget {
  // The index of the option.
  final int index;

  // The current value of the option.
  final num value;

  // The minimum allowed value for the option.
  final int minValue;

  // The maximum allowed value for the option.
  final int maxValue;

  // Callback function to decrease the option's value.
  final GestureTapCallback decrease;

  // Callback function to increase the option's value.
  final GestureTapCallback increase;

  // Optional callback function to handle additional onTap on the middle icon
  final GestureTapCallback? hit;

  // Constructor for the TextOptionModifyComponent.
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

  // This method builds the UI elements and returns a Row widget.
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // A button to decrease the option's value.
          RoundButtonUI(
            child: IconButton(
                onPressed: () => value > minValue ? decrease() : null,
                icon: const Icon(Icons.exposure_minus_1)),
          ),
          // Displays the current option value and the option's icon.
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
          // A button to increase the option's value.
          RoundButtonUI(
            child: IconButton(
              onPressed: () => value < maxValue ? increase() : null,
              icon: const Icon(Icons.exposure_plus_1),
            ),
          )
        ],
      );
}
