import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../model/services/strava/client.dart';
import '../model/services/strava/account.dart';

abstract class OAuthListener {
  // Called when Authorization is complete. The resulting
  // clients can be used to make requests for protected
  // resources.
  void onAuthComplete(StravaClient client);
}

class StravaOAuthFlow {
  static const String client_id = "3484";
  static const String client_secret =
      "62cf9087f17b21ac29579c7f620cf1bd0c6ea085";
  static const String authorizationEndpoint =
      "https://www.strava.com/oauth/mobile/authorize";
  static const String tokenEndpoint = "https://www.strava.com/oauth/token";
  static const String redirectUrl = "https://hernberry.com/oauth";
  static const List<String> scopes = [
    "read,activity:read_all,activity:write,profile:read_all"
  ];

  final OAuthListener listener;

  oauth2.AuthorizationCodeGrant _grant;

  StravaOAuthFlow(this.listener);

  bool _isOAuthCallback(Uri uri) {
    // Our OAuth2 Redirect is https://hernberry.com/oauth
    if (!uri.host.contains('hernberry') || !uri.path.startsWith("/oauth")) {
      return false;
    }
    return true;
  }

  void _onOAuthSuccess(oauth2.Client client) async {
    listener.onAuthComplete(StravaClient(client));
  }

  void _handleLinkChange(String link) {
    Uri uri = Uri.parse(link);
    if (_isOAuthCallback(uri)) {
      FlutterWebviewPlugin().close();
      _grant
          .handleAuthorizationResponse(uri.queryParameters)
          .then(_onOAuthSuccess);
    }
  }

  static Future<StravaClient> fromStoredCredentials(String storedCredentials) async {
    oauth2.Client client = oauth2.Client(
      oauth2.Credentials.fromJson(storedCredentials), identifier: client_id, secret: client_secret);
    client = await client.refreshCredentials();
    return Future.value(StravaClient(client));
  }

  Future<void> authorize() async {
    this._grant = new oauth2.AuthorizationCodeGrant(
        client_id, Uri.parse(authorizationEndpoint), Uri.parse(tokenEndpoint),
        basicAuth: false, secret: client_secret);
    final flutterWebviewPlugin = FlutterWebviewPlugin();

    String url = _grant
        .getAuthorizationUrl(Uri.parse(redirectUrl), scopes: scopes)
        .toString();

    flutterWebviewPlugin.onUrlChanged.listen(_handleLinkChange);
    flutterWebviewPlugin.launch(url);
  }
}
