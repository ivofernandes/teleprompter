import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teleprompter/src/data/capture_mode.dart';
import 'package:teleprompter/src/data/services/camera_service.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/ui/camera/recording_marker.dart';
import 'package:teleprompter/src/ui/camera/teleprompter_camera.dart';
import 'package:teleprompter/src/ui/textScroller/text_scroller_component.dart';

/// Widget that shows the teleprompter
class TeleprompterWidget extends StatefulWidget {
  const TeleprompterWidget({
    required this.text,
    this.title = 'Script name',
    this.savedToGallery = 'Video recorded saved to your gallery',
    this.errorSavingToGallery = 'Error saving video to your gallery',
    this.pictureSavedToGallery = 'Picture saved to your gallery',
    this.errorSavingPictureToGallery = 'Error saving picture to your gallery',
    this.defaultTextColor = Colors.greenAccent,
    this.startRecordingButton = const Icon(
      Icons.fiber_manual_record_sharp,
      color: Colors.red,
    ),
    this.stopRecordingButton = const Icon(Icons.stop, color: Colors.red),
    this.takePictureButton = const Icon(Icons.camera_alt),
    this.captureMode = TeleprompterCaptureMode.video,
    this.cameraOverlayBuilder,
    this.floatingButtonShape,
    this.defaultOpacity = 0.7,
    super.key,
  });

  /// Title of the teleprompter script
  final String title;

  /// Text where the tele
  final String text;

  /// Message to show when the video is saved to the gallery
  final String savedToGallery;

  /// Message to show when the video is not saved to the gallery
  final String errorSavingToGallery;

  /// Message shown after a picture is saved.
  final String pictureSavedToGallery;

  /// Message shown when a picture cannot be saved.
  final String errorSavingPictureToGallery;

  /// Color of the teleprompter text at the start
  final Color defaultTextColor;

  /// Start record button
  final Widget startRecordingButton;

  /// Stop record button
  final Widget stopRecordingButton;

  /// Camera button used when [captureMode] is [TeleprompterCaptureMode.photo].
  final Widget takePictureButton;

  /// Determines whether the camera control records video or takes pictures.
  final TeleprompterCaptureMode captureMode;

  /// Builds content above the camera preview and below the prompt text.
  ///
  /// The second argument reports whether video is currently recording. When
  /// omitted, an animated white marker is shown while recording.
  final Widget Function(
    BuildContext context,
    bool isRecording,
    TeleprompterCaptureMode captureMode,
  )?
  cameraOverlayBuilder;

  /// Shape of the floating button
  final ShapeBorder? floatingButtonShape;

  /// Default opacity of the teleprompter text
  final double defaultOpacity;

  @override
  _TeleprompterWidgetState createState() => _TeleprompterWidgetState();
}

class _TeleprompterWidgetState extends State<TeleprompterWidget> {
  double opacity = 0.7;

  @override
  void initState() {
    super.initState();

    opacity = widget.defaultOpacity;
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) =>
        TeleprompterState(context, widget.defaultTextColor, widget.captureMode),
    child: Consumer<TeleprompterState>(
      builder: (context, teleprompterState, child) {
        teleprompterState.captureMode = widget.captureMode;
        final CameraController? cameraController = CameraService()
            .getCameraController();

        // Stack with a camera behind and text above:
        return Stack(
          children: [
            cameraController != null
                ? TeleprompterCamera(cameraController)
                : const ColoredBox(color: Colors.black26),
            if (widget.cameraOverlayBuilder != null)
              widget.cameraOverlayBuilder!(
                context,
                teleprompterState.isRecording(),
                widget.captureMode,
              )
            else if (teleprompterState.isRecording())
              const RecordingMarker(),
            Opacity(
              opacity: teleprompterState.getOpacity(),
              child: TextScrollerComponent(
                title: widget.title,
                text: widget.text,
                savedToGallery: widget.savedToGallery,
                errorSavingToGallery: widget.errorSavingToGallery,
                pictureSavedToGallery: widget.pictureSavedToGallery,
                errorSavingPictureToGallery: widget.errorSavingPictureToGallery,
                stopRecordingButton: widget.stopRecordingButton,
                startRecordingButton: widget.startRecordingButton,
                takePictureButton: widget.takePictureButton,
                floatingButtonShape: widget.floatingButtonShape,
              ),
            ),
          ],
        );
      },
    ),
  );
}
