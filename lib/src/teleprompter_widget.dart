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
    super.key,
  });

  /// Title of the teleprompter script
  final String title;

  /// Text where the tele
  final String text;

  /// Message to show when the video is saved to the gallery
  final String savedToGallery;

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
        create: (_) => TeleprompterState(context),
        child: Consumer<TeleprompterState>(
          builder: (context, teleprompterState, child) {
            final CameraController? cameraController =
                CameraService().getCameraController();

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
                  ),
                )
              ],
            );
          },
        ),
      );
}
