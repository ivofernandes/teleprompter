import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teleprompter/src/data/services/camera_service.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/ui/camera/teleprompter_camera.dart';
import 'package:teleprompter/src/ui/textScroller/text_scroller_component.dart';

class TeleprompterWidget extends StatefulWidget {
  const TeleprompterWidget({
    required this.text,
    this.title = 'Script name',
    this.savedToGallery = 'Video recorded saved to your gallery',
    this.defaultTextColor = Colors.greenAccent,
    this.startRecordingButton =
        const Icon(Icons.fiber_manual_record_sharp, color: Colors.red),
    this.stopRecordingButton = const Icon(Icons.stop, color: Colors.red),
    this.floatingButtonShape,
    super.key,
  });

  /// Title of the teleprompter script
  final String title;

  /// Text where the tele
  final String text;

  /// Message to show when the video is saved to the gallery
  final String savedToGallery;

  /// Color of the teleprompter text at the start
  final Color defaultTextColor;

  /// Start record button
  final Widget startRecordingButton;

  /// Stop record button
  final Widget stopRecordingButton;

  /// Shape of the floating button
  final ShapeBorder? floatingButtonShape;

  @override
  _TeleprompterWidgetState createState() => _TeleprompterWidgetState();
}

class _TeleprompterWidgetState extends State<TeleprompterWidget> {
  double opacity = 0.7;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => TeleprompterState(
          context,
          widget.defaultTextColor,
        ),
        child: Consumer<TeleprompterState>(
          builder: (context, teleprompterState, child) {
            final CameraController? cameraController =
                CameraService().getCameraController();

            // Stack with a camera behind and text above:
            return Stack(
              children: [
                cameraController != null
                    ? TeleprompterCamera(cameraController)
                    : const ColoredBox(
                        color: Colors.black26,
                      ),
                Opacity(
                  opacity: teleprompterState.getOpacity(),
                  child: TextScrollerComponent(
                    title: widget.title,
                    text: widget.text,
                    savedToGallery: widget.savedToGallery,
                    stopRecordingButton: widget.stopRecordingButton,
                    startRecordingButton: widget.startRecordingButton,
                    floatingButtonShape: widget.floatingButtonShape,
                  ),
                )
              ],
            );
          },
        ),
      );
}
