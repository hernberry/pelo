import "package:flutter/material.dart";
import 'package:scoped_model/scoped_model.dart';

import './workout.dart';
import './uploader.dart';
import './service.dart';
import './ride_list.dart';
import './new_workout_controller.dart';
import './playlist.dart';
import './video_workout.dart';

import '../model/pelo.dart';
import '../model/services/peloton/types.dart';
import '../model/workout.dart';

import '../pages/sensor_config.dart';
import '../pages/service_config.dart';
import '../pages/workout.dart';
import '../pages/workout_details.dart';
import '../pages/workout_list.dart';
import '../pages/video_select.dart';
import '../pages/video_workout.dart';
import '../pages/new_workout.dart';
import '../pages/video_player.dart';

class NavigationController {
  NavigationController();

  MaterialPageRoute<dynamic> resolveRoute(RouteSettings settings) {
    if (settings.name.startsWith("/new_workout")) {
      return _createRoute<WorkoutPlan>(
          (model) => NewWorkoutPage(NewWorkoutController(model)));
    }
    if (settings.name.startsWith("/video_workout/")) {
      return _createRoute<String>(
          (model) => _buildVideoWorkoutPage(settings.name, model));
    }
    if (settings.name.startsWith("/workout/")) {
      return _createRoute<String>(
          (model) => _buildWorkoutPage(settings.name, model));
    }
    if (settings.name.startsWith("/details/")) {
      return _createRoute<String>(
          (model) => _buildDetailsPage(settings.name, model));
    }
    if (settings.name == '/sensor_config') {
      return _createRoute<String>((model) => SensorConfigPage());
    }
    if (settings.name == '/service_config') {
      return _createRoute<String>(
          (model) => ServiceConfigPage(ServiceController(model)));
    }
    if (settings.name == '/video_select') {
      return _createRoute<RideInfo>(
          (model) => RideListPage(RideListController(model.pelotonClient)));
    }
    return _createRoute<String>(
          (model) => WorktoutListPage(model.getWorkouts()));
  }

  MaterialPageRoute<T> _createRoute<T>(Function(PeloModel m) func) {
    return MaterialPageRoute<T>(
        builder: (c) => ScopedModelDescendant(
            builder: (BuildContext bc, Widget w, PeloModel m) => func(m)));
  }

  Widget _buildWorkoutPage(String route, PeloModel model) {
    String workoutName = route.replaceAll('/workout/', '');
    return WorkoutPage(WorkoutController(model.stravaAccount, workoutName,
        model.connectedBluetoothDevices, model));
  }

  Widget _buildVideoWorkoutPage(String route, PeloModel model) {
    String planId = route.replaceAll('/video_workout/', '');
    WorkoutPlan plan = model.getPlan(planId);
    return VideoWorkoutPage(VideoWorkoutController(
        WorkoutController(model.stravaAccount, plan.name,
            model.connectedBluetoothDevices, model, 
            playlist: plan.playlist),
        PlaylistController(plan.playlist, model.pelotonClient)));
  }

  Widget _buildDetailsPage(String route, PeloModel model) {
    String workoutId = route.replaceAll('/details/', '');
    return WorkoutDetailsPage(
        model.getCompletedWorkout(workoutId), Uploader(model));
  }
}
