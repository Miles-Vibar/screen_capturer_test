import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:screen_capturer_test/bloc/screen_capturer/events.dart';
import 'package:screen_capturer_test/bloc/screen_capturer/states.dart';
import 'package:window_manager/window_manager.dart';

class ScreenCapturerBloc
    extends Bloc<ScreenCapturerEvent, ScreenCapturerState> {
  ScreenCapturerBloc() : super(const ScreenCapturerState()) {
    on<CaptureScreenshot>((event, emit) async {
      try {
        Uint8List? imageBytesFromClipboard;
        final Directory directory = await getApplicationDocumentsDirectory();
        final String imageName =
            'Screenshot-${DateTime
            .now()
            .millisecondsSinceEpoch}.png';
        final String imagePath =
            '${directory.path}/screen_capturer_test/Screenshots/$imageName';

        await windowManager.minimize();

        if (!(await windowManager.isMinimized())) return;

        await screenCapturer.capture(
          mode: event.mode,
          imagePath: imagePath,
          copyToClipboard: true,
          silent: true,
        );

        emit(const Loading());

        for (int i = 0; i <= 5; i++) {
          imageBytesFromClipboard =
          await screenCapturer.readImageFromClipboard();
          await Future.delayed(const Duration(seconds: 1));
          if (imageBytesFromClipboard != null) {
            break;
          }
        }

        emit(
          ScreenshotCaptured(
            imageBytesFromClipboard: imageBytesFromClipboard,
          ),
        );
      } catch (e) {
        emit(const ClipboardError());
      }
    });
    on<SaveImage>((event, emit) async {
      final screenshot = (state as ScreenshotCaptured).imageBytesFromClipboard!;
      emit(const Loading());
      Directory directory = await getApplicationDocumentsDirectory();
      File image = File(
          '${directory
              .path}/screen_capturer_test/Screenshots/Screenshot-${DateTime
              .now()
              .millisecondsSinceEpoch}.png');
      await image.writeAsBytes(screenshot);
      emit(const ScreenshotSaved());
    });
  }
}
