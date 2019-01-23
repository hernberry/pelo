
class Workout {
  final String localId;
  String stravaId;
  final String name;
  final String tcxFilePath;

  Workout(this.name, this.tcxFilePath, this.localId, {this.stravaId});
}