import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../model/pelo.dart';

class PeloDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PeloModel model = ScopedModel.of<PeloModel>(context, rebuildOnChange: true);
    String profilePicture = model.isStravaAuthenticated ? model.stravaAccount.profilePicture : 
    'https://cdn2.iconfinder.com/data/icons/cycling/256/bike-fixed-gear-512.png';
    return Drawer(
        child: Column(children: <Widget>[
      AppBar(
        title: Row(children: [
          CircleAvatar(
              backgroundImage: NetworkImage(profilePicture)),
          Text('Settings')
        ]),
      ),
      ListTile(
          leading: Icon(Icons.devices_other),
          title: Text('Manage Sensors'),
          onTap: () {
            Navigator.pushNamed(context, '/sensor_config');
          }),
      ListTile(
          leading: Icon(Icons.cloud_queue),
          title: Text('Manage Services'),
          onTap: () {
            Navigator.pushNamed(context, '/service_config');
          }),
   ]));
  }
}
