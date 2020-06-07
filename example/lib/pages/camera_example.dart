import 'package:flutter/material.dart';
import 'package:flutter_video_editor/widgets/video_recorder.dart';

class CameraExample extends StatefulWidget {
  @override
  _CameraExampleState createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample>
    with WidgetsBindingObserver {
  VideoRecorderController controller;

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
                      } catch (e) {}
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
}
