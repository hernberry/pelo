import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../controller/workout.dart';
import '../scoped-model/pelo.dart';
import '../widgets/new_workout_dialog.dart';
import '../widgets/ui_elements/drawer.dart';

class HomePage extends StatelessWidget {
  Future<void> _onStartPressed(BuildContext context) async {
    String value = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => NewWorkoutDialog());
    if (value != null) {
      Navigator.pushReplacementNamed(context, "/workout/$value");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PeloModel>(
        builder: (BuildContext context, Widget child, PeloModel model) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Monoton"),
          ),
          drawer: PeloDrawer(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.play_circle_filled),
            onPressed: () => _onStartPressed(context)
          ),
          body: Column(
            children: <Widget>[
            ],
          ));
    });
  }
}
