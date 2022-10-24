import 'package:teleprompter/src/data/services/camera_service.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';

mixin RecorderState {
  bool _isRecording = false;
  bool _isCameraReady = false;

  Future<void> prepareCamera() async {
    await CameraService().startCameras();
    await CameraService().selectFrontCamera();
    _isCameraReady = true;
  }

  bool isRecording() => _isRecording;

  Future<void> startRecording(TeleprompterState teleprompterState) async {
    _isRecording = true;

    await CameraService().startRecording(teleprompterState);
  }

  Future<bool> stopRecording() async {
    _isRecording = false;

    return CameraService().stopRecording();
  }

  bool isCameraReady() => _isCameraReady;

  void disposeCamera() {
    _isCameraReady = false;
  }
}
