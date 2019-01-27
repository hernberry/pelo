import 'package:flutter/material.dart';
import '../model/services/peloton/client.dart';

class RideInfo {
  final PelotonInstructor instructor;
  final PelotonRide ride;
  final PelotonClassType classType;

  RideInfo({this.instructor, this.ride, this.classType});
}

class PlaylistController extends ChangeNotifier {
  final PelotonClient _pelotonClient;

  PlaylistController(this._pelotonClient);

  List<RideInfo> _rides;

  List<RideInfo> get rides {
    return _rides;
  }

  void fetchRides() {
    _rides = null;
    _pelotonClient.getRides().then((PelotonPage page) {
      _rides = _createRideInfos(page);
      notifyListeners();
    });
    notifyListeners();
  }

  List<RideInfo> _createRideInfos(PelotonPage page) {
    Map<String, PelotonInstructor> instructors =
        Map.fromIterable(page.instructors, key: (instructor) => instructor.id);
    Map<String, PelotonClassType> classTypes =
        Map.fromIterable(page.classTypes, key: (classType) => classType.typeId);

    return page.rides
        .map((ride) => RideInfo(
            instructor: instructors[ride.instructorId],
            classType: classTypes[ride.classTypeIds[0]],
            ride: ride))
        .toList();
  }
}
