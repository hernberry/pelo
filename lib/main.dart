import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/rendering.dart';


import 'scoped-model/pelo.dart';
import 'pages/auth.dart';
import 'pages/workout.dart';
import 'pages/sensor_config.dart';

void main() {
  debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return ScopedModel<PeloModel>(
      model: PeloModel(),
      child: MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.black,
      ),
      routes: {
        '/': (BuildContext context) => AuthPage(),
        '/workout': (BuildContext context) => WorkoutPage(),
        '/sensor_config': (BuildContext context) => SensorConfigPage(),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            builder: (BuildContext context) => AuthPage());
      },
    ));
  }
}
