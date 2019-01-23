import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/rendering.dart';

import 'scoped-model/pelo.dart';
import 'pages/auth.dart';
import 'pages/home.dart';
import 'pages/sensor_config.dart';
import 'pages/uploading.dart';

import 'controller/uploader.dart';
import 'controller/navigation.dart';

void main() {
  //debugPaintSizeEnabled = true;
  runApp(MonotonApp());
}

class MonotonApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MonotonState();
  }
}

class _MonotonState extends State<MonotonApp> {
  @override
  Widget build(BuildContext context) {
    PeloModel model = PeloModel();
    NavigationController nav = NavigationController();
    return ScopedModel<PeloModel>(
        model: model,
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.red,
            accentColor: Colors.black,
          ),
          onGenerateRoute: nav.resolveRoute,
          onUnknownRoute: (RouteSettings settings) {
            return MaterialPageRoute(
                builder: (BuildContext context) => HomePage());
          },
        ));
  }
}
