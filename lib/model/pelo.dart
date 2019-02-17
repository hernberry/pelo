import 'dart:convert';
import "package:scoped_model/scoped_model.dart";
import 'package:shared_preferences/shared_preferences.dart';

import 'services/strava/account.dart';
import 'services/strava/client.dart';
import 'services/peloton/client.dart';
import 'devices/bluetooth_device_descriptor.dart';
import 'workout.dart';

class PeloModel extends Model {
  static const String _DEVICES_KEY = "connected_devices";
  static const String WORKOUTS_KEY = "workouts";
  static const String STRAVA_CREDS_KEY = "strava_creds";
  static const String PELOTON_CREDS_KEY = "peloton_creds";

  StravaAccount stravaAccount;
  StravaClient stravaClient;
  PelotonClient pelotonClient;

  Map<String, WorkoutPlan> _workoutPlans = {};

  WorkoutPlan getPlan(String planId) {
    return _workoutPlans[planId];
  }

  void setPlan(WorkoutPlan plan) {
    _workoutPlans[plan.id] = plan;
  }
 
  final SharedPreferences _sharedPreferences;

  PeloModel(this._sharedPreferences);

  bool get isStravaAuthenticated {
    return stravaAccount != null;
  }

  bool get isPelotonAuthenticated {
    return pelotonClient != null;
  }

  void setStravaClient(StravaClient client) {
    this.stravaClient = client;
    _sharedPreferences.setString(STRAVA_CREDS_KEY, client.credentials);
  }

  void setStravaAccount(StravaAccount stravaAccount) {
    this.stravaAccount = stravaAccount;
  }

  String get stravaCredentials {
    return _sharedPreferences.getString(STRAVA_CREDS_KEY);
  }

  Future<void> disconnectStrava() async {
    await updateStravaCredentials(null);
    setStravaClient(null);
    setStravaAccount(null);
  }

  Future<void> updateStravaCredentials(String value) async {
    return _sharedPreferences.setString(STRAVA_CREDS_KEY, value);
  }

  void setPelotonClient(PelotonClient pelotonClient) {
    this.pelotonClient = pelotonClient;
  }

  Future<void> updatePelotonCredentials(String credentials) {
    return _sharedPreferences.setString(PELOTON_CREDS_KEY, credentials);
  }

  Future<void> disconnectPeloton() async {
    await updatePelotonCredentials(null);
    setPelotonClient(null);
  }

  bool isDeviceConnected(String id) {
    return _connectedDevicesMap.containsKey(id);
  }

  void disconnectDevice(String id) {
    Map<String, BluetoothDeviceDescriptor> devices = _connectedDevicesMap;
    devices.remove(id);
    _sharedPreferences.setString(_DEVICES_KEY, jsonEncode(devices));
  }

  void connectDevice(BluetoothDeviceDescriptor descriptor) {
    Map<String, BluetoothDeviceDescriptor> devices = _connectedDevicesMap;
    devices[descriptor.deviceGuid] = descriptor;
    _sharedPreferences.setString(_DEVICES_KEY, jsonEncode(devices));
  }

  Map<String, BluetoothDeviceDescriptor> get _connectedDevicesMap {
    String value = _sharedPreferences.getString(_DEVICES_KEY);
    if (value == null) {
      return {};
    }
    return decodeValues(
        value, (device) => BluetoothDeviceDescriptor.fromJson(device));
  }

  Map<String, T> decodeValues<T>(
      String jsonString, Function(Map<String, dynamic> json) decode) {
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap.map((k, v) => MapEntry(k, decode(v)));
  }

  List<BluetoothDeviceDescriptor> get connectedBluetoothDevices {
    return _connectedDevicesMap.values.toList();
  }

  Map<String, Workout> get _workoutsMap {
    String value = _sharedPreferences.getString(WORKOUTS_KEY);
    if (value == null) {
      return {};
    }
    return decodeValues(value, (device) => Workout.fromJson(device));
  }

  void setCompletedWorkout(Workout workout) {
    Map<String, Workout> workouts = _workoutsMap;
    workouts[workout.localId] = workout;
    _sharedPreferences.setString(WORKOUTS_KEY, jsonEncode(workouts));
  }

  Workout getCompletedWorkout(String localWorkoutId) {
    return _workoutsMap[localWorkoutId];
  }

  List<Workout> getWorkouts() {
    return _workoutsMap.values.toList();
  }

  void removeWorkout(String workoutLocalId) {
    Map<String, Workout> workouts = _workoutsMap;
    workouts.remove(workoutLocalId);
    _sharedPreferences.setString(WORKOUTS_KEY, jsonEncode(workouts));
  }
}
