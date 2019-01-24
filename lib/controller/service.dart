import 'package:flutter/material.dart';

import '../model/pelo.dart';
import '../model/services/strava/account.dart';
import '../model/services/strava/client.dart';
import 'oauth.dart';

class ServiceController extends ChangeNotifier with OAuthListener {
  final PeloModel model;
  StravaOAuthFlow stravaOAuthFlow;

  ServiceController(this.model) {
    stravaOAuthFlow = StravaOAuthFlow(this);
  }

  bool get isStravaConnected {
    return model.isStravaAuthenticated;
  }

  bool get isPelotonConnected {
    return false;
  }

  StravaAccount get stravaAccount {
    return model.stravaAccount;
  }

  @override
  void onAuthComplete(StravaClient client) async {
    model.setStravaClient(client);
    var stravaAccount = await client.getStravaAccount();
    model.setStravaAccount(stravaAccount);
    notifyListeners();
  }

  void connectToStrava() async {
    stravaOAuthFlow.authorize();
  }

  void disconnectFromStrava() async {
    model.disconnectStrava().then((arg) => notifyListeners());
  }
}
