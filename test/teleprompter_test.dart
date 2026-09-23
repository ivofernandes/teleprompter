import 'package:flutter_test/flutter_test.dart';
import 'package:teleprompter/teleprompter.dart';

void main() {
  test('video remains the first and default-compatible capture mode', () {
    expect(TeleprompterCaptureMode.values, <TeleprompterCaptureMode>[
      TeleprompterCaptureMode.video,
      TeleprompterCaptureMode.photo,
    ]);
  });
}
