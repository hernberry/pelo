import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../model/services/peloton/types.dart';
import '../model/workout.dart';
import '../model/pelo.dart';

class NewWorkoutController extends ChangeNotifier {

  TextEditingController _nameController = new TextEditingController();
  final PeloModel model;

  NewWorkoutController(this.model);

  List<RideInfo> _selectedRides = [];
  List<RideInfo> get selectedRides => _selectedRides;
  TextEditingController get nameController => _nameController;

  void initialize() {
    _nameController.text = DateTime.now().toString();
  }

  void addRide(ri) {
    _selectedRides.add(ri);
    notifyListeners();
  }

  void removeRide(ri) {
    _selectedRides.remove(ri);
    notifyListeners();
  }

  String createWorkout() {
    String planId = Uuid().v4();
    model.setPlan(WorkoutPlan(planId, _nameController.text,
        Playlist(_selectedRides)));
    return planId;    
  }
}
