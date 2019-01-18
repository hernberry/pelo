import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

import './account.dart';

class StravaClient {

  final oauth2.Client oauthClient;

  StravaClient(this.oauthClient);

  Future<StravaAccount> getStravaAccount() async {
    http.Response response = await oauthClient.get('https://www.strava.com/api/v3/athlete');
    Map<String, dynamic> body = convert.jsonDecode(response.body);
    return StravaAccount(
      userName: body['firstname'] + ' ' + body['lastname'],
      profilePicture: body['profile_medium']);
  }
}