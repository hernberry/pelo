import 'dart:core';
import 'package:flutter/material.dart';
import '../model/devices/cadence.dart';
import '../model/devices/heart_rate.dart';
import '../model/devices/bluetooth_device_descriptor.dart';
import '../model/devices/bluetooth.dart';

import '../model/devices/stopwatch.dart';

class WorkoutController extends ChangeNotifier {

  final String workoutName;
  final List<BluetoothDeviceDescriptor> deviceDescriptors;
  List<BluetoothDevice> devices;
  Stopwatch stopwatch;

  DateTime startTime;
  DateTime endTime;

  WorkoutController(this.workoutName, this.deviceDescriptors) {
    stopwatch = Stopwatch(_stopwatchReading);
  }

  int lastHearRateMeasurement = 0;
  int lastCadenceMeasurement = 0;
  Duration lastTimeMeasurement = Duration(seconds: 0);

  void initialize() {
    // Connect to all Bluetooth devices and start showing data (even if the workout hasn't started yet).
    devices = deviceDescriptors.map(_initializeDevice);
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
    lastHearRateMeasurement = heartRate;
  }

  void _cadenceReading(int cadence) {
    lastCadenceMeasurement = cadence;
  }

  void _stopwatchReading(Duration elapsedTime) {
    lastTimeMeasurement = elapsedTime;
    notifyListeners();
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