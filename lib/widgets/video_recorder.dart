import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_editor/constants/camera_type.dart';
import 'package:flutter_video_editor/exceptions.dart';

/// Returns a camera preview widget which takes a VideoRecorderController as a required param
class VideoRecorder extends StatelessWidget {
  final VideoRecorderController controller;
  final double width;
  final double height;

  const VideoRecorder({@required this.controller, this.width, this.height})
      : assert(controller != null);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller));
  }
}

/// Helper class to get camera descriptions
class VideoRecorderInitializer {
  static Future<CameraDescription> initialize() async {
    final cameras = await availableCameras();

    return cameras.first;
  }
}

/// Controller to use for VideoRecorder
class VideoRecorderController extends CameraController {
  CameraType cameraType = CameraType.back; //opens the back camera by default
  bool isDisposed = false;

  VideoRecorderController({CameraDescription cameraDescription})
      : super(cameraDescription, ResolutionPreset.medium);

  @override
  Future<void> initialize() {
    return super.initialize();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    if (!isDisposed) {
      isDisposed = true;
    }
  }

  /// Allows you to switch between front and back camera, returns a new instance of VideoRecorderController
  /// to represent the current selected camera. Throws [NoCameraFound] exception
  /// if device as 0 or only 1 camera
  Future<VideoRecorderController> switchCamera() async {
    final cameras = await availableCameras();

    if (cameras.length <= 1) {
      throw NoCameraFoundException(
          "Your device has ${cameras.length} camera(s)");
    }

    if (cameraType == CameraType.back) {
      //Look for front camera among list and return its description
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          var controller = VideoRecorderController(cameraDescription: camera);
          controller.cameraType = CameraType.front;
          return controller;
        }
      }
    } else if (cameraType == CameraType.front) {
      //Look for front camera among list and return its description
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          var controller = VideoRecorderController(cameraDescription: camera);
          controller.cameraType = CameraType.back;
          return controller;
        }
      }
    }

    return null;
  }
}
