import 'dart:convert';
import 'package:http/http.dart' as http;

import './types.dart'; 

class PelotonClient {
  static const String apiAuthority = "api.pelotoncycle.com";

  String _sessionId;

  PelotonClient();
  PelotonClient.withSession(this._sessionId);

  bool get isAuthenticated {
    return _sessionId != null;
  }

  String get sessionId {
    return _sessionId;
  }

  Future<void> authenticate(PelotonCredentials credentials) async {
    Uri authUri = Uri.https(apiAuthority, 'auth/login');
    http.Response response = await http.post(authUri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: jsonEncode({
          'username_or_email': credentials.userNameOrEmailAddress,
          'password': credentials.password,
        }));

    _sessionId = jsonDecode(response.body)['session_id'];
  }

  // Extra params:
  //class_type_id=
  Future<PelotonPage> getRides(int page, String category,
      {Duration length, String classId}) async {
    var queryParams = {
      'context_format': 'audio,video',
      'limit': '18',
      'page': '$page',
      'browse_category': category,
      'desc': 'true',
      'sort_by': 'original_air_time',
    };
    if (length != null) {
      queryParams['duration'] = '${length.inSeconds}';
    }
    if (classId != null) {
      queryParams['class_type_id'] = classId;
    }

    Uri browseUri =
        Uri.https(apiAuthority, 'api/v2/ride/archived', queryParams);
    http.Response response = await http.get(browseUri, headers: {
      'Cookie': 'peloton_session_id=$_sessionId',
      'peloton-platform': 'web'
    });

    return PelotonPage.fromJson(jsonDecode(response.body));
  }

  Future<String> getStreamToken() async {
    Uri streamUri = Uri.https(apiAuthority, 'api/subscription/stream');

    http.Response response = await http.post(streamUri, headers: {
      'Cookie': 'peloton_session_id=$_sessionId',
      'peloton-platform': 'web'
    });
    return jsonDecode(response.body)['token'];
  }

  Future<String> getRideVideoUrl(PelotonRide ride) async {
    String token = await getStreamToken();
    String encodedToken = Uri.encodeComponent(token);
    String url = ride.streamUrl + "?hdnea=$encodedToken";
    return url;
  }
}
