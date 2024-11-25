import 'package:screen_capturer/screen_capturer.dart';

class ScreenCapturerEvent {
  const ScreenCapturerEvent();
}

class CaptureScreenshot extends ScreenCapturerEvent {
  final CaptureMode mode;
  const CaptureScreenshot({required this.mode});
}

class SaveImage extends ScreenCapturerEvent {
  const SaveImage();
}

class CancelScreenshot extends ScreenCapturerEvent {
  const CancelScreenshot();
}