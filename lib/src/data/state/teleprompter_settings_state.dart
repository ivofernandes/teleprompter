import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teleprompter/src/shared/app_logger.dart';

mixin TeleprompterSettingsState {
  static const int indexOpacity = 0;
  static const int indexSpeed = 1;
  static const int indexTextSize = 2;

  static const String settingsOpacity = 'SETTINGS_OPACITY';
  static const String settingsSpeed = 'SETTINGS_SPEED';
  static const String settingsTextSize = 'SETTINGS_TEXT_SIZE';
  static const String settingsTextColor = 'SETTINGS_TEXT_COLOR';

  static const Map<int, num> step = {
    indexOpacity: 0.05,
    indexSpeed: 1,
    indexTextSize: 1,
  };

  static const Map<int, num> minValue = {
    indexOpacity: 0,
    indexSpeed: 1,
    indexTextSize: 1,
  };

  static const Map<int, num> maxValue = {
    indexOpacity: 1,
    indexSpeed: 100,
    indexTextSize: 80,
  };

  double _opacity = 0.7;
  int _speedFactor = 5;
  double _textSize = 14;
  Color _textColor = Colors.greenAccent;

  Future<void> loadSettings(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Speed
    final int? prefSpeed = prefs.getInt(settingsSpeed);
    if (prefSpeed != null) {
      _speedFactor = prefSpeed;
    }

    // Opacity
    final double? prefOpacity = prefs.getDouble(settingsOpacity);
    if (prefOpacity != null) {
      _opacity = prefOpacity;
    }

    // Text size
    final double? prefTextSize = prefs.getDouble(settingsTextSize);
    if (prefTextSize != null) {
      _textSize = prefTextSize;
    }

    // Text color
    final int? prefTextColor = prefs.getInt(settingsTextColor);
    if (prefTextColor != null) {
      _textColor = Color(prefTextColor);
    }
  }

  double getOpacity() => min(1, max(0, _opacity));

  int getSpeedFactor() => _speedFactor;

  double getTextSize() => _textSize;

  Color getTextColor() => _textColor;

  Future<void> setTextColor(Color color) async {
    _textColor = color;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(settingsTextColor, color.value);
  }

  num getValueForIndex(int index) {
    switch (index) {
      case indexOpacity:
        return _opacity;
      case indexSpeed:
        return _speedFactor;
      case indexTextSize:
        return _textSize;
      default:
        return -1;
    }
  }

  int minValueForIndex(int index) => minValue[index]!.toInt();

  int maxValueForIndex(int index) => maxValue[index]!.toInt();

  Future<void> setStepValueForIndex(int index, num step) async {
    switch (index) {
      case indexOpacity:
        _opacity += step.toDouble();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(settingsOpacity, _opacity);
        break;
      case indexSpeed:
        _speedFactor += step.toInt();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt(settingsSpeed, _speedFactor);
        break;
      case indexTextSize:
        _textSize += step.toDouble();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(settingsTextSize, _textSize);
        break;
      default:
        AppLogger().debug('unable to set index $index');
    }
  }

  Map<int, num> getSteps() => step;
}
