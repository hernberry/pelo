import 'package:flutter/material.dart';

import '../model/pelo.dart';
import '../model/services/strava/account.dart';
import '../model/services/strava/client.dart';
import '../model/services/peloton/client.dart';
import '../model/services/peloton/types.dart';
import 'oauth.dart';

class ServiceController extends ChangeNotifier with OAuthListener {

  bool _isAuthenticating = false;

  final PeloModel model;
  StravaOAuthFlow stravaOAuthFlow;

  ServiceController(this.model) {
    stravaOAuthFlow = StravaOAuthFlow(this);
  }

  bool get isStravaConnected {
    return model.isStravaAuthenticated;
  }

  bool get isPelotonConnected {
    return model.isPelotonAuthenticated;
  }

  bool get isAuthInProgress {
    return _isAuthenticating;
  }

  StravaAccount get stravaAccount {
    return model.stravaAccount;
  }

  @override
  void onAuthComplete(StravaClient client) async {
    model.setStravaClient(client);
    var stravaAccount = await client.getStravaAccount();
    model.setStravaAccount(stravaAccount);
    _isAuthenticating = false;
    notifyListeners();
  }

  void connectToStrava() async {
    stravaOAuthFlow.authorize();
    _isAuthenticating = true;
    notifyListeners();
  }

  void disconnectFromStrava() async {
    model.disconnectStrava().then((arg) => notifyListeners());
  }

  void connectToPeloton(PelotonCredentials creds) {
    PelotonClient client = PelotonClient();
    client.authenticate(creds).then((arg) {
      model.setPelotonClient(client);
      model.updatePelotonCredentials(client.sessionId);
      _isAuthenticating = false;
      notifyListeners();
    });
    _isAuthenticating = true;
    notifyListeners();
  }

  void disconnectFromPeloton() {
    model.disconnectPeloton().then((v) {notifyListeners();});
  }
}
