import "package:flutter/material.dart";
import 'package:scoped_model/scoped_model.dart';

import './workout.dart';
import './uploader.dart';
import '../scoped-model/pelo.dart';

import '../pages/sensor_config.dart';
import '../pages/workout.dart';
import '../pages/uploading.dart';
import '../pages/auth.dart';
import '../pages/home.dart';
import '../pages/video_player.dart';

class NavigationController {
  NavigationController();

  MaterialPageRoute resolveRoute(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (BuildContext context) => ScopedModelDescendant(
            builder: (BuildContext context, Widget child, PeloModel model) =>
                _choosePage(settings, model)));
  }

  Widget _choosePage(RouteSettings settings, PeloModel model) {
    if (!model.isAuthenticated) {
      return AuthPage();
    }
    if (settings.name.startsWith("/workout/")) {
      return _buildWorkoutPage(settings.name, model);
    }
    if (settings.name.startsWith("/upload/")) {
      return _buildUploadingPage(settings.name, model);
    }
    if (settings.name == '/auth') {
        return AuthPage();
    }
    if (settings.name == '/sensor_config') {
        return SensorConfigPage();
    }
    return HomePage();
  }

  Widget _buildWorkoutPage(String route, PeloModel model) {
    String workoutName = route.replaceAll('/workout/', '');
    return WorkoutPage(WorkoutController(model.stravaAccount, workoutName,
        model.connectedBluetoothDevices, model));
  }

  Widget _buildUploadingPage(String route, PeloModel model) {
    String workoutId = route.replaceAll('/upload/', '');
    return UploadingPage(model.getCompletedWorkout(workoutId), Uploader(model.stravaClient));
  }

  MaterialPageRoute _buildSensorConfigPage() {
    return MaterialPageRoute(
        builder: (BuildContext context) => SensorConfigPage());
  }
}
