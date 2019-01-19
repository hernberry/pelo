import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../controller/workout.dart';
import '../scoped-model/pelo.dart';
import '../widgets/new_workout_dialog.dart';
import '../widgets/ui_elements/drawer.dart';
import './workout.dart';

class HomePage extends StatelessWidget {
  Future<void> _onStartPressed(BuildContext context, PeloModel model) async {
    String value = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => NewWorkoutDialog());
    if (value != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => WorkoutPage(
                  WorkoutController(value, model.connectedBluetoothDevices))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PeloModel>(
        builder: (BuildContext context, Widget child, PeloModel model) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Workout"),
          ),
          drawer: PeloDrawer(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.play_circle_filled),
            onPressed: () {
              _onStartPressed(context, model);
            },
          ),
          body: Column(
            children: <Widget>[
              Text("Something will go here eventually.....")
            ],
          ));
    });
  }
}
