import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import './bluetooth.dart';
import './heart_rate.dart';
import './cadence.dart';

abstract class BluetoothScanListener {
  void onDeviceDiscovered(BluetoothDevice device);

  void onScanStopped();

  void onScanStart();
}

class BluetoothScanner {
  static final String heartRateServiceId = "0000180d-0000-1000-8000-00805f9b34fb";
  static final String cyclingCadenceServiceId = "00001816-0000-1000-8000-00805f9b34fb";

  final BluetoothScanListener listener;
  final fb.FlutterBlue flutterBlue = fb.FlutterBlue.instance;
  Timer timer;
  final List<String> knownDevices = [];
  final Map<String, dynamic> connections = {};

  StreamSubscription<fb.ScanResult> scanStream;

  BluetoothScanner(this.listener);

  void startScanning() {
    scanStream = flutterBlue
        .scan(timeout: Duration(seconds: 10))
        .listen((fb.ScanResult sr) {
      String deviceId = sr.device.id.id;
      if (knownDevices.contains(deviceId)) {
        return;
      }
      knownDevices.add(sr.device.id.id);
      for (String serviceId in sr.advertisementData.serviceUuids) {
        if (serviceId == heartRateServiceId) {
          listener.onDeviceDiscovered(HearRateMonitor(sr.device));
        } else if (serviceId == cyclingCadenceServiceId) {
          listener.onDeviceDiscovered(CadenceMonitor(sr.device));
        }
      }
    });
    listener.onScanStart();
    timer = Timer(Duration(seconds: 10), _stopScanning);
  }

  void stopScanning() {
    scanStream.cancel();
    scanStream = null;
    timer.cancel();
    timer = null;
    listener.onScanStopped();
  }

  void _stopScanning() {
    listener.onScanStopped();
  }
}
