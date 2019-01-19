import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/rendering.dart';

import 'scoped-model/pelo.dart';
import 'pages/auth.dart';
import 'pages/home.dart';
import 'pages/sensor_config.dart';

void main() {
  //debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  static final Map<String, WidgetBuilder> ROUTES = {
    '/': (BuildContext context) => HomePage(),
    '/auth': (BuildContext context) => AuthPage(),
    '/sensor_config': (BuildContext context) => SensorConfigPage(),
  };

  @override
  Widget build(BuildContext context) {
    PeloModel model = PeloModel();
    return ScopedModel<PeloModel>(
        model: model,
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.red,
            accentColor: Colors.black,
          ),
          onGenerateRoute: (RouteSettings settings) {
            if (!model.isAuthenticated) {
              return MaterialPageRoute(
                  builder: (BuildContext context) => AuthPage());
            }
            if (!ROUTES.containsKey(settings.name)) {
              return null;
            }
            return MaterialPageRoute(builder: ROUTES[settings.name]);
          },
          onUnknownRoute: (RouteSettings settings) {
            return MaterialPageRoute(
                builder: (BuildContext context) => HomePage());
          },
        ));
  }
}
