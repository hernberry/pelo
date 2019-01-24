import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../model/pelo.dart';
import '../model/devices/bluetooth_device_descriptor.dart';
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

  static const Map<Type, DeviceType> deviceTypes = {
    HearRateMonitor: DeviceType.heartRate,
    CadenceMonitor: DeviceType.cadence
  };

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
  }

  @override
  void deactivate() {
    super.deactivate();
    _isDeactivated = true;
  }

  @override
  void onScanStart() {
    if (_isDeactivated) {
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
    if (_isDeactivated) {
      return;
    }
    setState(() {
      scanningState = ScanningState.notScanning;
    });
  }

  @override
  void onDeviceDiscovered(BluetoothDevice device) {
    if (_isDeactivated) {
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
    // TODO - move all the logic into a controller.
    return ScopedModelDescendant<PeloModel>(
        rebuildOnChange: true,
        builder: (BuildContext context, Widget child, PeloModel model) {
          return _getDeviceWidget(device, model.isDeviceConnected(device.id), () {
            if (model.isDeviceConnected(device.id)) {
              model.disconnectDevice(device.id);
              return false;
            } else {
              model.connectDevice(
                BluetoothDeviceDescriptor(device.id, device.name, deviceTypes[device.runtimeType]));
              return true;
            }
          });
        });
  }

  Widget _getDevicesWidget() {
    if (devices.length == 0) {
      return Expanded(child: Text("No Devices Found"));
    }

    return Container(
        height: 250.0,
        child: Column(children: devices.map(_getScopedDeviceWidget).toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Connect Bluetooth Sensors"),
        ),
        body: Container(
          height: 300.0,
            child: Column(children: <Widget>[
          _getScanningStateWidget(),
          _getDevicesWidget(),
        ])));
  }
}
