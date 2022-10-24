import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/ui/camera/camera_actions.dart';

class TeleprompterCamera extends StatefulWidget {
  final CameraController controller;
  const TeleprompterCamera(this.controller, {super.key});

  @override
  _TeleprompterCameraState createState() => _TeleprompterCameraState();
}

class _TeleprompterCameraState extends State<TeleprompterCamera>
    with CameraActions, WidgetsBindingObserver, TickerProviderStateMixin {
  XFile? imageFile;
  XFile? videoFile;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  late AnimationController _exposureModeControlRowAnimationController;
  double _minAvailableZoom = 1;
  double _maxAvailableZoom = 1;
  double _currentScale = 1;
  double _baseScale = 1;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  TeleprompterState? teleprompterState;
  bool cameraDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    //initZoom();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _exposureModeControlRowAnimationController.dispose();
    cameraDisposed = true;
    super.dispose();

    if (teleprompterState != null) {
      teleprompterState?.disposeCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController cameraController = widget.controller;

    if (cameraDisposed) {
      refreshCamera();
    }

    // App state changed before we got the chance to initialize.
    if (!cameraController.value.isInitialized) {
      return;
    }

    teleprompterState = Provider.of<TeleprompterState>(context, listen: false);
    final bool recording =
        teleprompterState == null || !teleprompterState!.isRecording();
    if (state == AppLifecycleState.inactive && recording) {
      cameraDisposed = true;
      cameraController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    teleprompterState = Provider.of<TeleprompterState>(context, listen: false);

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(1),
              child: Center(
                child: _cameraPreviewWidget(),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController cameraController = widget.controller;

    if (!cameraController.value.isInitialized || cameraDisposed) {
      cameraController.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
      return Container();
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          widget.controller,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate,
                    onTapDown: (details) =>
                        onViewFinderTap(details, constraints),
                  )),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await widget.controller.setZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final CameraController cameraController = widget.controller;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> initZoom() async {
    await widget.controller
        .getMaxZoomLevel()
        .then((value) => _maxAvailableZoom = value);

    await widget.controller
        .getMinZoomLevel()
        .then((value) => _minAvailableZoom = value);
  }

  Future<void> refreshCamera() async {
    //request new camera selection to teleprompter state
    await teleprompterState!.prepareCamera();
    teleprompterState!.refresh();
  }
}
