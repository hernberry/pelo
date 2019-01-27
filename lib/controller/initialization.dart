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
    
    await SimplePermissions.requestPermission(Permission.AccessCoarseLocation);

    if (stravaCreds != null) {
      StravaClient stravaClient = await StravaOAuthFlow.fromStoredCredentials(stravaCreds);
      StravaAccount stravaAccount = await stravaClient.getStravaAccount();
      model.setStravaClient(stravaClient);
      model.setStravaAccount(stravaAccount);
    }

    return Future.value(model);
  }
}