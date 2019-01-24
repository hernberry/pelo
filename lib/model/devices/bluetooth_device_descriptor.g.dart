// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluetooth_device_descriptor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BluetoothDeviceDescriptor _$BluetoothDeviceDescriptorFromJson(
    Map<String, dynamic> json) {
  return BluetoothDeviceDescriptor(
      json['deviceGuid'] as String,
      json['name'] as String,
      _$enumDecodeNullable(_$DeviceTypeEnumMap, json['deviceType']));
}

Map<String, dynamic> _$BluetoothDeviceDescriptorToJson(
        BluetoothDeviceDescriptor instance) =>
    <String, dynamic>{
      'deviceGuid': instance.deviceGuid,
      'name': instance.name,
      'deviceType': _$DeviceTypeEnumMap[instance.deviceType]
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$DeviceTypeEnumMap = <DeviceType, dynamic>{
  DeviceType.cadence: 'cadence',
  DeviceType.heartRate: 'heartRate'
};
