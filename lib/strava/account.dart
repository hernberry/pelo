class Zone {
  final int min;
  final int max;

  Zone(this.min, this.max);
}

class StravaAccount{
  final String profilePicture;
  final String userName;

  final Map<int, Zone> heartRateZones;

  StravaAccount({this.profilePicture, this.userName, this.heartRateZones});
}