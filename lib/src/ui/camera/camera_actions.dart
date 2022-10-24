import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:teleprompter/src/shared/app_logger.dart';
import 'package:teleprompter/src/shared/my_snack_bar.dart';

mixin CameraActions {
  Future<void> resumeVideoRecording(
      CameraController? cameraController, BuildContext context) async {
    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      showCameraException(e, context);
      rethrow;
    }
  }

  void showCameraException(CameraException e, BuildContext context) {
    logError(e.code, e.description);
    MySnackBar.show(
        context: context, text: 'Error: ${e.code}\n${e.description}');
  }

  void logError(String code, String? message) {
    if (message != null) {
      AppLogger().error('Error: $code\nError Message: $message');
    } else {
      AppLogger().error('Error: $code');
    }
  }
}
