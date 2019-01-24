import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

import '../../../model/workout.dart';
import './account.dart';

enum UploadState {
  ready,
  processing,
  error,
}

class StravaClient {

  final oauth2.Client oauthClient;
  
  String get credentials => oauthClient.credentials.toJson();

  StravaClient(this.oauthClient);

  static const Map<String, UploadState> UPLOAD_STATE = {
    "Your activity is ready.": UploadState.ready,
    "Your activity is still being processed.": UploadState.processing,
  };

  Map<int, Zone> _extractZones(Map<String, dynamic> zoneData) {
    Map<int, Zone> zones = {};
    List<dynamic> rawZones = zoneData['zones'];
    for (int i = 0; i < rawZones.length; i ++) {
      zones[i + 1] = Zone(rawZones[i]['min'], rawZones[i]['max']);
    }
    return zones;
  }

  Future<http.Response> _get(String url, {int retries = 1}) async {
    http.Response response = await oauthClient.get(url);
    if (response.statusCode == 200 || retries == 0) {
      return Future.value(response);
    }

    // Arbitrarily refresh the access token.
    oauthClient.refreshCredentials();
    _get(url, retries: retries - 1);
  }

  Future<Map<String, dynamic>> uploadWorkout(Workout workout, {int retries=1}) async {
    var uri = Uri.parse("https://www.strava.com/api/v3/uploads");
    var request = new http.MultipartRequest("POST", uri);
    request.fields['name'] = workout.name;
    request.fields['trainer'] = '1';
    request.fields['data_type'] = 'tcx';
    request.fields['activity_type'] = 'ride';
    request.fields['external_id'] = workout.localId;

    String fileAsString = await File(workout.tcxFilePath).readAsString();

    request.files.add(await http.MultipartFile.fromPath('file', workout.tcxFilePath));
    http.StreamedResponse responseStream = await oauthClient.send(request);
    if (responseStream.statusCode <= 299 || retries == 0) {
      return convert.jsonDecode(await responseStream.stream.bytesToString());
    }
    return uploadWorkout(workout, retries: retries -1);
  }

  Future<UploadState> getUploadState(int id) async {
    String url = "https://www.strava.com/api/v3/uploads/$id";
    String response = (await _get(url)).body;

    String status = convert.jsonDecode(response)['status'];
    if (UPLOAD_STATE.containsKey(status)) {
      return UPLOAD_STATE[status];
    }
    return UploadState.error;
  }

  Future<StravaAccount> getStravaAccount() async {
    Future<http.Response> accountInfoFuture = _get('https://www.strava.com/api/v3/athlete');
    Future<http.Response> zonesFuture = _get('https://www.strava.com/api/v3/athlete/zones');

    Map<String, dynamic> account = convert.jsonDecode((await accountInfoFuture).body);
    Map<String, dynamic> zones = convert.jsonDecode((await zonesFuture).body);
    return StravaAccount(
      userName: account['firstname'] + ' ' + account['lastname'],
      profilePicture: account['profile_medium'],
      heartRateZones: _extractZones(zones['heart_rate']));
  }

  Future<String> refreshCredentials() async {
    await oauthClient.refreshCredentials();
    return credentials;
  }
}
