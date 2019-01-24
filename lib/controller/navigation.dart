import "package:flutter/material.dart";
import 'package:scoped_model/scoped_model.dart';

import './workout.dart';
import './uploader.dart';
import './service.dart';
import '../model/pelo.dart';

import '../pages/sensor_config.dart';
import '../pages/service_config.dart';
import '../pages/workout.dart';
import '../pages/workout_details.dart';
import '../pages/workout_list.dart';
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
    if (settings.name.startsWith("/workout/")) {
      return _buildWorkoutPage(settings.name, model);
    }
    if (settings.name.startsWith("/details/")) {
      return _buildDetailsPage(settings.name, model);
    }
    if (settings.name == '/sensor_config') {
        return SensorConfigPage();
    }
    if (settings.name == '/service_config') {
      return ServiceConfigPage(ServiceController(model));
    }
    return WorktoutListPage(model.getWorkouts());
  }

  Widget _buildWorkoutPage(String route, PeloModel model) {
    String workoutName = route.replaceAll('/workout/', '');
    return WorkoutPage(WorkoutController(model.stravaAccount, workoutName,
        model.connectedBluetoothDevices, model));
  }

  Widget _buildDetailsPage(String route, PeloModel model) {
    String workoutId = route.replaceAll('/details/', '');
    return WorkoutDetailsPage(model.getCompletedWorkout(workoutId), Uploader(model));
  }
}
