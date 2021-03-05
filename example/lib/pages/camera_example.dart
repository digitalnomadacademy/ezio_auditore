import 'package:flutter/material.dart';
import 'package:flutter_video_editor/exceptions.dart';
import 'package:flutter_video_editor/widgets/video_recorder.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class CameraExample extends StatefulWidget {
  @override
  _CameraExampleState createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample>
    with WidgetsBindingObserver {
  VideoRecorderController controller;
  String videoPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      print("Controller State: ${controller != null}");
      if (controller != null) {
        setState(() {});
      }
    }
  }

  Future<void> _initCamera() async {
    //If controller is disposed in case of inactivity, controller would have to be initialized again
    if (controller == null || controller.isDisposed) {
      final cameraDescription = await VideoRecorderInitializer.initialize();

      controller =
          VideoRecorderController(cameraDescription: cameraDescription);
    }

    if (controller != null && controller.value.isInitialized) {
      return controller;
    }

    return controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              child: Center(
                child: FutureBuilder(
                  future: _initCamera(),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done)
                      return VideoRecorder(
                        controller: controller,
                      );

                    return Text(
                      'Loading camera',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.switch_camera,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      try {
                        controller = await controller.switchCamera();
                      } on NoCameraFoundException catch (e) {}
                      setState(() {});
                    },
                  ),
                  if (!(controller?.isRecordingVideo ?? false) &&
                      !(controller?.isRecordingPaused ?? false))
                    IconButton(
                      icon: Icon(
                        Icons.fiber_manual_record,
                        color: Colors.redAccent,
                      ),
                      onPressed: () async {
                        await onRecordVideoPressed();
                      },
                    ),
                  if ((controller?.isRecordingVideo ?? false) &&
                      !(controller?.isRecordingPaused ?? false))
                    IconButton(
                      icon: Icon(
                        Icons.pause_circle_outline,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        onPauseVideoPressed();
                      },
                    ),
                  if ((controller?.isRecordingVideo ?? false) &&
                      (controller?.isRecordingPaused ?? false))
                    IconButton(
                      icon: Icon(
                        Icons.pause_circle_filled,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        onResumeVideoPressed();
                      },
                    ),
                  if (controller?.isRecordingVideo ?? false)
                    IconButton(
                      icon: Icon(
                        Icons.stop,
                        color: Colors.redAccent,
                      ),
                      onPressed: () async {
                        await onStopRecordingPressed();
                        await GallerySaver.saveVideo(videoPath,
                                albumName: "FlutterVideoRecorder")
                            .then((value) => print("Video saved: $value"));

                        print("Video saved");

                        setState(() {});
                      },
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String> onRecordVideoPressed() async {
    if (controller.isRecordingVideo) {
      return null;
    }

    //Provide a path to record video
    var tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${DateTime.now().toString()}.mp4';

    try {
      videoPath = filePath;
      await controller.startVideoRecording();
      print("Recording started");
      setState(() {});
    } catch (e) {
      print("Error recording video: ${e.toString()}");
    }

    return filePath;
  }

  void onPauseVideoPressed() async {
    await controller.pauseVideoRecording();
    print("Recording paused");
    setState(() {});
  }

  void onResumeVideoPressed() async {
    await controller.resumeVideoRecording();
    print("Recording resumed");
    setState(() {});
  }

  Future<void> onStopRecordingPressed() async {
    return controller.stopVideoRecording();
  }
}
