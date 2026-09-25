import 'dart:io';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as path;
import 'package:teleprompter/src/data/services/cameraService/camera_dectector.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/shared/app_logger.dart';

class CameraService extends CameraDetector {
  static final CameraService _singleton = CameraService._internal();
  factory CameraService() => _singleton;
  CameraService._internal();

  /// Makes the front camera available without requiring teleprompter state.
  Future<CameraController?> prepareCamera() async {
    if (cameraController?.value.isInitialized ?? false) {
      return cameraController;
    }
    await startCameras();
    await selectFrontCamera();
    return cameraController;
  }

  /// Captures a file but does not save it. Used when media must be processed.
  Future<XFile> capturePicture() async {
    final controller = await prepareCamera();
    if (controller == null || !controller.value.isInitialized) {
      throw CameraException('cameraUnavailable', 'No camera is available.');
    }
    return controller.takePicture();
  }

  /// Stops recording and returns the unmodified temporary recording.
  Future<XFile> stopRecordingFile() async {
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      throw CameraException('notRecording', 'No video is being recorded.');
    }
    return cameraController!.stopVideoRecording();
  }

  Future<void> saveImage(String filePath) async {
    await _requestGalleryAccess();
    await Gal.putImage(filePath);
  }

  Future<void> saveVideo(String filePath) async {
    await _requestGalleryAccess();
    await Gal.putVideo(filePath);
  }

  Future<void> _requestGalleryAccess() async {
    if (!await Gal.hasAccess()) {
      await Gal.requestAccess();
    }
  }

  Future<void> startRecording(TeleprompterState teleprompterState) async {
    try {
      if (cameraController == null || !cameraController!.value.isInitialized) {
        AppLogger().debug('Error: select a camera first.');
        return;
      }

      if (cameraController!.value.isRecordingVideo) {
        // A recording is already started, do nothing.
        return;
      }

      if (!teleprompterState.isCameraReady()) {
        await teleprompterState.prepareCamera();
      }

      await cameraController!.startVideoRecording();
    } on CameraException {
      try {
        // Try to select the front camera again
        await selectFrontCamera();
        await cameraController!.startVideoRecording();
        Future.delayed(Duration.zero, () => teleprompterState.refresh());
      } on CameraException {
        rethrow;
      }
    }
  }

  Future<bool> stopRecording() async {
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      return false;
    }

    try {
      final XFile file = await cameraController!.stopVideoRecording();

      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      // Rename the file with a proper extension
      final String newPath = path.setExtension(file.path, '.mp4');
      final File newFile = await File(file.path).rename(newPath);

      // Save the video using the GAL package without MIME type
      await Gal.putVideo(newFile.path);

      // Delete the old file
      await File(newFile.path).delete();
      return true;
    } on CameraException catch (e) {
      AppLogger().error(e);
    } catch (e) {
      AppLogger().error('Unexpected error: $e');
    }

    return false;
  }

  Future<bool> takePicture(TeleprompterState teleprompterState) async {
    try {
      if (cameraController == null || !cameraController!.value.isInitialized) {
        await teleprompterState.prepareCamera();
      }

      if (cameraController == null || !cameraController!.value.isInitialized) {
        AppLogger().debug('Error: select a camera first.');
        return false;
      }

      final XFile file = await cameraController!.takePicture();
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }
      await Gal.putImage(file.path);
      await File(file.path).delete();
      return true;
    } on CameraException catch (e) {
      AppLogger().error(e);
    } catch (e) {
      AppLogger().error('Unexpected error: $e');
    }
    return false;
  }

  Future<void> pauseVideoRecording() async {
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController!.pauseVideoRecording();
    } on CameraException catch (e) {
      AppLogger().error(e);
      rethrow;
    }
  }
}
