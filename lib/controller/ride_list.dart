import 'dart:math';
import 'dart:core';
import 'package:flutter/material.dart';
import '../model/services/peloton/client.dart';
import '../model/services/peloton/types.dart';

class ClassType {
  final String _classTypeId;
  final String _classTypeName;
  final Category _supportedCategory;

  const ClassType._internal(
      this._classTypeId, this._classTypeName, this._supportedCategory);
  toString() => "$classTypeName";

  String get classTypeId {
    return _classTypeId;
  }

  String get classTypeName {
    return _classTypeName;
  }

  static const POWER_ZONE = ClassType._internal(
      "665395ff3abf4081bf315686227d1a51", "Power Zone", Category.CYCLING);
  static const HEART_RATE_ZONE = ClassType._internal(
      "59a49f882ea9475faa3110d50a8fb3f3", "Low Impact", Category.CYCLING);
  static const INTERVALS = ClassType._internal(
      "7579b9edbdf9464fa19eb58193897a73", "Intervals", Category.CYCLING);
  static const LOW_IMPACT = ClassType._internal(
      "8c34b36dba084e22b91426621759230d", "Heart Rate Zone", Category.CYCLING);
  static const ALL_CYCLING =
      ClassType._internal(null, "All Cycling", Category.CYCLING);

  static const POST_RIDE_STRETCH = ClassType._internal(
      "736e33ce009b425e81f276cfaf42b5d3", "Post-ride", Category.STRETCHING);
  static const ALL_STRETCHING =
      ClassType._internal(null, "All Stretching", Category.STRETCHING);

  static const ALL_TYPES = [
    POWER_ZONE,
    HEART_RATE_ZONE,
    INTERVALS,
    LOW_IMPACT,
    ALL_CYCLING,
    POST_RIDE_STRETCH,
    ALL_STRETCHING
  ];
}

class Category {
  final String _name;
  String get name {
    return _name;
  }

  final String _id;
  String get id {
    return _id;
  }

  toString() => _name;

  const Category._internal(this._id, this._name);

  static const Category STRETCHING =
      Category._internal("stretching", "Stretching");
  static const Category CYCLING = Category._internal("cycling", "Cycling");

  static const List<Category> ALL = [STRETCHING, CYCLING];
}

class ClassLength {
  final Duration _duration;
  final String _durationDisplay;

  Duration get duration {
    return _duration;
  }

  String get display {
    return _durationDisplay;
  }

  toString() => _durationDisplay != null
      ? _durationDisplay
      : "${_duration.inMinutes} Minutes";

  const ClassLength._withDuration(this._duration) : _durationDisplay = null;

  const ClassLength._fromString(this._durationDisplay) : _duration = null;

  static const ClassLength ANY = ClassLength._fromString("Any");
  static const ClassLength FIVE_MINUTES =
      ClassLength._withDuration(Duration(minutes: 5));
  static const ClassLength TEN_MINUTES =
      ClassLength._withDuration(Duration(minutes: 10));
  static const ClassLength FIFTEEN_MINUTES =
      ClassLength._withDuration(Duration(minutes: 15));
  static const ClassLength TWENTY_MINUTES =
      ClassLength._withDuration(Duration(minutes: 20));
  static const ClassLength THIRTY_MINUTES =
      ClassLength._withDuration(Duration(minutes: 30));
  static const ClassLength FOURTYFIVE_MINUTES =
      ClassLength._withDuration(Duration(minutes: 45));
  static const ClassLength SIXTY_MINUTES =
      ClassLength._withDuration(Duration(minutes: 60));
  static const ClassLength NINETY_MINUTES =
      ClassLength._withDuration(Duration(minutes: 90));

  static const List<ClassLength> ALL = [
    ANY,
    FIVE_MINUTES,
    TEN_MINUTES,
    FIFTEEN_MINUTES,
    TWENTY_MINUTES,
    THIRTY_MINUTES,
    FOURTYFIVE_MINUTES,
    SIXTY_MINUTES,
    NINETY_MINUTES,
  ];
}

class RideListController extends ChangeNotifier {
  final PelotonClient _pelotonClient;

  ScrollController _scrollController;
  bool _isLoading = false;

  ClassType classTypeFilter;
  Category classCategoryFilter;
  ClassLength classLengthFilter;

  List<ClassType> _supportedClassTypes;

  List<ClassType> get supportedClassTypes {
    return _supportedClassTypes;
  }

  ScrollController get scrollController {
    return _scrollController;
  }

  bool get isLoading {
    return _isLoading;
  }

  RideListController(this._pelotonClient);

  Map<int, List<RideInfo>> _ridesByPage = {};

  List<RideInfo> _rides = [];

  List<RideInfo> get rides {
    return _rides;
  }

  void initialize() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    classTypeFilter = ClassType.ALL_CYCLING;
    classCategoryFilter = Category.CYCLING;
    classLengthFilter = ClassLength.ANY;

    _supportedClassTypes = ClassType.ALL_TYPES
        .where((t) => t._supportedCategory == classCategoryFilter)
        .toList();
    fetchRidesPage();
  }

  void updateCaegoryFilter(Category c) {
    if (classCategoryFilter != c) {
      classCategoryFilter = c;
      _supportedClassTypes = ClassType.ALL_TYPES
          .where((t) => t._supportedCategory == classCategoryFilter)
          .toList();
      classTypeFilter =
          _supportedClassTypes.firstWhere((ct) => ct.classTypeId == null);
      notifyListeners();
    }
  }

  void updateClassTypeFilter(ClassType ctf) {
    if (classTypeFilter != ctf) {
      classTypeFilter = ctf;
      notifyListeners();
    }
  }

  void updateClassLength(ClassLength cl) {
    if (classLengthFilter != cl) {
      classLengthFilter = cl;
      notifyListeners();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchRidesPage();
    }
  }

  int _nextRidePage() {
    if (rides.isEmpty) {
      return 0;
    }
    return _ridesByPage.keys.reduce(max) + 1;
  }

  void refresh() {
    _rides.clear();
    _ridesByPage.clear();
    _isLoading = false;
    fetchRidesPage();
  }

  void fetchRidesPage() {
    if (_isLoading) {
      return;
    }
    int _page = _nextRidePage();
    _pelotonClient
        .getRides(_page, classCategoryFilter._id,
            length: classLengthFilter._duration,
            classId: classTypeFilter._classTypeId)
        .then((PelotonPage page) {
      _ridesByPage[_page] = _createRideInfos(page);
      _isLoading = false;
      _rides = _ridesByPage.values.reduce((x, y) => x + y);
      notifyListeners();
    });
    _isLoading = true;
    notifyListeners();
  }

  List<RideInfo> _createRideInfos(PelotonPage page) {
    Map<String, PelotonInstructor> instructors =
        Map.fromIterable(page.instructors, key: (instructor) => instructor.id);
    Map<String, PelotonClassType> classTypes =
        Map.fromIterable(page.classTypes, key: (classType) => classType.id);

    return page.rides
        .map((ride) => RideInfo(
            instructor: instructors[ride.instructorId],
            classType: classTypes[ride.classTypeIds[0]],
            ride: ride))
        .toList();
  }
}
