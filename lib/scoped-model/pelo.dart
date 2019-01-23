import "package:scoped_model/scoped_model.dart";

import '../strava/account.dart';
import '../strava/client.dart';
import '../model/devices/bluetooth_device_descriptor.dart';
import '../model/workout.dart';

class PeloModel extends Model {
  StravaAccount stravaAccount;
  StravaClient stravaClient;

  Map<String,BluetoothDeviceDescriptor> _connectedDevices = {};
  Map<String, Workout> _workouts = {};

  bool get isAuthenticated {
    return stravaAccount != null;
  }

  void setStravaClient(StravaClient client) {
    this.stravaClient = client;
  }

  void setStravaAccount(StravaAccount stravaAccount) {
    this.stravaAccount = stravaAccount;
  }

  bool isConnected(String id) {
    return _connectedDevices.containsKey(id);
  }

  void disconnect(String id) {
    _connectedDevices.remove(id);
  }

  void connect(String id, String name, Type deviceType) {
    _connectedDevices[id] = BluetoothDeviceDescriptor(id, name, deviceType);
  }

  List<BluetoothDeviceDescriptor> get connectedBluetoothDevices {
    return List.unmodifiable(_connectedDevices.values.toList());
  }

  void addCompletedWorkout(Workout workout) {
    _workouts[workout.localId] = workout;
  }

  Workout getCompletedWorkout(String localWorkoutId) {
    return _workouts[localWorkoutId];
  }
}