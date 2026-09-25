import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teleprompter/teleprompter.dart';

void main() {
  test('video remains the first and default-compatible capture mode', () {
    expect(TeleprompterCaptureMode.values, <TeleprompterCaptureMode>[
      TeleprompterCaptureMode.video,
      TeleprompterCaptureMode.photo,
    ]);
  });

  test('overlay camera defaults to composited photo capture', () {
    final widget = OverlayCameraWidget(
      overlayBuilder: (_) => const SizedBox(),
    );

    expect(widget.captureMode, TeleprompterCaptureMode.photo);
  });

  test('overlay camera refuses unprocessed video', () {
    expect(
      () => OverlayCameraWidget(
        captureMode: TeleprompterCaptureMode.video,
        overlayBuilder: (_) => const SizedBox(),
      ),
      throwsAssertionError,
    );
  });
}
