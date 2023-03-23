import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/ui/textScroller/options/text_option_modify_component.dart';
import 'package:teleprompter/src/ui/textScroller/options/text_option_navigator_icon_component.dart';

class TextScrollerOptionsComponent extends StatelessWidget {
  final int index;
  final UpdateIndexCallback? updateIndex;

  const TextScrollerOptionsComponent({
    required this.index,
    required this.updateIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TeleprompterState teleprompterState =
        Provider.of<TeleprompterState>(context, listen: false);

    return SizedBox(
      height: 80,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextOptionNavigatorIconComponent(
                      index: index - 1,
                      updateIndex: updateIndex,
                    ),
                    TextOptionModifyComponent(
                      index: index,
                      value: teleprompterState.getValueForIndex(index),
                      minValue: teleprompterState.minValueForIndex(index),
                      maxValue: teleprompterState.maxValueForIndex(index),
                      decrease: () =>
                          teleprompterState.decreaseValueForIndex(index),
                      increase: () =>
                          teleprompterState.increaseValueForIndex(index),
                      hit: () => teleprompterState.hit(index, context),
                    ),
                    TextOptionNavigatorIconComponent(
                      index: index + 1,
                      updateIndex: updateIndex,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 60)
          ],
        ),
      ),
    );
  }
}
