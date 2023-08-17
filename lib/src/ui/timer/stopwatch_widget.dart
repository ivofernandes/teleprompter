import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

/// A widget that displays a timer while recording.
class StopwatchWidget extends StatefulWidget {
  /// The style of the text.
  final TextStyle style;

  /// The padding of the text.
  final EdgeInsetsGeometry? padding;

  /// Whether to show the hours.
  final bool showHours;

  /// Whether to show the minutes.
  final bool showMinutes;

  /// Whether to show the seconds.
  final bool showSeconds;

  /// Whether to show the milliseconds.
  final bool showMilliseconds;

  const StopwatchWidget({
    super.key,
    this.padding = const EdgeInsets.all(10),
    this.style = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    this.showHours = true,
    this.showMinutes = true,
    this.showSeconds = true,
    this.showMilliseconds = false,
  });

  @override
  State<StopwatchWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.onStartTimer();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose(); // Need to call dispose function.
  }

  @override
  Widget build(BuildContext context) => Center(
        child: StreamBuilder<int>(
          stream: _stopWatchTimer.rawTime,
          initialData: 0,
          builder: (context, snap) {
            final value = snap.data!;
            final displayTime = StopWatchTimer.getDisplayTime(
              value,
              hours: widget.showHours,
              minute: widget.showMinutes,
              second: widget.showSeconds,
              milliSecond: widget.showMilliseconds,
            );
            return Container(
              padding: widget.padding,
              child: Text(
                displayTime,
                style: widget.style,
              ),
            );
          },
        ),
      );
}
