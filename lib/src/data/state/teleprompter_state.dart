import 'package:flutter/material.dart';
import 'package:teleprompter/src/data/state/recorder_state.dart';
import 'package:teleprompter/src/data/state/teleprompter_settings_state.dart';
import 'package:teleprompter/src/shared/app_logger.dart';
import 'package:teleprompter/src/ui/textScroller/options/teleprompter_color_picker_component.dart';

/// Provider to manage the state of the teleprompter
class TeleprompterState
    with ChangeNotifier, TeleprompterSettingsState, RecorderState {
  bool _scrolling = false; // Indicates if the teleprompter is scrolling
  int _optionIndex = 0; // Currently selected option index
  double _scrollPosition = 0; // Current scroll position

  // Constructor initializes the teleprompter state
  TeleprompterState(BuildContext context, Color defaultTextColor) {
    prepareCamera().then((value) => refresh());
    loadSettings(context, defaultTextColor).then((value) => refresh());
  }

  // Returns true if the teleprompter is scrolling, false otherwise
  bool isScrolling() => _scrolling;

  // Sets scrolling to false when the teleprompter completes scrolling
  void completedScroll() {
    stopScroll();
  }

  // Stops scrolling if the teleprompter is currently scrolling
  void stopScroll() {
    if (_scrolling) {
      _scrolling = false;
      refresh();
    }
  }

  // Toggles scrolling state between start and stop
  void toggleStartStop() {
    _scrolling = !_scrolling;
    refresh();
  }

  // Notifies listeners of state changes and logs a debug message
  void refresh() {
    notifyListeners();
    AppLogger().debug('Teleprompter state refresh()');
  }

  // Increases the value for the given option index
  void increaseValueForIndex(int index) {
    setStepValueForIndex(index, getSteps()[index]!);
    refresh();
  }

  // Decreases the value for the given option index
  void decreaseValueForIndex(int index) {
    setStepValueForIndex(index, getSteps()[index]! * -1);
    refresh();
  }

  // Displays a color picker dialog when the option is clicked
  void hit(int index, BuildContext context) {
    showDialog<Widget>(
        context: context,
        builder: (
          BuildContext context,
        ) =>
            TeleprompterColorPickerComponent(this));
  }

  // Getter for the current option index
  int getOptionIndex() => _optionIndex;

  // Updates the current option index
  void updateOptionIndex(int index) => _optionIndex = index;

  // Getter for the current scroll position
  double getScrollPosition() => _scrollPosition;

  // Sets the current scroll position
  void setScrollPosition(double offset) => _scrollPosition = offset;
}
