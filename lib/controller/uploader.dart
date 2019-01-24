import 'dart:core';
import 'dart:async';
import '../model/services/strava/client.dart';
import '../model/workout.dart';
import '../model/pelo.dart';

abstract class UploadListener {
  void uploadComplete(int id);

  void processingComplete(bool isSuccess);
}

class Uploader {
  Timer completionCheckTimer;
  final PeloModel model;

  Uploader(this.model);

  UploadListener listener;

  bool get isStravaConnected {
    return model.isStravaAuthenticated;
  }

  void removeWorkout(Workout workout) {
    model.removeWorkout(workout.localId);
  }

  void registerListener(UploadListener listener) {
    this.listener = listener;
  }

  void startUpload(Workout workout) {
    model.stravaClient
        .uploadWorkout(workout)
        .then((Map<String, dynamic> uploadResponse) {
      listener.uploadComplete(uploadResponse['id']);
      completionCheckTimer = Timer(
        Duration(seconds: 15),
        () {
          _checkCompletion(uploadResponse['id']);
        },
      );
    });
  }

  Future<void> _checkCompletion(int id) async {
    UploadState state = await model.stravaClient.getUploadState(id);
    if (state == UploadState.error) {
      listener.processingComplete(false);
      return;
    } else if (state == UploadState.ready) {
      listener.processingComplete(true);
      return;
    }
    completionCheckTimer = Timer(Duration(seconds: 15), () {
      _checkCompletion(id);
    });
  }
}
