import 'dart:async';
import 'dart:core';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import './bluetooth_device_descriptor.dart';

abstract class BluetoothDevice {
  final fb.BluetoothDevice device;
  final fb.FlutterBlue flutterBlue = fb.FlutterBlue.instance;

  String get name {
    return device.name;
  }

  StreamSubscription<fb.BluetoothDeviceState> connection;

  BluetoothDevice(this.device);

  BluetoothDevice.fromDescriptor(BluetoothDeviceDescriptor descriptor)
      : device = fb.BluetoothDevice(
            id: fb.DeviceIdentifier(descriptor.deviceGuid),
            name: descriptor.name);

  String get id {
    return device.id.id;
  }

  Timer _connectTimeout;
  bool _shouldReconnect = true;

  void connect() {
    if (connection != null) {
      connection.cancel();
    }
    connection =
        flutterBlue.connect(device).listen((fb.BluetoothDeviceState state) {
      switch (state) {
        case fb.BluetoothDeviceState.connected:
          _connectTimeout.cancel();
          _connectTimeout = null;
          _connected();
          break;
        case fb.BluetoothDeviceState.connecting:
          _connectTimeout.cancel();
          _connecting();
          break;
        case fb.BluetoothDeviceState.disconnected:
          _disconnected();
          break;
        default:
          return;
      }
    });
    _connectTimeout = Timer(Duration(seconds: 5), reconnect);
  }

  void servicesAvailable(List<fb.BluetoothService> services);
  void onDisconnect();

  void reconnect() {
    print('Reconnecting to ${device.name}...');
    if (_shouldReconnect) {
      connect();
    }
  }

  void _connecting() {
    print("Connecting to ${device.name}");
  }

  void _connected() {
    print("Connected to ${device.name}");
    device.discoverServices().then(servicesAvailable);
    scheduleReconnect();
  }

  void disconnect() {
    _shouldReconnect = false;
    if (_connectTimeout != null) {
      _connectTimeout.cancel();
    }
    onDisconnect();
    if (connection != null) {
      connection.cancel();
    }
  }

  void scheduleReconnect() {
    if (!_shouldReconnect) {
      return;
    }

    if (_connectTimeout != null) {
      _connectTimeout.cancel();
    }
    _connectTimeout = Timer(Duration(seconds: 5), reconnect);
  }

  void valueReceived() {
    scheduleReconnect();
  }

  void _disconnected() {
    print("Disconnected from ${device.name}");
    onDisconnect();
    connection.cancel();
    connection = null;
    if (_shouldReconnect) {
      reconnect();
    }
  }
}
