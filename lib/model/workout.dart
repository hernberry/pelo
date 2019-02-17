import 'package:json_annotation/json_annotation.dart';
import 'services/peloton/types.dart';

part 'workout.g.dart';

@JsonSerializable()
// TODO - this should really be called CompletedWorkout
class Workout {
  final String localId;
  int stravaId;
  final String name;
  final String tcxFilePath;
  final Duration duration;
  final DateTime time;
  final Playlist playlist;

  Workout(
    this.name, this.tcxFilePath, this.localId, this.duration, this.time, {this.stravaId, this.playlist});

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}

@JsonSerializable()
class Playlist {
  List<RideInfo> rides;

  Playlist(this.rides);
  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistToJson(this);
}

class WorkoutPlan {
  String id;
  String name;
  Playlist playlist;

  WorkoutPlan(this.id, this.name, this.playlist);
}