import 'dart:io';
import 'package:uni_links/uni_links.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import './client.dart';
import './account.dart';

abstract class OAuthListener {
  // Called when OAuthFlow detects that authorization is needed.
  void onAuthorizationNeeded();

  // Called when Authorization is complete. The resulting
  // clients can be used to make requests for protected
  // resources.
  void onAuthComplete(StravaClient client, StravaAccount account);
}

class OAuthFlow {
  static const String credsFileName = "strava_creds.json";
  static const String client_id = "3484";
  static const String client_secret =
      "62cf9087f17b21ac29579c7f620cf1bd0c6ea085";
  static const String authorizationEndpoint =
      "https://www.strava.com/oauth/mobile/authorize";
  static const String tokenEndpoint = "https://www.strava.com/oauth/token";
  static const String redirectUrl = "https://hernberry.com/oauth";
  static const List<String> scopes = ["read,activity:read_all,activity:write"];

  final OAuthListener listener;

  oauth2.AuthorizationCodeGrant _grant;

  OAuthFlow(this.listener);

  bool _isOAuthCallback(Uri uri) {
    // Our OAuth2 Redirect is https://hernberry.com/oauth
    if (!uri.path.startsWith("/oauth")) {
      print('Got a callback we weren\'t expecting: ' + uri.toString());
      return false;
    }
    return true;
  }

  Future<void> _onOAuthSuccess(oauth2.Client client) async {
    var directory = await getApplicationDocumentsDirectory();
    var credentialsFile =
        File.fromUri(Uri.parse(directory.uri.toString() + "/" + credsFileName));
    credentialsFile.writeAsString(client.credentials.toJson());

    StravaClient stravaClient = StravaClient(client);
    stravaClient.getStravaAccount().then((StravaAccount account) {
      listener.onAuthComplete(stravaClient, account);
    });
  }

  Future<void> _maybeHandleOAuthCallback(String link) async {
    Uri uri = Uri.parse(link);
    if (_isOAuthCallback(uri)) {
      closeWebView();
      _grant
          .handleAuthorizationResponse(uri.queryParameters)
          .then(_onOAuthSuccess);
    }
  }

  Future<void> checkExistingAuth() async {
    var directory = await getApplicationDocumentsDirectory();
    var credentialsFile =
        File.fromUri(Uri.parse(directory.uri.toString() + "/" + credsFileName));

    var exists = await credentialsFile.exists();
    exists = false;
    if (exists) {
      var credentials =
          new oauth2.Credentials.fromJson(await credentialsFile.readAsString());
      _onOAuthSuccess(
        oauth2.Client(credentials, identifier: client_id, secret: client_secret));
    } else {
      listener.onAuthorizationNeeded();
    }
  }

  Future<void> authorize() async {
    print("Starting OAuth flow...");
    getLinksStream().listen((link) {
      _maybeHandleOAuthCallback(link);
    });

    this._grant = new oauth2.AuthorizationCodeGrant(
        client_id, Uri.parse(authorizationEndpoint), Uri.parse(tokenEndpoint),
        basicAuth: false, secret: client_secret);
    launch(_grant
        .getAuthorizationUrl(Uri.parse(redirectUrl), scopes: scopes)
        .toString());
  }
}
