import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:teleprompter/src/data/capture_mode.dart';
import 'package:teleprompter/src/data/services/camera_service.dart';
import 'package:teleprompter/src/shared/app_logger.dart';

/// Processes a raw video and a transparent PNG containing the visible overlay.
///
/// Video compositing is deliberately supplied by the host app because the
/// appropriate native encoder depends on its supported platforms. The returned
/// file is the one saved to the gallery. [outputSize] is the oriented camera
/// frame size in pixels; the overlay PNG is rendered at that same size.
typedef VideoOverlayProcessor =
    Future<XFile> Function(XFile video, XFile overlay, Size outputSize);

/// A camera made specifically for producing photos or videos with an overlay.
///
/// Unlike the package's teleprompter screen, this screen has no script,
/// scrolling controls, or text settings. Photo overlays are rendered into the
/// saved PNG. Video overlays are passed to [videoOverlayProcessor] for encoding
/// before saving.
class OverlayCameraWidget extends StatefulWidget {
  const OverlayCameraWidget({
    required this.overlayBuilder,
    this.captureMode = TeleprompterCaptureMode.photo,
    this.videoOverlayProcessor,
    this.title = 'Overlay camera',
    this.photoSavedMessage = 'Picture with overlay saved to your gallery',
    this.videoSavedMessage = 'Video with overlay saved to your gallery',
    this.errorMessage = 'Could not save media',
    this.onSaved,
    super.key,
  }) : assert(
         captureMode != TeleprompterCaptureMode.video ||
             videoOverlayProcessor != null,
         'A videoOverlayProcessor is required so videos are never saved '
         'without their overlay.',
       );

  final WidgetBuilder overlayBuilder;
  final TeleprompterCaptureMode captureMode;
  final VideoOverlayProcessor? videoOverlayProcessor;
  final String title;
  final String photoSavedMessage;
  final String videoSavedMessage;
  final String errorMessage;
  final ValueChanged<XFile>? onSaved;

  @override
  State<OverlayCameraWidget> createState() => _OverlayCameraWidgetState();
}

class _OverlayCameraWidgetState extends State<OverlayCameraWidget> {
  final GlobalKey _overlayKey = GlobalKey();
  CameraController? _controller;
  bool _busy = false;
  bool _recording = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final controller = await CameraService().prepareCamera();
      if (mounted) setState(() => _controller = controller);
    } catch (error) {
      AppLogger().error('Unable to prepare overlay camera: $error');
      if (mounted) _show(widget.errorMessage);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          if (_recording)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(_formatElapsed(), key: const Key('recording-time')),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ColoredBox(
                color: Colors.black,
                child: controller == null || !controller.value.isInitialized
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final previewSize = controller.value.previewSize!;
                          final availableIsPortrait =
                              constraints.maxHeight > constraints.maxWidth;
                          final sensorIsPortrait =
                              previewSize.height > previewSize.width;
                          final orientedSize =
                              availableIsPortrait == sensorIsPortrait
                              ? previewSize
                              : Size(previewSize.height, previewSize.width);

                          return Center(
                            child: AspectRatio(
                              aspectRatio:
                                  orientedSize.width / orientedSize.height,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CameraPreview(controller),
                                  RepaintBoundary(
                                    key: _overlayKey,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        widget.overlayBuilder(context),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            SizedBox(
              height: 104,
              child: Center(
                child: _CaptureButton(
                  mode: widget.captureMode,
                  recording: _recording,
                  busy: _busy,
                  onPressed: _capture,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capture() async {
    if (_busy) return;
    if (widget.captureMode == TeleprompterCaptureMode.photo) {
      await _takePhoto();
    } else if (_recording) {
      await _stopVideo();
    } else {
      await _startVideo();
    }
  }

  Future<void> _takePhoto() async {
    setState(() => _busy = true);
    XFile? raw;
    XFile? output;
    try {
      raw = await CameraService().capturePicture();
      output = await _compositePhoto(raw);
      await CameraService().saveImage(output.path);
      widget.onSaved?.call(output);
      if (mounted) _show(widget.photoSavedMessage);
    } catch (error) {
      AppLogger().error('Unable to capture overlay photo: $error');
      if (mounted) _show(widget.errorMessage);
    } finally {
      await _delete(raw);
      // The gallery plugin has copied the file and clients should not rely on
      // the temporary callback path after this operation completes.
      await _delete(output);
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startVideo() async {
    setState(() => _busy = true);
    try {
      await _controller!.startVideoRecording();
      if (!mounted) {
        await CameraService().stopRecordingFile();
        return;
      }
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });
      setState(() {
        _recording = true;
        _elapsed = Duration.zero;
      });
    } catch (error) {
      AppLogger().error('Unable to start overlay video: $error');
      if (mounted) _show(widget.errorMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stopVideo() async {
    setState(() => _busy = true);
    _timer?.cancel();
    XFile? raw;
    XFile? overlay;
    XFile? output;
    try {
      raw = await CameraService().stopRecordingFile();
      final boundary =
          _overlayKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final outputSize = _orientedCameraSize(boundary.size);
      overlay = await _writeOverlayFile(
        await _captureOverlay(outputSize),
        raw.path,
      );
      output = await widget.videoOverlayProcessor!(raw, overlay, outputSize);
      await CameraService().saveVideo(output.path);
      widget.onSaved?.call(output);
      if (mounted) _show(widget.videoSavedMessage);
    } catch (error) {
      AppLogger().error('Unable to finish overlay video: $error');
      if (mounted) _show(widget.errorMessage);
    } finally {
      await _delete(raw);
      await _delete(overlay);
      if (output?.path != raw?.path && output?.path != overlay?.path) {
        await _delete(output);
      }
      if (mounted) {
        setState(() {
          _recording = false;
          _busy = false;
        });
      }
    }
  }

  Size _orientedCameraSize(Size displaySize) {
    final previewSize = _controller!.value.previewSize!;
    final displayIsPortrait = displaySize.height > displaySize.width;
    final sensorIsPortrait = previewSize.height > previewSize.width;
    return displayIsPortrait == sensorIsPortrait
        ? previewSize
        : Size(previewSize.height, previewSize.width);
  }

  Future<ui.Image> _captureOverlay(Size targetSize) async {
    final boundary =
        _overlayKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final widthRatio = targetSize.width / boundary.size.width;
    final heightRatio = targetSize.height / boundary.size.height;
    final ratio = (widthRatio + heightRatio) / 2;
    return boundary.toImage(pixelRatio: ratio);
  }

  Future<XFile> _compositePhoto(XFile photo) async {
    final bytes = await photo.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final cameraImage = (await codec.getNextFrame()).image;
    final outputSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );
    final overlay = await _captureOverlay(outputSize);
    final width = cameraImage.width;
    final height = cameraImage.height;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final destination = Rect.fromLTWH(
      0,
      0,
      width.toDouble(),
      height.toDouble(),
    );
    canvas.drawImage(cameraImage, Offset.zero, Paint());
    canvas.drawImageRect(
      overlay,
      Rect.fromLTWH(0, 0, overlay.width.toDouble(), overlay.height.toDouble()),
      destination,
      Paint(),
    );
    final result = await recorder.endRecording().toImage(width, height);
    final png = await result.toByteData(format: ui.ImageByteFormat.png);
    final file = File('${photo.path}.overlay.png');
    await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
    cameraImage.dispose();
    overlay.dispose();
    result.dispose();
    return XFile(file.path);
  }

  Future<XFile> _writeOverlayFile(ui.Image image, String beside) async {
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$beside.overlay.png');
    await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
    image.dispose();
    return XFile(file.path);
  }

  Future<void> _delete(XFile? file) async {
    if (file != null && await File(file.path).exists()) {
      await File(file.path).delete();
    }
  }

  String _formatElapsed() {
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.mode,
    required this.recording,
    required this.busy,
    required this.onPressed,
  });

  final TeleprompterCaptureMode mode;
  final bool recording;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    key: const Key('overlay-camera-capture'),
    onPressed: busy ? null : onPressed,
    iconSize: 38,
    padding: const EdgeInsets.all(18),
    style: IconButton.styleFrom(
      backgroundColor: recording ? Colors.red : Colors.white,
      foregroundColor: recording ? Colors.white : Colors.black,
    ),
    icon: busy
        ? const SizedBox.square(
            dimension: 30,
            child: CircularProgressIndicator(strokeWidth: 3),
          )
        : Icon(
            recording
                ? Icons.stop
                : mode == TeleprompterCaptureMode.photo
                ? Icons.camera_alt
                : Icons.fiber_manual_record,
          ),
  );
}
