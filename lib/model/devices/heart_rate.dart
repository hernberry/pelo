import 'dart:core';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import './bluetooth.dart';
import './bluetooth_device_descriptor.dart';

enum SensorContact { not_supported, contact_not_detected, contact_detected }

class HeartRateReading {
  SensorContact contact;
  int hearRateBpm;
  int totalEnergyExpended;

  HeartRateReading({this.contact, this.hearRateBpm, this.totalEnergyExpended});
}

class HearRateMonitor extends BluetoothDevice {
  static final fb.Guid heartRateServiceId =
      fb.Guid("0000180d-0000-1000-8000-00805f9b34fb");
  static final fb.Guid heartRateMeasureCharacteristic =
      fb.Guid("00002a37-0000-1000-8000-00805f9b34fb");

  static const int HEART_RATE_VALUE_FORMAT_MASK = 0x01;
  // The Second and Third bits make up the contact status mask.
  static const int SENSOR_CONTACT_STATUS_MASK = 0x06;

  // The fourthe bit is the energey expended bit
  static const int ENERT_EXPENDED_PRESENT_MASK = 0x08;

  fb.BluetoothCharacteristic _characteristic;
  Function(HeartRateReading) heartRateReading;

  HearRateMonitor(fb.BluetoothDevice device) : super(device);
  HearRateMonitor.fromDescriptor(BluetoothDeviceDescriptor descriptor)
      : super.fromDescriptor(descriptor);

  void subscribe(Function(HeartRateReading) heartRateReading) {
    this.heartRateReading = heartRateReading;
  }

  SensorContact getSensorContact(int flags) {
    int sensorContact = (flags & SENSOR_CONTACT_STATUS_MASK) >> 1;
    switch (sensorContact) {
     case 2:
        return SensorContact.contact_not_detected;
      case 3:
        return SensorContact.contact_detected;
     case 0:
     case 1:
     default:
        return SensorContact.not_supported;
      }
  }

  int getEnergyExpended(List<int> byteValues) {
    if (byteValues[0] & ENERT_EXPENDED_PRESENT_MASK == 0) {
      // This device does not support energy expended.
      return -1;
    }
    int index = 2;
    if (byteValues[0] & HEART_RATE_VALUE_FORMAT_MASK == 1) {
      // THis means the heary rate measurement takes up two bytes.
      index = 3;
    }
    int energy = (byteValues[index] << 8) + byteValues[index + 1];
    return energy;
  }

  void _valueChanged(List<int> values) {
    super.valueReceived();
    int flags = values[0];
    int heartRate = values[1];
    SensorContact contact = getSensorContact(flags);
    int energy = getEnergyExpended(values);
    if (heartRateReading == null) {
      return;
    }
    heartRateReading(HeartRateReading(contact: contact, totalEnergyExpended: energy, hearRateBpm: heartRate));
  }

  void servicesAvailable(List<fb.BluetoothService> services) {
    for (fb.BluetoothService service in services) {
      print(service);
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

  void onDisconnect() {
    device.setNotifyValue(_characteristic, false);
  }
}
