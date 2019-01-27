import 'package:flutter/material.dart';

import '../widgets/peloton_login.dart';
import '../model/services/peloton/client.dart';
import '../controller/service.dart';

class ServiceConfigPage extends StatefulWidget {
  final ServiceController serviceController;

  ServiceConfigPage(this.serviceController);

  @override
  _ServiceConfigPageState createState() =>
      _ServiceConfigPageState(serviceController);
}

class _ServiceConfigPageState extends State<ServiceConfigPage> {
  final ServiceController controller;

  _ServiceConfigPageState(this.controller);

  @override
  void initState() {
    super.initState();
    controller.addListener(_controllerEvent);
  }

  void _controllerEvent() {
    setState(() {});
  }

  Widget _getStravaRow() {
    if (controller.isStravaConnected) {
      var account = controller.stravaAccount;
      return Container(
        child: ListTile(
          leading: ImageIcon(AssetImage("assets/strava_symbol_orange.png")),
          title: Text(account.userName),
          trailing: CircleAvatar(
            backgroundImage: NetworkImage(account.profilePicture),
          ),
          subtitle: FlatButton(
              child: Text("Disconnect"),
              onPressed: controller.disconnectFromStrava),
        ),
      );
    }
    return Container(
      child: ListTile(
        onTap: controller.connectToStrava,
        leading: ImageIcon(AssetImage("assets/strava_symbol_orange.png")),
        title: Text("Connect To Strava"),
      ),
    );
  }

  Widget _getPelotonRow() {
    if (controller.isPelotonConnected) {
      var account = controller.stravaAccount;
      return Container(
          child: ListTile(
        leading: ImageIcon(AssetImage("assets/peloton.png")),
        title: Text(account.userName),
        subtitle: FlatButton(
          child: Text("Disconnect"),
          onPressed: controller.disconnectFromPeloton,
        ),
      ));
    }
    return Container(
      child: ListTile(
        onTap: _connectPeloton,
        leading: ImageIcon(AssetImage("assets/peloton.png")),
        title: Text('Connect To Peloton'),
      ),
    );
  }

  void _connectPeloton() async {
    PelotonCredentials creds = await showDialog<PelotonCredentials>(
        context: context, builder: (context) => PelotonLogin());
    if (creds != null) {
      controller.connectToPeloton(creds);
    }
  }

  Widget _body() {
    if (controller.isAuthInProgress) {
      return Container(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
        height: 300.0,
        child: Column(children: <Widget>[
          _getStravaRow(),
          _getPelotonRow(),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Connect Services"),
        ),
        body: _body());
  }
}
