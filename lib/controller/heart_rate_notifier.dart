import 'package:flutter/material.dart';

class HeartRateChangeNotifier extends ChangeNotifier {

   int _currentHeartRate;
   int get currentHeartRate => _currentHeartRate;

   int _currentHearRateZone;
   int get currentHeartRateZone => _currentHearRateZone;

   void update(int heartRate, int zone) {
     _currentHeartRate = heartRate;
     _currentHearRateZone = zone;
     notifyListeners();
   }
}