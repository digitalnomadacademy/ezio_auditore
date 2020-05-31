import 'package:example/pages/example_page.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> routes = {
  RouteName.home: (context) => ExamplePage(),
  ...testRoutes
};

String initialRoute = RouteName.testPage;

class RouteName {
  static const String home = '/';
  static const String testPage = 'test';
  
}

Map<String, WidgetBuilder> testRoutes = {
  RouteName.testPage: (context) => _TestPage(),
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
