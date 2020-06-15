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

  ///Check if we are currently recording video
  bool get isRecordingVideo => this.value.isRecordingVideo;

  ///Check if current recording is paused
  bool get isRecordingPaused => this.value.isRecordingPaused;

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

  /// Function to record videos. Requires a file path. Returns a future with
  /// recorded video in specified file path
  Future<void> startVideoRecording(String filePath) async {
    return super.startVideoRecording(filePath);
  }

  /// Function to pause video recording. Returns null if no video is being recorded
  Future<void> pauseVideoRecording() async {
    if (!this.isRecordingVideo) {
      return null;
    }
    return super.pauseVideoRecording();
  }

  /// Function to resume video recording. Returns null if no video was being recorded
  Future<void> resumeVideoRecording() async {
    if (!this.isRecordingVideo) {
      return null;
    }
    return super.resumeVideoRecording();
  }

  /// Function to stop video recording. Returns null if no video is being recorded
  Future<void> stopVideoRecording() async {
    if (!this.isRecordingVideo) {
      return null;
    }
    return super.stopVideoRecording();
  }
}
