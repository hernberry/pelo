import 'dart:core';
import '../model/devices/cadence.dart';
import '../model/devices/heart_rate.dart';
import '../model/devices/bluetooth_device_descriptor.dart';
import '../model/devices/bluetooth.dart';

import '../model/devices/stopwatch.dart';
import './time_notifier.dart';
import './heart_rate_notifier.dart';

class WorkoutController {

  final String workoutName;
  final List<BluetoothDeviceDescriptor> deviceDescriptors;
  final TimeNotifier timeNotifier;
  final HeartRateChangeNotifier heartRateChangeNotifier;
  List<BluetoothDevice> devices;
  Stopwatch stopwatch;

  DateTime startTime;
  DateTime endTime;

  WorkoutController(this.workoutName, this.deviceDescriptors) :
      heartRateChangeNotifier = HeartRateChangeNotifier(),
      timeNotifier = TimeNotifier() {
    stopwatch = Stopwatch(_stopwatchReading);
  }

  Duration lastTimeMeasurement = Duration(seconds: 0);

  void initialize() {
    // Connect to all Bluetooth devices and start showing data (even if the workout hasn't started yet).
    devices = deviceDescriptors.map(_initializeDevice).toList();
  }

  void startWorkout() {
    startTime = DateTime.now();
    stopwatch.start();
  }

  void endWorkout() {
    endTime = DateTime.now();
    stopwatch.stop();
  }

  void _heartRateReading(int heartRate) {
    heartRateChangeNotifier.update(heartRate, 4);
  }

  void _cadenceReading(int cadence) {
  }

  void _stopwatchReading(Duration elapsedTime) {
    timeNotifier.update(elapsedTime);
  }

  BluetoothDevice _initializeDevice(BluetoothDeviceDescriptor descriptor) {
    if (descriptor.deviceType == HearRateMonitor) {
      HearRateMonitor hrm = HearRateMonitor.fromDescriptor(descriptor);
      hrm.subscribe(_heartRateReading);
      hrm.connect();
      return hrm;
    } else if (descriptor.deviceType == CadenceMonitor) {
      CadenceMonitor cadence = CadenceMonitor.fromDescriptor(descriptor);
      cadence.subscribe(_cadenceReading);
      cadence.connect();
      return cadence;
    }
    throw Exception('Unkown device type: $descriptor.type');
  }
}