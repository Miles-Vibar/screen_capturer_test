import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:screen_capturer_test/bloc/screen_capturer/bloc.dart';
import 'package:screen_capturer_test/bloc/screen_capturer/events.dart';
import 'package:screen_capturer_test/bloc/screen_capturer/states.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Screen Capture'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScreenCapturerBloc(),
      child: BlocConsumer<ScreenCapturerBloc, ScreenCapturerState>(
        listener: (context, Object? state) async {
          if (state is ClipboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Clipboard Error! Please try again!'),
              ),
            );
          }
          if (state is ScreenshotSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Screenshot Saved!'),
              ),
            );
          }
          if (state is ScreenshotCaptured) {
            await windowManager.restore();
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(widget.title),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (state is ScreenshotCaptured)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: (state.imageBytesFromClipboard == null)
                          ? const Text('Screenshot broken')
                          : Image.memory(state.imageBytesFromClipboard!),
                    ),
                  if (state is Loading)
                    const SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: (state is Loading)
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          context.read<ScreenCapturerBloc>().add(
                                const CaptureScreenshot(
                                  mode: CaptureMode.region,
                                ),
                              );
                        },
                  backgroundColor: (state is Loading)
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.5)
                      : null,
                  foregroundColor: (state is Loading)
                      ? Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.5)
                      : null,
                  disabledElevation: 0,
                  tooltip: 'Capture',
                  label: const Text('Capture'),
                ),
                const SizedBox(
                  width: 16,
                ),
                if (state is ScreenshotCaptured)
                  if (state.imageBytesFromClipboard != null)
                    FloatingActionButton.extended(
                      onPressed: () => context
                          .read<ScreenCapturerBloc>()
                          .add(const SaveImage()),
                      tooltip: 'Save Image',
                      label: const Text('Save Image'),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
