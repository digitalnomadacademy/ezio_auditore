import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Returns a camera preview widget which takes a VideoRecorderController as a required param
class VideoRecorder extends StatelessWidget {
  final VideoRecorderController controller;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller));
  }

  const VideoRecorder({@required this.controller, this.width, this.height})
      : assert(controller != null);
}

/// Helper class to get camera descriptions
class VideoRecorderInitializer {
  static Future<CameraDescription> initialize() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    return camera;
  }
}

/// Controller to use for VideoRecorder
class VideoRecorderController extends CameraController {
  VideoRecorderController({CameraDescription cameraDescription})
      : super(cameraDescription, ResolutionPreset.medium);

  @override
  Future<void> initialize() {
    return super.initialize();
  }
}
