import 'package:flutter/material.dart';

class CadenceChangeNotifier extends ChangeNotifier {

   int _currentCadence;
   int get currentCadence => _currentCadence;

   void update(int cadence) {
     _currentCadence = cadence;
     notifyListeners();
   }
}