import 'package:flutter/material.dart';

/// A subtle animated white marker shown while video is being recorded.
class RecordingMarker extends StatefulWidget {
  const RecordingMarker({super.key});

  @override
  State<RecordingMarker> createState() => _RecordingMarkerState();
}

class _RecordingMarkerState extends State<RecordingMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.35,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned(
    top: 24,
    right: 24,
    child: IgnorePointer(
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)],
          ),
        ),
      ),
    ),
  );
}
