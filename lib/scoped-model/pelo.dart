import "package:scoped_model/scoped_model.dart";

import '../strava/account.dart';
import '../strava/client.dart';
import '../model/devices/bluetooth_device_descriptor.dart';

class PeloModel extends Model {
  StravaAccount stravaAccount;
  StravaClient stravaClient;

  Map<String, Type> _connectedDevices = {};

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

  void connect(String id, Type deviceType) {
    _connectedDevices[id] = deviceType;
  }

  List<BluetoothDeviceDescriptor> get connectedBluetoothDevices {
    return List.unmodifiable(_connectedDevices.values.toList());
  }
}