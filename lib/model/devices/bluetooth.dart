import 'dart:async';
import 'dart:core';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import './bluetooth_device_descriptor.dart';

abstract class BluetoothDevice {
  final fb.BluetoothDevice device;
  final fb.FlutterBlue flutterBlue = fb.FlutterBlue.instance;

  String get name {return device.name;}

  StreamSubscription<fb.BluetoothDeviceState> connection;

  BluetoothDevice(this.device);

  BluetoothDevice.fromDescriptor(BluetoothDeviceDescriptor descriptor) 
     : device = fb.BluetoothDevice(id: fb.DeviceIdentifier(descriptor.deviceGuid), name: descriptor.name);

  String get id {
    return device.id.id;
  }

  void connect() {
    if (connection != null) {
      return;
    }
    connection =
        flutterBlue.connect(device).listen((fb.BluetoothDeviceState state) {
      switch (state) {
        case fb.BluetoothDeviceState.connected:
          _connected();
          break;
        case fb.BluetoothDeviceState.connecting:
          _connecting();
          break;
        case fb.BluetoothDeviceState.disconnected:
          _disconnected();
          break;
        default:
          return;
      }
    });
  }

  void servicesAvailable(List<fb.BluetoothService> services);

  void _connecting() {}

  void _connected() {
    device.discoverServices().then(servicesAvailable);
  }

  void disconnect() {
    connection.cancel();
  }

  void _disconnected() {
    connection = null;
  }
}