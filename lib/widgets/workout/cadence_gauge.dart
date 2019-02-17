import 'package:flutter/material.dart';
import '../../controller/cadence_notifier.dart';

class CadenceGauge extends StatefulWidget {
  final CadenceChangeNotifier cadenceNotifier;
  final double largeFontSize;
  final double smallFontSize;
  final Color textColor;

  CadenceGauge(this.cadenceNotifier,
      {this.largeFontSize = 50,
      this.smallFontSize = 30,
      this.textColor = Colors.black});

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
        decoration: BoxDecoration(
          color: Colors.black87,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          Row(
            children: <Widget>[
              Text('Cadence',
                  style: TextStyle(
                      color: widget.textColor,
                      fontSize: widget.smallFontSize,
                      inherit: false)),
            ],
          ),
          Row(children: <Widget>[
            Text(
              '$_cadence',
              style: TextStyle(
                  color: widget.textColor,
                  fontSize: widget.largeFontSize,
                  inherit: false),
            ),
            SizedBox(width: 10),
            Text('RPM',
                style: TextStyle(
                    color: widget.textColor,
                    fontSize: widget.smallFontSize,
                    inherit: false)),

          ]),
        SizedBox(height: 25,)]));
  }
}
