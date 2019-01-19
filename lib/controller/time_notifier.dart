import 'package:flutter/material.dart';

class TimeNotifier extends ChangeNotifier {

   Duration _currentElapsedTime;
   Duration get currentElapsedTime => _currentElapsedTime;

   void update(Duration elapsedTime) {
     _currentElapsedTime = elapsedTime;
     notifyListeners();
   }
}