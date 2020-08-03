import 'package:example/pages/camera_example.dart';

import 'package:example/pages/concat_videos.dart';
import 'package:example/pages/example_page.dart';
import 'package:example/pages/thumbnail_example.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> routes = {
  RouteName.home: (context) => ExamplePage(),
  RouteName.concat: (context) => ConcatVideosPage(),
  ...testRoutes
};

String initialRoute = RouteName.testPage;

class RouteName {
  static const String home = '/';
  static const String testPage = 'test';
  static const String cameraExample = 'cameraExample';
  static const String concat = 'concat';
  static const String thumbnailExample = 'thumbnailExample';
}

Map<String, WidgetBuilder> testRoutes = {
  RouteName.testPage: (context) => _TestPage(),
  RouteName.cameraExample: (context) => CameraExample(),
  RouteName.thumbnailExample: (context) => ThumbnailExample(),
};

class _TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routes"),
      ),
      body: ListView(
        children: routes.keys
            .map((routeName) => Card(
                  child: ListTile(
                    title: Text(routeName),
                    onTap: () => Navigator.pushNamed(context, routeName),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
