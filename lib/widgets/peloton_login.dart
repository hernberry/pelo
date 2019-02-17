import 'package:flutter/material.dart';

import '../model/services/peloton/types.dart';

class PelotonLogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PelotonLoginState();
}

class _PelotonLoginState extends State<PelotonLogin> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("Login to Peloton"),
      children: <Widget>[
        Image.asset('assets/peloton_banner.png'),
        TextFormField(
          controller: _usernameController,
        ),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
        ),
        Row(children: [
          RaisedButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel')),
          RaisedButton(
              onPressed: () => Navigator.pop(
                  context,
                  PelotonCredentials(
                      _usernameController.value.text, _passwordController.value.text)),
              child: Text('Login'))
        ])
      ],
    );
  }
}
