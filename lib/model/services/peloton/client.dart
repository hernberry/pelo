import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'client.g.dart';

@JsonSerializable()
class PelotonCredentials {
  String userNameOrEmailAddress;
  String password;

  PelotonCredentials(this.userNameOrEmailAddress, this.password);

  factory PelotonCredentials.fromJson(Map<String, dynamic> json) =>
      _$PelotonCredentialsFromJson(json);
  Map<String, dynamic> toJson() => _$PelotonCredentialsToJson(this);
}

@JsonSerializable()
class PelotonRide {
  String id;
  String title;

  @JsonKey(name: "image_url")
  String imageUrl;

  @JsonKey(name: "instructor_id")
  String instructorId;

  @JsonKey(name: 'vod_stream_url')
  String streamUrl;

  int duration;

  @JsonKey(name: "class_type_ids")
  List<String> classTypeIds;

  PelotonRide();
  factory PelotonRide.fromJson(Map<String, dynamic> json) =>
      _$PelotonRideFromJson(json);
  Map<String, dynamic> toJson() => _$PelotonRideToJson(this);
}

@JsonSerializable()
class PelotonInstructor {
  String name;

  String imageUrl;

  PelotonInstructor();

  factory PelotonInstructor.fromJson(Map<String, dynamic> json) =>
      _$PelotonInstructorFromJson(json);
  Map<String, dynamic> toJson() => _$PelotonInstructorToJson(this);
}

@JsonSerializable()
class PelotonClassType {
  String typeId;
  String name;

  PelotonClassType();
  factory PelotonClassType.fromJson(Map<String, dynamic> json) =>
      _$PelotonClassTypeFromJson(json);
  Map<String, dynamic> toJson() => _$PelotonClassTypeToJson(this);
}

@JsonSerializable()
class PelotonPage {
  int count;
  int page;
  int limit;

  PelotonPage();

  @JsonKey(name: "page_count")
  int pageCount;

  List<PelotonInstructor> instructors;

  @JsonKey(name: "class_types")
  List<PelotonClassType> classTypes;

  @JsonKey(name: "data")
  List<PelotonRide> rides;

  factory PelotonPage.fromJson(Map<String, dynamic> json) =>
      _$PelotonPageFromJson(json);
  Map<String, dynamic> toJson() => _$PelotonPageToJson(this);
}

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
  Future<PelotonPage> getRides({int page = 0}) async {
    Uri browseUri = Uri.https(apiAuthority, 'api/v2/ride/archived', {
      'browse_category': 'cycling',
      'context_format': 'audio,video',
      'limit': '18',
      'page': '$page',
      'sort_by': 'original_air_time',
      'desc': 'true',
    });
    http.Response response = await http.get(browseUri, headers: {
      'Cookie': 'peloton_session_id=$_sessionId',
      'peloton-platform': 'web'
    });

    return PelotonPage.fromJson(jsonDecode(response.body));
  }

  Future<String> getStreamToken() async {
    Uri streamUri = Uri.https(
      apiAuthority, 'api/subscription/stream');

    http.Response response = await http.get(streamUri, headers: {
      'Cookie': 'peloton_session_id=$_sessionId',
      'peloton-platform': 'web'
    });
    return jsonDecode(response.body)['token'];
  }

  Future<String> getRideVideoUrl(PelotonRide ride) async {
    String token = await getStreamToken();
    String encodedToken = Uri.encodeComponent(token);
    return ride.streamUrl + "?hdnea=$encodedToken";
  }
}
