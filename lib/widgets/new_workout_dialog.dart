import 'package:flutter/material.dart';

class NewWorkoutDialog extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _DialogState();
  }
}

class _DialogState extends State<NewWorkoutDialog> {
  String _name = "";

  void _onTextChange(String value) {
    setState(() {
      _name = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text("Enter Workout Name"),
          TextField(
            
            onChanged: _onTextChange),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context, null),),
              RaisedButton(child: Text("OK"), onPressed: () => Navigator.pop(context, _name)),
            ],
          )
        ],
      ),
    );
  }
}
