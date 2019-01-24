import 'package:flutter/material.dart';
import '../../model/workout.dart';

class WorkoutListElement extends StatelessWidget {
  final Workout workout;

  WorkoutListElement(this.workout);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.pushNamed(context, '/details/${workout.localId}'),
      leading: Icon(Icons.directions_bike),
      title: Text(workout.name),
      subtitle: Text(workout.time.toString()),
      trailing: Text("${workout.duration.inMinutes} minutes"),
    );
  }
}
