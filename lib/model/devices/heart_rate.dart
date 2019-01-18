import 'dart:core';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import './bluetooth.dart';
import './bluetooth_device_descriptor.dart';

class HearRateMonitor extends BluetoothDevice {
  static final fb.Guid heartRateServiceId =
      fb.Guid("0000180d-0000-1000-8000-00805f9b34fb");
  static final fb.Guid heartRateMeasureCharacteristic =
      fb.Guid("00002a37-0000-1000-8000-00805f9b34fb");

  fb.BluetoothCharacteristic _characteristic;
  Function heartRateReading;
  
  HearRateMonitor(fb.BluetoothDevice device) : super(device);
  HearRateMonitor.fromDescriptor(BluetoothDeviceDescriptor descriptor) : super.fromDescriptor(descriptor);

  void subscribe(Function heartRateReading) {
    this.heartRateReading = heartRateReading;
  }

  void _valueChanged(List<int> values) {
    // HR measurement is the second value. Always preset AFAICT.
    if (heartRateReading == null) {
      return;
    }
    heartRateReading(values[1]);
  }

  void servicesAvailable(List<fb.BluetoothService> services) {
    for (fb.BluetoothService service in services) {
      if (service.uuid == heartRateServiceId) {
        for (fb.BluetoothCharacteristic c in service.characteristics) {
          if (c.uuid == heartRateMeasureCharacteristic) {
            _characteristic = c;
            device.setNotifyValue(_characteristic, true);
            device.onValueChanged(_characteristic).listen(_valueChanged);
            return;
          }
        }
      }
    }
    print("Hmmmm didn't find a heart rate service here. WTF?");
  }
}

