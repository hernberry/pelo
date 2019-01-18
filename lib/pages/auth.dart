import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../strava/oauth.dart';
import '../strava/client.dart';
import '../strava/account.dart';
import '../scoped-model/pelo.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

enum AuthState { starting, authNeeded, authorizing }

class _AuthPageState extends State<AuthPage> with OAuthListener {
  AuthState authState = AuthState.starting;
  OAuthFlow oAuthFlow;
  PeloModel model;

  _AuthPageState() {
    oAuthFlow = OAuthFlow(this);
  }

  void onAuthComplete(StravaClient client, StravaAccount account) {
    // Navigate away!
    print('got auth');
    model.setStravaClient(client);
    model.setStravaAccount(account);
    Navigator.pushReplacementNamed(context, '/workout');
  }

  void onAuthorizationNeeded() {
    print('need auth!');
    setState(() => authState = AuthState.authNeeded);
  }

  @override
  void initState() {
    super.initState();
    oAuthFlow.checkExistingAuth();
  }

  void _authorize() {
    setState(() {
      oAuthFlow.authorize();
      authState = AuthState.authorizing;
    });
  }

  Widget _buildLoadingWidget() {
    return new Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Text("Initializing Pelo"),
          CircularProgressIndicator()]),
    );
  }

  Widget _buildAuthorizingWidget() {
    return new Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Text("Connecting to Strava..."),
          CircularProgressIndicator()]),
    );
  }

  Widget _buildAuthNeededDialog() {
    return new Container(
        padding: EdgeInsets.symmetric(
          horizontal: 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/strava_logo_orange.png'),
            RaisedButton(
                child: Text('Connect To Strava'), onPressed: _authorize),
            Text(
                'Pelo uploads your activities to Strava. Connect to Strava to continue.',
                textAlign: TextAlign.center),
          ],
        ));
  }

  Widget _getBody() {
    switch(authState) {
      case AuthState.authNeeded:
          return _buildAuthNeededDialog();
      case AuthState.authorizing:
          return _buildAuthorizingWidget();
      default:
          return _buildLoadingWidget();    
    }
  }

  Widget build(BuildContext context) {
   model = ScopedModel.of<PeloModel>(context, rebuildOnChange: true);
   return Scaffold(
      appBar: AppBar(title: Text('Pelo')),
      body: _getBody(),
    );
  }
}
