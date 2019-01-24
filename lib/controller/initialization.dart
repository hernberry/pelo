import 'package:shared_preferences/shared_preferences.dart';
import '../model/pelo.dart';
import '../model/services/strava/client.dart';
import '../model/services/strava/account.dart';
import 'oauth.dart';

class InitController {

  Future<PeloModel> createModel() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    PeloModel model = PeloModel(preferences);
    String stravaCreds = preferences.get(PeloModel.STRAVA_CREDS_KEY);
    if (stravaCreds != null) {
      StravaClient stravaClient = await StravaOAuthFlow.fromStoredCredentials(stravaCreds);
      StravaAccount stravaAccount = await stravaClient.getStravaAccount();
      model.setStravaClient(stravaClient);
      model.setStravaAccount(stravaAccount);
    }

    return Future.value(model);
  }
}