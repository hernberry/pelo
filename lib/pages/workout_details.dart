import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/pelo.dart';
import '../model/workout.dart';
import '../widgets/ui_elements/drawer.dart';
import '../controller/uploader.dart';
import 'package:scoped_model/scoped_model.dart';

class WorkoutDetailsPage extends StatefulWidget {
  final Workout workoutDetails;
  final Uploader uploader;

  WorkoutDetailsPage(this.workoutDetails, this.uploader);

  @override
  State<StatefulWidget> createState() {
    return _WorkoutDetailsPageState(uploader);
  }
}

enum _PageState { notStarted, uploading, processing, complete }

class _WorkoutDetailsPageState extends State<WorkoutDetailsPage>
    with UploadListener {
  final Uploader uploader;
  int stravaWorkoutId;

  _PageState state = _PageState.notStarted;

  _WorkoutDetailsPageState(this.uploader);

  @override
  void uploadComplete(int id) {
    setState(() {
      state = _PageState.processing;
      stravaWorkoutId = id;
    });
  }

  @override
  void processingComplete(bool success) {
    setState(() {
      state = _PageState.complete;
    });
  }

  @override
  void initState() {
    super.initState();
    uploader.registerListener(this);
    if (widget.workoutDetails.stravaId != null) {
      state = _PageState.complete;
      stravaWorkoutId = widget.workoutDetails.stravaId;
    }
  }

  Widget _removeWorkoutButton() {
    return InkWell(
        onTap: () {
          uploader.removeWorkout(widget.workoutDetails);
          Navigator.pushReplacementNamed(context, '/');
        },
        child: Text('Remove this workout.'));
  }

  Widget _newPageState() {
    if (uploader.isStravaConnected) {
      return InkWell(
        child: Text("Upload this workout to Strava"),
        onTap: () {
          uploader.startUpload(widget.workoutDetails);
          state = _PageState.uploading;
        },
      );
    }
    return Text("Connect to Strava to upload and view this Workout");
  }

  Widget _body() {
    switch (state) {
      case _PageState.uploading:
        return Text('Your workout is being uploaded to strava');
      case _PageState.processing:
        return Text('Upload complete. Strava is processing your workout.');
      case _PageState.complete:
        return InkWell(
            onTap: () =>
                launch('https://www.strava.com/activities/$stravaWorkoutId'),
            child: Text(
                'Visit https://www.strava.com/activities/$stravaWorkoutId to view your workout!'));
      case _PageState.notStarted:
        return _newPageState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PeloModel>(
        builder: (BuildContext context, Widget child, PeloModel model) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Uploading"),
          ),
          drawer: PeloDrawer(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _body(), 
              SizedBox(height: 50,),
              _removeWorkoutButton()],
          ));
    });
  }
}
