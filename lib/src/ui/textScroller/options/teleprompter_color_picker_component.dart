import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/shared/round_button_ui.dart';

class TeleprompterColorPickerComponent extends StatelessWidget {
  final TeleprompterState teleprompterState;

  const TeleprompterColorPickerComponent(
    this.teleprompterState, {
    super.key,
  });

  void changeColor(Color color) {
    teleprompterState.setTextColor(color);
    teleprompterState.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Align(
        alignment: Alignment.centerRight,
        child: RoundButtonUI(
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.clear),
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: teleprompterState.getTextColor(),
          onColorChanged: changeColor,
          pickerAreaHeightPercent: 0.8,
        ),
      ),
    );
  }
}
