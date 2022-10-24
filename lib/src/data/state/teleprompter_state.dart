import 'package:flutter/material.dart';
import 'package:teleprompter/src/data/state/recorder_state.dart';
import 'package:teleprompter/src/data/state/teleprompter_settings_state.dart';
import 'package:teleprompter/src/shared/app_logger.dart';
import 'package:teleprompter/src/ui/textScroller/options/teleprompter_color_picker_component.dart';

class TeleprompterState
    with ChangeNotifier, TeleprompterSettingsState, RecorderState {
  bool _scrolling = false;
  int _optionIndex = 0;
  double _scrollPosition = 0;

  TeleprompterState(BuildContext context) {
    prepareCamera().then((value) => refresh());
    loadSettings(context).then((value) => refresh());
  }

  bool isScrolling() => _scrolling;

  void completedScroll() {
    stopScroll();
  }

  void stopScroll() {
    if (_scrolling) {
      _scrolling = false;
      refresh();
    }
  }

  void toggleStartStop() {
    _scrolling = !_scrolling;
    refresh();
  }

  void refresh() {
    notifyListeners();
    AppLogger().debug('Teleprompter state refresh()');
  }

  void increaseValueForIndex(int index) {
    setStepValueForIndex(index, getSteps()[index]!);
    refresh();
  }

  void decreaseValueForIndex(int index) {
    setStepValueForIndex(index, getSteps()[index]! * -1);
    refresh();
  }

  void hit(int index, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            TeleprompterColorPickerComponent(this));
  }

  int getOptionIndex() => _optionIndex;

  void updateOptionIndex(int index) => _optionIndex = index;

  double getScrollPosition() => _scrollPosition;

  void setScrollPosition(double offset) => _scrollPosition = offset;
}
