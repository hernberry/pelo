// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) {
  return Workout(
      json['name'] as String,
      json['tcxFilePath'] as String,
      json['localId'] as String,
      json['duration'] == null
          ? null
          : Duration(microseconds: json['duration'] as int),
      json['time'] == null ? null : DateTime.parse(json['time'] as String),
      stravaId: json['stravaId'] as int,
      playlist: json['playlist'] == null
          ? null
          : Playlist.fromJson(json['playlist'] as Map<String, dynamic>));
}

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'localId': instance.localId,
      'stravaId': instance.stravaId,
      'name': instance.name,
      'tcxFilePath': instance.tcxFilePath,
      'duration': instance.duration?.inMicroseconds,
      'time': instance.time?.toIso8601String(),
      'playlist': instance.playlist
    };

Playlist _$PlaylistFromJson(Map<String, dynamic> json) {
  return Playlist((json['rides'] as List)
      ?.map((e) =>
          e == null ? null : RideInfo.fromJson(e as Map<String, dynamic>))
      ?.toList());
}

Map<String, dynamic> _$PlaylistToJson(Playlist instance) =>
    <String, dynamic>{'rides': instance.rides};
