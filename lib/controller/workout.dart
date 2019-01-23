import 'dart:io';
import 'dart:core';
import '../strava/account.dart';
import '../model/devices/cadence.dart';
import '../model/devices/heart_rate.dart';
import '../model/devices/bluetooth_device_descriptor.dart';
import '../model/devices/bluetooth.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

import '../model/devices/stopwatch.dart';
import '../model/workout.dart';
import '../scoped-model/pelo.dart';
import './workout_recorder.dart';
import './time_notifier.dart';
import './heart_rate_notifier.dart';
import './cadence_notifier.dart';

enum WorkoutState { initializing, stopped, running, paused }

class WorkoutController {
  final String workoutName;
  final List<BluetoothDeviceDescriptor> deviceDescriptors;
  final TimeNotifier timeNotifier;
  final HeartRateChangeNotifier heartRateChangeNotifier;
  final CadenceChangeNotifier cadenceChangeNotifier;
  final StravaAccount stravaAccount;
  // TODO - extract a workouts manager so we don't have to inect the whole model here.
  final PeloModel peloModel;

  List<BluetoothDevice> devices;
  bool _hasHeartRateMonitor;
  bool _hasCadenceMonitor;
  Stopwatch stopwatch;

  DateTime startTime;
  DateTime endTime;
  String _workoutFileName;

  String _localId;
  String get localWorkoutId => _localId;

  WorkoutRecorder _workoutRecorder;

  WorkoutState _currentState = WorkoutState.initializing;
  WorkoutState get currentState {
    return _currentState;
  }

  WorkoutController(
      this.stravaAccount, this.workoutName, this.deviceDescriptors, this.peloModel)
      : heartRateChangeNotifier = HeartRateChangeNotifier(),
        timeNotifier = TimeNotifier(),
        cadenceChangeNotifier = CadenceChangeNotifier() {
    stopwatch = Stopwatch(_stopwatchReading);
  }

  Duration lastTimeMeasurement = Duration(seconds: 0);

  Future<void> initialize() async {
    // Connect to all Bluetooth devices and start showing data (even if the workout hasn't started yet).
    devices = deviceDescriptors.map(_initializeDevice).toList();

    _localId = Uuid().v4();
    Directory directory = await getApplicationDocumentsDirectory();

    _workoutFileName = '${directory.path}/$_localId-$workoutName.tcx';

    _workoutRecorder = WorkoutRecorder(_workoutFileName);
    await _workoutRecorder.initialize();
    this._currentState = WorkoutState.stopped;
  }

  void startWorkout() {
    _currentState = WorkoutState.running;
    startTime = DateTime.now();
    _workoutRecorder.start(WorkoutHeader(startTime));
    stopwatch.start();
  }

  Future<void> endWorkout() async {
    _currentState = WorkoutState.stopped;
    endTime = DateTime.now();
    stopwatch.stop();
    await _workoutRecorder.finish(WorkoutSummary(endTime.difference(startTime)));
    peloModel.addCompletedWorkout(Workout(workoutName, _workoutFileName, _localId));
  }

  void pauseWorkout() {
    _currentState = WorkoutState.paused;
    stopwatch.stop();
  }

  void resumeWorkout() {
    _currentState = WorkoutState.running;
    stopwatch.start();
  }

  int _getHearRateZone(int heartRate) {
    for (int i = 1; i < 5; i++) {
      Zone zone = stravaAccount.heartRateZones[i];
      if (heartRate <= zone.max) {
        return i;
      }
    }
    return 5;
  }

  void _heartRateReading(int heartRate) {
    heartRateChangeNotifier.update(heartRate, _getHearRateZone(heartRate));
  }

  void _cadenceReading(int cadence) {
    cadenceChangeNotifier.update(cadence);
  }

  void _stopwatchReading(Duration elapsedTime) {
    timeNotifier.update(elapsedTime);
    int heartRate = _hasHeartRateMonitor ? heartRateChangeNotifier.currentHeartRate : null;
    int cadence = _hasCadenceMonitor ? cadenceChangeNotifier.currentCadence : null;
    _workoutRecorder.record(
      WorkoutRecord(
        DateTime.now(),
        heartRate,
        cadence));
  }

  BluetoothDevice _initializeDevice(BluetoothDeviceDescriptor descriptor) {
    if (descriptor.deviceType == HearRateMonitor) {
      HearRateMonitor hrm = HearRateMonitor.fromDescriptor(descriptor);
      hrm.subscribe(_heartRateReading);
      hrm.connect();
      _hasHeartRateMonitor = true;
      return hrm;
    } else if (descriptor.deviceType == CadenceMonitor) {
      CadenceMonitor cadence = CadenceMonitor.fromDescriptor(descriptor);
      cadence.subscribe(_cadenceReading);
      cadence.connect();
      _hasCadenceMonitor = true;
      return cadence;
    }
    throw Exception('Unkown device type: $descriptor.type');
  }
}
