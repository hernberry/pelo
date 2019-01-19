import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-model/pelo.dart';
import '../widgets/ui_elements/drawer.dart';
import '../model/devices/scanner.dart';
import '../model/devices/bluetooth.dart';
import '../model/devices/heart_rate.dart';
import '../model/devices/cadence.dart';
import '../widgets/devices/heart_rate_list_element.dart';
import '../widgets/devices/cadence_list_element.dart';

class SensorConfigPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _SensorConfigState();
  }
}

enum ScanningState { scanning, notScanning }

class _SensorConfigState extends State<SensorConfigPage>
    with BluetoothScanListener {
  ScanningState scanningState = ScanningState.notScanning;
  List<BluetoothDevice> devices = [];
  BluetoothScanner scanner;

  bool _isDeactivated = false;

  @override
  void initState() {
    super.initState();
    scanner = BluetoothScanner(this);
    _performScan();
  }

  @override
  void dispose() {
    super.dispose();
    scanner.stopScanning();
    scanner = null;
    _isDisposed = true;
  }

  @override
  void onScanStart() {
    if (_isDisposed) {
      return;
    }
    setState(() {
      scanningState = ScanningState.scanning;
    });
  }

  void _performScan() {
    scanner.startScanning();
  }

  @override
  void onScanStopped() {
    if (_isDisposed) {
      return;
    }
    setState(() {
      scanningState = ScanningState.notScanning;
    });
  }

  @override
  void onDeviceDiscovered(BluetoothDevice device) {
    if (_isDisposed) {
      return;
    }
    setState(() {
      devices.add(device);
    });
  }

  Widget _getScanningStateWidget() {
    if (scanningState == ScanningState.scanning) {
      return Container(
          height: 30.0,
          child: Row(
            children: <Widget>[
              Text('Available Devices'),
              CircularProgressIndicator(),
            ],
          ));
    }
    return Container(
        height: 30.0,
        child: Row(children: <Widget>[
          Text('Available Devices'),
          RaisedButton(child: Text('Scan Again'), onPressed: _performScan),
        ]));
  }

  Widget _getDeviceWidget(
      BluetoothDevice device, bool isRegistered, Function registerClicked) {
    if (device is HearRateMonitor) {
      return HeartRateMonitorListElement(device, isRegistered, registerClicked);
    } else if (device is CadenceMonitor) {
      return CadenceListElement(device, isRegistered, registerClicked);
    }
    return null;
  }

  Widget _getScopedDeviceWidget(BluetoothDevice device) {
    return ScopedModelDescendant<PeloModel>(
        rebuildOnChange: true,
        builder: (BuildContext context, Widget child, PeloModel model) {
          return _getDeviceWidget(device, model.isConnected(device.id), () {
            if (model.isConnected(device.id)) {
              model.disconnect(device.id);
              return false;
            } else {
              model.connect(device.id, device.runtimeType);
              return true;
            }
          });
        });
  }

  Widget _getDevicesWidget() {
    if (devices.length == 0) {
      return Expanded(child: Text("No Devices Found"));
    }

    return Expanded(
        child: Column(children: devices.map(_getScopedDeviceWidget).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Pelo"),
        ),
        body: Container(
            child: Column(children: <Widget>[
          _getScanningStateWidget(),
          _getDevicesWidget(),
        ])));
  }
}
