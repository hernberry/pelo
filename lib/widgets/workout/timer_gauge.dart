import 'package:flutter/material.dart';
import '../../controller/time_notifier.dart';

class TimerGauge extends StatefulWidget {
  final TimeNotifier timeNotifier;

  TimerGauge(this.timeNotifier);

  @override
  State<StatefulWidget> createState() {
    return _TimerGaugeState();
  }
}

class _TimerGaugeState extends State<TimerGauge> {
  Duration _duration = Duration();

  @override
  void initState() {
    super.initState();
    widget.timeNotifier.addListener(_timeChange);
  }

  void _timeChange() {
    setState(() {
      _duration = widget.timeNotifier.currentElapsedTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "$_duration",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        )
      ],
    ));
  }
}
