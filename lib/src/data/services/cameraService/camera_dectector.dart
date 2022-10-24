import 'package:camera/camera.dart';
import 'package:teleprompter/src/shared/app_logger.dart';

List<CameraDescription> cameras = [];

class CameraDetector {
  bool _cameraReady = false;
  CameraController? cameraController;

  Future<void> startCameras() async {
    cameras = await availableCameras();
  }

  bool isCameraReady() => _cameraReady;

  CameraController? getCameraController() => cameraController;

  Future<void> selectFrontCamera() async {
    for (final CameraDescription cameraDescription in cameras) {
      if (cameraDescription.lensDirection == CameraLensDirection.front) {
        await onNewCameraSelected(cameraDescription);
        _cameraReady = true;
      }
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // If the controller is updated then update the UI.
    cameraController!.addListener(() {
      AppLogger().debug('camera event: ${cameraController!.value}');
      if (cameraController!.value.hasError) {
        AppLogger()
            .debug('Camera error ${cameraController!.value.errorDescription}');
      }
    });

    try {
      await cameraController!.initialize();
    } on CameraException {
      rethrow;
    }
  }
}
