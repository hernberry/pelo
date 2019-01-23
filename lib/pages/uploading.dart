import 'package:flutter/material.dart';

import '../scoped-model/pelo.dart';
import '../model/workout.dart';
import '../widgets/ui_elements/drawer.dart';
import '../controller/uploader.dart';
import 'package:scoped_model/scoped_model.dart';

class UploadingPage extends StatefulWidget {
  final Workout workoutDetails;
  final Uploader uploader;

  UploadingPage(this.workoutDetails, this.uploader);

  @override
  State<StatefulWidget> createState() {
    return _UploadingPageState(uploader);
  }
}

enum _PageState { uploading, processing, complete }

class _UploadingPageState extends State<UploadingPage> with UploadListener {
  final Uploader uploader;
  int stravaWorkoutId;

  _PageState state;

  _UploadingPageState(this.uploader);

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
    state = _PageState.uploading;
    uploader.registerListener(this);
    uploader.startUpload(widget.workoutDetails);
  }

  Widget _bodyText() {
    switch (state) {
      case _PageState.uploading:
        return Text('Your workout is being uploaded to strava');
      case _PageState.processing:
        return Text('Upload complete. Strava is processing your workout.');
      case _PageState.complete:
        return Text(
            'Processing complete. Visit https://www.strava.com/activities/$stravaWorkoutId');
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
            children: <Widget>[_bodyText()],
          ));
    });
  }
}
