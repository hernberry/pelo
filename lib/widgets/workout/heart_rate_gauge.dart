import 'package:flutter/material.dart';
import '../../controller/heart_rate_notifier.dart';

class HeartRateGauge extends StatefulWidget {
  final HeartRateChangeNotifier heartRateNotifier;

  HeartRateGauge(this.heartRateNotifier);

  @override
  State<StatefulWidget> createState() {
    return _HeartRateGaugeState();
  }
}

class _HeartRateGaugeState extends State<HeartRateGauge> {
  static const Map<int, Color> ZONE_COLORS = const {
    1: Colors.transparent,
    2: Colors.greenAccent,
    3: Colors.yellowAccent,
    4: Colors.orangeAccent,
    5: Colors.redAccent
  };

  int _heartRate = 0;
  int _heartRateZone = 1;

  bool hrState = false;

  @override
  void initState() {
    super.initState();
    widget.heartRateNotifier.addListener(_heartRateChange);
  }

  void _heartRateChange() {
    setState(() {
      hrState = !hrState;
      _heartRate = widget.heartRateNotifier.currentHeartRate;
      _heartRateZone = widget.heartRateNotifier.currentHeartRateZone;
    });
  }

  Icon _getHrIcon() {
    return Icon(
      hrState ? Icons.favorite_border : Icons.favorite,
      color: Colors.pink,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: ZONE_COLORS[_heartRateZone]),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(children: <Widget>[
                Text(
                  'Heart Rate',
                  style: TextStyle(fontSize: 20.0),
                )
              ]),
              Row(children: <Widget>[
                Text(
                  "$_heartRate",
                  style: TextStyle(fontSize: 50.0),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text("BPM", style: TextStyle(fontSize: 20.0)),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _getHrIcon(),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Zone $_heartRateZone'),
                ],
              )
            ]));
  }
}
