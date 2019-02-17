import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'time_notifier.dart';
import 'heart_rate_notifier.dart';
import 'cadence_notifier.dart';
import 'workout.dart';
import './workout_state.dart';
import 'playlist.dart';
import './playlist_state.dart';

enum ControlsViewState { visible, hidden }

class VideoWorkoutController extends ChangeNotifier {
  final WorkoutController _workoutController;
  final PlaylistController _playlistController;
  ControlsViewState _controlsViewState;

  VideoWorkoutController(this._workoutController, this._playlistController);

  WorkoutState get currentState => _workoutController.currentState;
  ControlsViewState get controlsViewState => _controlsViewState;
  VideoPlayerController get playerController => _playlistController.playerController;
  PlaylistState get playlistState => _playlistController.playlistState;
  Duration get currentVideoRemaining => _playlistController.currentVideoRemaining;

  TimeNotifier get timeNotifier => _workoutController.timeNotifier;
  HeartRateChangeNotifier get heartRateNotifier => _workoutController.heartRateChangeNotifier;
  CadenceChangeNotifier get cadenceNotifier => _workoutController.cadenceChangeNotifier;

  Future<void> initialize() async {
    _controlsViewState = ControlsViewState.visible;
    _playlistController.addListener(_playlistControllerNotified);
    await _workoutController.initialize();
    await _playlistController.initialize();
  }

  void _playlistControllerNotified() {
    notifyListeners();
  }

  void toggle() {
    switch (currentState) {
      case WorkoutState.initializing:
        break;
      case WorkoutState.stopped:
        _start();
        break;
      case WorkoutState.running:
        if (_controlsViewState == ControlsViewState.hidden) {
          _showControls();
        } else {
          _pause();
        }
        break;
      case WorkoutState.paused:
        _resume();
        break;
    }
  }

  void _start() {
    _controlsViewState = ControlsViewState.visible;
    _workoutController.startWorkout();
    _playlistController.play();
    notifyListeners();
    _startHideTimeout();
  }

  Future<String> end() {
    _playlistController.pause();
    Future<String> id = _workoutController.endWorkout();
    notifyListeners();
    return id;
  }

  void _pause() {
    _controlsViewState = ControlsViewState.visible;
    _playlistController.pause();
    _workoutController.pauseWorkout();
    notifyListeners();
  }

  void _resume() {
    _controlsViewState = ControlsViewState.visible;
    _playlistController.play();
    _workoutController.resumeWorkout();
    notifyListeners();
    _startHideTimeout();
  }

  Timer _hideTimer;
  void _startHideTimeout() {
    if (_hideTimer != null && _hideTimer.isActive) {
      _hideTimer.cancel();
    }
    _hideTimer = Timer(Duration(seconds: 7), _hideControls);
  }

  void _hideControls() {
    if (_workoutController.currentState == WorkoutState.running) {
      _controlsViewState = ControlsViewState.hidden;
      notifyListeners();
    }
  }

  void _showControls() {
    _controlsViewState = ControlsViewState.visible;
    _startHideTimeout();
    notifyListeners();
  }
}
