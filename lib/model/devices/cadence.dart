import 'dart:core';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import './bluetooth.dart';
import './bluetooth_device_descriptor.dart';

class CadenceMonitor extends BluetoothDevice {
  static final fb.Guid cyclingCadenceServiceId =
      fb.Guid("00001816-0000-1000-8000-00805f9b34fb");
  static final fb.Guid cyclingCadenceCharacteristicId =
      fb.Guid("00002a5b-0000-1000-8000-00805f9b34fb");

  fb.BluetoothCharacteristic _characteristic;
  Function cadenceReading;

  CadenceMonitor(fb.BluetoothDevice device) : super(device);

  CadenceMonitor.fromDescriptor(BluetoothDeviceDescriptor descriptor)
      : super.fromDescriptor(descriptor);

  double lastCrankTimeSeconds = 0;
  int lastTotalCranks = 0;

  void subscribe(Function cadenceReading) {
    this.cadenceReading = cadenceReading;
  }

  void _valueChanged(List<int> values) {
    super.valueReceived();
    int newTotalCranks = (values[2] << 8) + values[1];
    print(values);
    // Time is recorded in 1/1024s.
    double newCrankTimeSeconds = (((values[4] << 8) + values[3]) / 1024.0);

    if (newCrankTimeSeconds * newTotalCranks == 0) {
      return;
    }

    int elapsedCranks = newTotalCranks - lastTotalCranks;
    if (newTotalCranks < lastTotalCranks) {
      elapsedCranks = (65536 - lastTotalCranks) + newTotalCranks;
    }

    double elapsedSeconds = newCrankTimeSeconds - lastCrankTimeSeconds;
    if (newCrankTimeSeconds < lastCrankTimeSeconds) {
      elapsedSeconds = 64 - lastCrankTimeSeconds + newCrankTimeSeconds;
    }

    lastCrankTimeSeconds = newCrankTimeSeconds;
    lastTotalCranks = newTotalCranks;

    String allValues = values.toString();
    print(allValues);
    if (elapsedSeconds == 0) {
      return;
    }
    double cadenceEstimate = 60.0 * (elapsedCranks / elapsedSeconds);

    cadenceReading(cadenceEstimate.round());
  }

  void servicesAvailable(List<fb.BluetoothService> services) {
    for (fb.BluetoothService service in services) {
      if (service.uuid == cyclingCadenceServiceId) {
        for (fb.BluetoothCharacteristic c in service.characteristics) {
          if (c.uuid == cyclingCadenceCharacteristicId) {
            _characteristic = c;
            device.setNotifyValue(_characteristic, true);
            device.onValueChanged(_characteristic).listen(_valueChanged);
            return;
          }
        }
      }
    }
    print("Hmmmm didn't find a cadence service here. WTF?");
  }

  void onDisconnect() {
    if (device != null) {
      device.setNotifyValue(_characteristic, false);
    }
  }
}
