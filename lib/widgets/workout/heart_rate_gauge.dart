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

  static final Map<int, Color> ZONE_COLORS = {
    1: Colors.tealAccent,
    2: Colors.green,
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
    return Icon(hrState ? Icons.favorite : Icons.favorite_border);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ZONE_COLORS[_heartRateZone]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("$_heartRate BPM"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _getHrIcon(),
              Text('Zone $_heartRateZone'),
            ],)
        ]
      ));
  }
}