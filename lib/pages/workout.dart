import 'package:flutter/material.dart';

import '../widgets/workout/timer_gauge.dart';
import '../widgets/workout/heart_rate_gauge.dart';
import '../widgets/workout/cadence_gauge.dart';
import '../controller/workout.dart';

class WorkoutPage extends StatefulWidget {
  final WorkoutController workoutController;

  WorkoutPage(this.workoutController);

  @override
  State<StatefulWidget> createState() {
    return _WorkoutPageState(this.workoutController);
  }
}

class _WorkoutPageState extends State<WorkoutPage> {
  final WorkoutController controller;

  _WorkoutPageState(this.controller);

  Widget _timerWidget() {
    return TimerGauge(controller.timeNotifier);
  }

  Widget _heartRateWidget() {
    return HeartRateGauge(controller.heartRateChangeNotifier);
  }

  Widget _cadenceWidget() {
    return CadenceGauge(controller.cadenceChangeNotifier);
  }

  void _startPressed() {
    setState(() {
      controller.startWorkout();
    });
  }

  void _pausePressed() {
    setState(() {
      controller.pauseWorkout();
    });
  }

  void _resumePressed() {
    setState(() {
      controller.resumeWorkout();
    });
  }

  void _endPressed(BuildContext context) {
    controller.endWorkout().then((arg) => Navigator.pushReplacementNamed(
        context, "/upload/${controller.localWorkoutId}"));
  }

  List<Widget> _workoutStoppedRow() {
    return [
      RaisedButton(
        child: Text("Start"),
        onPressed: _startPressed,
      )
    ];
  }

  List<Widget> _workoutPausedRow() {
    return [
      RaisedButton(
        child: Text("End"),
        onPressed: () => _endPressed(context),
      ),
      RaisedButton(
        child: Text("Resume"),
        onPressed: _resumePressed,
      )
    ];
  }

  List<Widget> _workoutRunningRow() {
    return [
      RaisedButton(child: Text("End"), onPressed: () => _endPressed(context)),
      RaisedButton(
        child: Text("Pause"),
        onPressed: _pausePressed,
      )
    ];
  }

  Row _getButtonRow() {
    List<Widget> buttons;
    switch (controller.currentState) {
      case WorkoutState.running:
      case WorkoutState.initializing:
        buttons = _workoutRunningRow();
        break;
      case WorkoutState.paused:
        buttons = _workoutPausedRow();
        break;
      case WorkoutState.stopped:
        buttons = _workoutStoppedRow();
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: buttons);
  }

  @override
  void initState() {
    super.initState();
    controller.initialize().then((arg) {
      setState(() {});
    });
  }

  Widget _initializingBody() {
    return new Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Initializing Workout"),
            CircularProgressIndicator()
          ]),
    );
  }

  Widget _workoutBody() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            _cadenceWidget(),
          ],
        ),
        _getButtonRow()
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Workout: ${controller.workoutName}"),
        ),
        body: controller.currentState == WorkoutState.initializing
            ? _initializingBody()
            : _workoutBody());
    ;
  }
}
