import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'model/pelo.dart';
import 'controller/initialization.dart';

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
  final InitController initController = InitController();
  final NavigationController navigationController = NavigationController();
  PeloModel peloModel;

  @override
  void initState() {
    super.initState();
    initController.createModel().then(_peloModelReady);
  }

  void _peloModelReady(PeloModel peloModel) {
    setState(() {
      this.peloModel = peloModel;
    });
  }

  Widget _loadingWidget() {
    return Container(
      child: Card(child: CircularProgressIndicator(),),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (peloModel == null) {
      return _loadingWidget();
    }
    return ScopedModel<PeloModel>(
        model: peloModel,
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.red,
            accentColor: Colors.black,
          ),
          onGenerateRoute: navigationController.resolveRoute,
        ));
  }
}
