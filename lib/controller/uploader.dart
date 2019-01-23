import 'dart:core';
import 'dart:async';
import '../strava/client.dart';
import '../model/workout.dart';

abstract class UploadListener {
  void uploadComplete(int id);

  void processingComplete(bool isSuccess);
}

class Uploader {
  Timer completionCheckTimer;
  StravaClient stravaClient;

  Uploader(this.stravaClient);

  UploadListener listener;

  void registerListener(UploadListener listener) {
    this.listener = listener;
  }

  void startUpload(Workout workout) {
    stravaClient
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
    UploadState state = await stravaClient.getUploadState(id);
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
