import 'package:json_annotation/json_annotation.dart';

part 'workout.g.dart';

@JsonSerializable()
class Workout {
  final String localId;
  int stravaId;
  final String name;
  final String tcxFilePath;
  final Duration duration;
  final DateTime time;

  Workout(
    this.name, this.tcxFilePath, this.localId, this.duration, this.time, {this.stravaId});

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}