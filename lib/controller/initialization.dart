import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_permissions/simple_permissions.dart';
import '../model/pelo.dart';
import '../model/workout.dart';
import '../model/services/peloton/client.dart';
import '../model/services/strava/client.dart';
import '../model/services/strava/account.dart';
import 'oauth.dart';

class InitController {

  Future<PeloModel> createModel() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    PeloModel model = PeloModel(preferences);
    String stravaCreds = preferences.get(PeloModel.STRAVA_CREDS_KEY);
    String pelotonSessionId = preferences.get(PeloModel.PELOTON_CREDS_KEY);
    
    if (stravaCreds != null) {
      StravaClient stravaClient = await StravaOAuthFlow.fromStoredCredentials(stravaCreds);
      StravaAccount stravaAccount = await stravaClient.getStravaAccount();
      model.setStravaClient(stravaClient);
      model.setStravaAccount(stravaAccount);
    }

    if (pelotonSessionId != null) {
      PelotonClient client = PelotonClient.withSession(pelotonSessionId);
      model.setPelotonClient(client);
      model.updatePelotonCredentials(pelotonSessionId);
    }

    return Future.value(model);
  }
}