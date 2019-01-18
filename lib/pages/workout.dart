import 'package:flutter/material.dart';

import '../widgets/ui_elements/drawer.dart';

class WorkoutPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        drawer: PeloDrawer(),
        appBar: AppBar(
          title: Text("Pelo"),
        ),
        body: Column(
          children: <Widget>[
            
          ],
        ));
  }
}
