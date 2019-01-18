import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../scoped-model/pelo.dart';

class PeloDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PeloModel model = ScopedModel.of<PeloModel>(context, rebuildOnChange: true);

    return Drawer(
        child: Column(children: <Widget>[
      AppBar(
        title: Row(children: [
          CircleAvatar(
              backgroundImage: AssetImage('assets/dog.jpg')),
            //      NetworkImage(model.stravaAccount.profilePicture)),
          Text('Settings')
        ]),
        automaticallyImplyLeading: false,
      ),
      ListTile(
          leading: Icon(Icons.edit),
          title: Text('Manage Sensors'),
          onTap: () {
            Navigator.pushNamed(context, '/sensor_config');
          }),
      ListTile(
          leading: Icon(Icons.edit),
          title: Text('Workout'),
          onTap: () {
            Navigator.pushNamed(context, '/workout');
          })
    ]));
  }
}
