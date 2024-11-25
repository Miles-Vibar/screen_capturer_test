import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ScreenCapturerState extends Equatable  {
  const ScreenCapturerState();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class Loading extends ScreenCapturerState {
  const Loading();
}

class ScreenshotCaptured extends ScreenCapturerState {
  final Uint8List? imageBytesFromClipboard;
  const ScreenshotCaptured({required this.imageBytesFromClipboard});
}

class ScreenshotSaved extends ScreenCapturerState {
  const ScreenshotSaved();
}

class ClipboardError extends ScreenCapturerState {
  const ClipboardError();
}