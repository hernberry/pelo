import 'package:flutter/material.dart';

import '../widgets/workout/timer_gauge.dart';
import '../widgets/workout/heart_rate_gauge.dart';
import '../controller/workout.dart';

class WorkoutPage extends StatefulWidget {
  final WorkoutController controller;

  WorkoutPage(this.controller);

  @override
  State<StatefulWidget> createState() {
    controller.initialize();
    return _WorkoutSate();
  }
}

class _WorkoutSate extends State<WorkoutPage> {
  Widget _timerWidget() {
    return TimerGauge(widget.controller.timeNotifier);
  }

  Widget _heartRateWidget() {
    return HeartRateGauge(widget.controller.heartRateChangeNotifier);
  }

  Widget _cadenceWidget() {
    return null;
  }

  void _buttonPressed() {
    widget.controller.startWorkout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Workout"),
        ),
        body: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _timerWidget(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _heartRateWidget(),
                //_cadenceWidget(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RaisedButton(child: Text("Start"), onPressed: _buttonPressed,)
              ],
            )
          ],
        )));
  }
}
