import 'package:json_annotation/json_annotation.dart';

part 'types.g.dart';

@JsonSerializable()
class PelotonCredentials {
  String userNameOrEmailAddress;
  String password;

  PelotonCredentials(this.userNameOrEmailAddress, this.password);

  factory PelotonCredentials.fromJson(Map<String, dynamic> json) =>
      _$PelotonCredentialsFromJson(json);
  Map<String, dynamic> toJson() => _$PelotonCredentialsToJson(this);
}

@JsonSerializable()
class PelotonRide {
  String id;
  String title;

  @JsonKey(name: "image_url")
  String imageUrl;

  @JsonKey(name: "instructor_id")
  String instructorId;

  @JsonKey(name: 'vod_stream_url')
  String streamUrl;

  @JsonKey(name: 'length')
  int totalDuration;

  @JsonKey(name: 'pedaling_end_offset')
  int pedalingDuration;

  @JsonKey(name: "class_type_ids")
  List<String> classTypeIds;

  @JsonKey(name: "fitness_discipline")
  String fitnessDiscipline;

  PelotonRide(
      {this.id,
      this.title,
      this.imageUrl,
      this.instructorId,
      this.streamUrl,
      this.totalDuration,
      this.pedalingDuration,
      this.classTypeIds,
      this.fitnessDiscipline});
  factory PelotonRide.fromJson(Map<String, dynamic> json) =>
      _$PelotonRideFromJson(json);
  Map<String, dynamic> toJson() => _$PelotonRideToJson(this);
}

@JsonSerializable()
class PelotonInstructor {
  String name;

  @JsonKey(name: "image_url")
  String imageUrl;

  String id;

  PelotonInstructor();

  factory PelotonInstructor.fromJson(Map<String, dynamic> json) =>
      _$PelotonInstructorFromJson(json);
  Map<String, dynamic> toJson() => _$PelotonInstructorToJson(this);
}

@JsonSerializable()
class PelotonClassType {
  String id;
  String name;

  PelotonClassType();
  factory PelotonClassType.fromJson(Map<String, dynamic> json) =>
      _$PelotonClassTypeFromJson(json);
  Map<String, dynamic> toJson() => _$PelotonClassTypeToJson(this);
}

@JsonSerializable()
class PelotonPage {
  int count;
  int page;
  int limit;

  PelotonPage();

  @JsonKey(name: "page_count")
  int pageCount;

  List<PelotonInstructor> instructors;

  @JsonKey(name: "class_types")
  List<PelotonClassType> classTypes;

  @JsonKey(name: "data")
  List<PelotonRide> rides;

  factory PelotonPage.fromJson(Map<String, dynamic> json) =>
      _$PelotonPageFromJson(json);
  Map<String, dynamic> toJson() => _$PelotonPageToJson(this);
}

@JsonSerializable()
class RideInfo {
  final PelotonInstructor instructor;
  final PelotonRide ride;
  final PelotonClassType classType;

  RideInfo({this.instructor, this.ride, this.classType});

  factory RideInfo.fromJson(Map<String, dynamic> json) =>
      _$RideInfoFromJson(json);
  Map<String, dynamic> toJson() => _$RideInfoToJson(this);}
