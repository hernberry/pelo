import 'package:flutter/material.dart';
import '../../controller/cadence_notifier.dart';

class CadenceGauge extends StatefulWidget {
  final CadenceChangeNotifier cadenceNotifier;

  CadenceGauge(this.cadenceNotifier);

  @override
  State<StatefulWidget> createState() {
    return _CadenceGaugeState();
  }
}

class _CadenceGaugeState extends State<CadenceGauge> {
  int _cadence = 0;

  @override
  void initState() {
    super.initState();
    widget.cadenceNotifier.addListener(_cadenceChange);
  }

  void _cadenceChange() {
    if (!mounted) {
      return;
    }
    setState(() {
      _cadence = widget.cadenceNotifier.currentCadence;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          Row(
            children: <Widget>[
              Text('Cadence', style: TextStyle(fontSize: 20.0)),
            ],
          ),
          Row(children: <Widget>[
            Text('$_cadence', style: TextStyle(fontSize: 50.0)),
            SizedBox(width: 10),
            Text('RPM', style: TextStyle(fontSize: 20.0)),
          ]),
        ]));
  }
}
