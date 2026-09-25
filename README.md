# teleprompter
Flutter package to create a teleprompter from a simple text
Features:
- Play the text generated in your app with an automatic scroll
- Record video directly inside the app
- Take pictures instead of video with a configurable capture mode
- Place a custom (including animated) widget over the camera preview
- Automatic save to gallery on stop recording

Demo using the example of the package:
![Teleprompter demo](https://github.com/ivofernandes/teleprompter/raw/main/doc/example.gif?raw=true)

## Why I did this package
I developed this rhyming dictionary, but at some point the complexity of this teleprompter feature started to be too much, is about a thousand lines of code, and because of that I created a package to have an example app and an easier use case to test.
Then after being decoupled decided to publish as content creation is probably an important part of many apps.

If you can test by just installing this app, that in the editor mode has a teleprompter feature:

https://play.google.com/store/apps/details?id=com.rhymit.rhymit_application

https://apps.apple.com/pt/app/rhymit/id1251123570

## Getting started

Add the dependency to your `pubspec.yaml`:

```
teleprompter: ^0.0.10
```

Or run the following command in the terminal in the root of your project: 
```
flutter pub add teleprompter
```

## Usage


```dart
import 'package:flutter/material.dart';
import 'package:teleprompter/teleprompter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String text =
    '''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum sollicitudin elit id ex pellentesque, vitae blandit neque pulvinar. Aenean maximus ante nisi, ac lobortis erat euismod vitae. Etiam porttitor malesuada turpis, non lacinia diam tristique non. Nam pulvinar neque massa, sit amet gravida elit fringilla sit amet. Cras quis tristique diam. Cras commodo lacus at lorem fermentum, at aliquam eros facilisis. Morbi fringilla laoreet commodo. Sed placerat magna id arcu hendrerit, ac porttitor sapien porttitor. Phasellus mauris elit, condimentum ac iaculis ut, iaculis a urna. Morbi posuere sit amet diam ut auctor. Morbi sodales odio eleifend mauris venenatis ultricies. Aenean efficitur libero nec nulla fringilla, sit amet dignissim velit consectetur. Suspendisse consectetur porta arcu, sagittis dictum quam.

Nullam convallis tortor nisl, eget laoreet orci cursus at. Curabitur at luctus libero. Nunc nec orci et turpis tincidunt pretium. Curabitur nec dolor facilisis, molestie quam vitae, hendrerit elit. In a viverra ex. In hac habitasse platea dictumst. Curabitur luctus sapien sit amet pharetra varius. Fusce placerat lacus vel purus hendrerit, vel consectetur erat ornare. In eu nisi nunc.

Etiam ac euismod tortor, sit amet volutpat erat. Vestibulum non laoreet mauris. Quisque quis nibh at est semper gravida vel sit amet diam. Nullam convallis diam sed elit facilisis fringilla. Nunc in tincidunt tellus. Donec eleifend odio ligula, ut luctus arcu auctor eleifend. Sed lacinia et urna bibendum faucibus. Aenean varius tortor et tristique sollicitudin. Mauris eu volutpat nibh, sit amet maximus mauris. Duis ipsum dolor, malesuada maximus efficitur ut, cursus at justo. Maecenas sit amet iaculis orci.

Nunc commodo mauris a egestas ullamcorper. Nullam finibus rhoncus congue. Suspendisse in pellentesque erat. Nunc fermentum purus in lorem eleifend, et consequat diam ultrices. Nam ac mauris purus. Aliquam augue diam, mattis eget est sed, vulputate dictum nisl. Morbi vitae sapien ut justo consequat euismod et vehicula ante. Duis consectetur eros ac augue efficitur, ut suscipit lorem aliquet. Phasellus condimentum, augue in posuere luctus, mi erat ullamcorper ante, non ullamcorper arcu ligula eget libero. Suspendisse faucibus condimentum ex sed fermentum. Ut non ante iaculis, hendrerit tellus non, imperdiet sapien. Maecenas vestibulum ligula velit, sed venenatis nunc varius eu. Nam a elit sed dolor convallis rutrum at non dui. Etiam ultricies libero eros, ac porttitor odio mattis vel. Mauris posuere imperdiet lacus, vel dictum leo.

Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Etiam luctus pretium pellentesque. In nec tellus gravida ante maximus congue tempus non orci. Vivamus vel molestie sem. Nulla odio purus, condimentum et leo sagittis, semper tristique elit. Ut dui nisi, condimentum nec leo suscipit, fringilla sodales arcu. Nulla at suscipit augue, et feugiat diam. Nulla rhoncus augue a neque interdum venenatis. Praesent pellentesque lacus facilisis, bibendum metus at, dignissim sapien. Sed malesuada neque nulla, non egestas libero vulputate eu. Mauris a varius orci. Nullam euismod elit eu facilisis aliquam. Ut lectus mi, tincidunt at elit a, finibus feugiat ipsum. Integer vitae venenatis nisl. Mauris ac tristique ligula.''';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const TeleprompterWidget(
        text: text,
      ),
    );
  }
}
```

### Pictures, videos, and camera overlays

`captureMode` controls the camera action shown by `TeleprompterWidget`:

- `TeleprompterCaptureMode.video` records video and is the default.
- `TeleprompterCaptureMode.photo` takes a single picture.

Use `cameraOverlayBuilder` to place any Flutter widget above the camera preview.
The builder receives:

1. The current `BuildContext`.
2. `isRecording`, which changes when video recording starts or stops.
3. The active `TeleprompterCaptureMode`.

For example, this reusable overlay combines a status pill, safe-area padding,
and a branded information card instead of displaying only a text label:

```dart
class CameraBrandOverlay extends StatelessWidget {
  const CameraBrandOverlay({
    required this.isRecording,
    required this.captureMode,
    super.key,
  });

  final bool isRecording;
  final TeleprompterCaptureMode captureMode;

  @override
  Widget build(BuildContext context) {
    final isPhoto = captureMode == TeleprompterCaptureMode.photo;

    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          minimum: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isRecording ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    isPhoto
                        ? 'PHOTO'
                        : isRecording
                            ? 'RECORDING'
                            : 'READY',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    left: BorderSide(color: Colors.orangeAccent, width: 5),
                  ),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(child: Icon(Icons.movie_filter)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Behind the scenes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Made with Teleprompter',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Add an overlay in picture mode

Set `captureMode` to `photo` and return the overlay from the builder. The camera
control will take and save a picture instead of starting a recording:

```dart
TeleprompterWidget(
  text: 'Look at the camera and introduce today\'s topic.',
  captureMode: TeleprompterCaptureMode.photo,
  cameraOverlayBuilder: (context, isRecording, captureMode) {
    return CameraBrandOverlay(
      isRecording: isRecording,
      captureMode: captureMode,
    );
  },
);
```

#### Add an overlay in video mode

The same API works for video. Use `isRecording` to update the overlay while the
recording is active:

```dart
TeleprompterWidget(
  text: 'This script scrolls while the video is being recorded.',
  captureMode: TeleprompterCaptureMode.video,
  cameraOverlayBuilder: (context, isRecording, captureMode) {
    return CameraBrandOverlay(
      isRecording: isRecording,
      captureMode: captureMode,
    );
  },
);
```

If `cameraOverlayBuilder` is omitted in video mode, the package displays its
default animated recording marker. `RecordingMarker` is exported if you want to
include that marker inside your own composition.

`cameraOverlayBuilder` remains useful when an overlay only needs to appear in
the teleprompter preview. To create exported media that contains the overlay,
use the dedicated `OverlayCameraWidget` instead. It intentionally contains no
script scroller or text controls:

```dart
OverlayCameraWidget(
  captureMode: TeleprompterCaptureMode.photo,
  overlayBuilder: (context) => const CameraBrandOverlay(
    isRecording: false,
    captureMode: TeleprompterCaptureMode.photo,
  ),
);
```

In photo mode the package preserves the camera image's original pixel size and
aspect ratio. The overlay is rendered at that same frame size and composited
into the PNG before it is copied to the gallery, so the saved picture matches
the preview rather than merely displaying a Flutter widget above it.

Video encoding differs between platforms, so video mode requires a
`videoOverlayProcessor`. The callback receives the raw recording, a transparent
PNG of the overlay, and the preview size. It must return a video with that PNG
composited over every frame; only its returned file is saved. Requiring the
processor prevents an apparently successful capture from silently saving a
video without its overlay.

The example app includes a complete customization screen with a live preview,
editable content, layouts, colors, and navigation into the dedicated overlay
camera. See
[`example/lib/picture_overlay_screen.dart`](example/lib/picture_overlay_screen.dart).


### iOS

\* The camera plugin compiles for any version of iOS, but its functionality
requires iOS 10 or higher. If compiling for iOS 9, make sure to programmatically
check the version of iOS running on the device before using any camera plugin features.
The [device_info_plus](https://pub.dev/packages/device_info_plus) plugin, for example, can be used to check the iOS version.

Add two rows to the `ios/Runner/Info.plist`:

* one with the key `Privacy - Camera Usage Description` and a usage description.
* and one with the key `Privacy - Microphone Usage Description` and a usage description.
* add one for the videos/photos library

If editing `Info.plist` as text, that probably is quite easier, just add:

```xml
<key>NSCameraUsageDescription</key>
<key>NSCameraUsageDescription</key>
<string>Need camera to record to video image</string>
<key>NSMicrophoneUsageDescription</key>
<string>Need microphone to record to video audio</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Need access to library to save the video</string>
```

### Android

Update the min sdk version to work on android
Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

```groovy
minSdkVersion 21
```

If you are not sure where to find that file 'minSdkVersion' on android studio and update the build.gradle to support only from version 21


## More info

This package also exposes a widget that can be used to display a stopwatch. That can be included anywhere in your project just by adding StopwatchWidget():
```dart
StopwatchWidget()
```

## Contributing
If you want to contribute to this project, you are more than welcome to do so.
You can create an issue, or even better, create a pull request.
https://github.com/ivofernandes/teleprompter

## Like us on pub.dev
Package url:
https://pub.dev/packages/teleprompter
