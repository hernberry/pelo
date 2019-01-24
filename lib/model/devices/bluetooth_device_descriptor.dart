
import 'package:json_annotation/json_annotation.dart';

part 'bluetooth_device_descriptor.g.dart';

enum DeviceType {
  cadence,
  heartRate
}

@JsonSerializable()
class BluetoothDeviceDescriptor {

  final String deviceGuid;
  final String name;
  final DeviceType deviceType;

  BluetoothDeviceDescriptor(this.deviceGuid, this.name, this.deviceType);

  factory BluetoothDeviceDescriptor.fromJson(Map<String, dynamic> json) => _$BluetoothDeviceDescriptorFromJson(json);
  Map<String, dynamic> toJson() => _$BluetoothDeviceDescriptorToJson(this);

}