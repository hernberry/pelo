import 'package:flutter/material.dart';
import '../model/workout.dart';
import '../widgets/new_workout_dialog.dart';
import '../widgets/ui_elements/drawer.dart';
import '../widgets/ui_elements/workout_element.dart';

class WorktoutListPage extends StatelessWidget {
  final List<Workout> workouts;

  WorktoutListPage(this.workouts);

  Future<void> _onStartPressed(BuildContext context) async {
    Navigator.pushReplacementNamed(context, "/new_workout");
  }

  Widget _body() {
    if (workouts.isEmpty) {
      return Text("No workouts logged yet!");
    }
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
              color: Colors.black,
            ),
        itemCount: workouts.length,
        itemBuilder: (ontext, index) => WorkoutListElement(workouts[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Workouts"),
        ),
        drawer: PeloDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.play_circle_filled),
            onPressed: () => _onStartPressed(context)),
        body: Container(child: _body()));
  }
}
