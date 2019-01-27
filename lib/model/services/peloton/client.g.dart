// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PelotonCredentials _$PelotonCredentialsFromJson(Map<String, dynamic> json) {
  return PelotonCredentials(
      json['userNameOrEmailAddress'] as String, json['password'] as String);
}

Map<String, dynamic> _$PelotonCredentialsToJson(PelotonCredentials instance) =>
    <String, dynamic>{
      'userNameOrEmailAddress': instance.userNameOrEmailAddress,
      'password': instance.password
    };

PelotonRide _$PelotonRideFromJson(Map<String, dynamic> json) {
  return PelotonRide()
    ..id = json['id'] as String
    ..title = json['title'] as String
    ..imageUrl = json['image_url'] as String
    ..instructorId = json['instructor_id'] as String
    ..streamUrl = json['vod_stream_url'] as String
    ..duration = json['duration'] as int
    ..classTypeIds =
        (json['class_type_ids'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$PelotonRideToJson(PelotonRide instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image_url': instance.imageUrl,
      'instructor_id': instance.instructorId,
      'vod_stream_url': instance.streamUrl,
      'duration': instance.duration,
      'class_type_ids': instance.classTypeIds
    };

PelotonInstructor _$PelotonInstructorFromJson(Map<String, dynamic> json) {
  return PelotonInstructor()
    ..name = json['name'] as String
    ..imageUrl = json['imageUrl'] as String;
}

Map<String, dynamic> _$PelotonInstructorToJson(PelotonInstructor instance) =>
    <String, dynamic>{'name': instance.name, 'imageUrl': instance.imageUrl};

PelotonClassType _$PelotonClassTypeFromJson(Map<String, dynamic> json) {
  return PelotonClassType()
    ..typeId = json['typeId'] as String
    ..name = json['name'] as String;
}

Map<String, dynamic> _$PelotonClassTypeToJson(PelotonClassType instance) =>
    <String, dynamic>{'typeId': instance.typeId, 'name': instance.name};

PelotonPage _$PelotonPageFromJson(Map<String, dynamic> json) {
  return PelotonPage()
    ..count = json['count'] as int
    ..page = json['page'] as int
    ..limit = json['limit'] as int
    ..pageCount = json['page_count'] as int
    ..instructors = (json['instructors'] as List)
        ?.map((e) => e == null
            ? null
            : PelotonInstructor.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..classTypes = (json['class_types'] as List)
        ?.map((e) => e == null
            ? null
            : PelotonClassType.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..rides = (json['data'] as List)
        ?.map((e) =>
            e == null ? null : PelotonRide.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$PelotonPageToJson(PelotonPage instance) =>
    <String, dynamic>{
      'count': instance.count,
      'page': instance.page,
      'limit': instance.limit,
      'page_count': instance.pageCount,
      'instructors': instance.instructors,
      'class_types': instance.classTypes,
      'data': instance.rides
    };
