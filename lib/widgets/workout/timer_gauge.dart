import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../controller/time_notifier.dart';

class TimerGauge extends StatefulWidget {
  final TimeNotifier timeNotifier;
  final double largeFontSize;
  final double smallFontSize;
  final Color textColor;


  TimerGauge(this.timeNotifier,
      {this.largeFontSize = 50,
      this.smallFontSize = 30,
      this.textColor = Colors.black});


  @override
  State<StatefulWidget> createState() {
    return _TimerGaugeState(this.timeNotifier);
  }
}

class _TimerGaugeState extends State<TimerGauge> {
  NumberFormat numberFormat = NumberFormat("00");
  Duration _duration = Duration();

  final TimeNotifier timeNotifier;

  _TimerGaugeState(this.timeNotifier);

  @override
  void initState() {
    super.initState();
    timeNotifier.addListener(_timeChange);
  }

  void _timeChange() {
    if (!mounted) {
      return;
    }
    setState(() {
      _duration = timeNotifier.currentElapsedTime;
    });
  }

  String _timerValue() {
    if (_duration.inHours > 0) {
      return '${numberFormat.format(_duration.inHours.remainder(24))}:${numberFormat.format(_duration.inMinutes.remainder(60))}:${numberFormat.format(_duration.inSeconds.remainder(60))}';
    }
    return '${numberFormat.format(_duration.inMinutes.remainder(60))}:${numberFormat.format(_duration.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Colors.black87),
        child: Column(children: <Widget>[
      Text('Time', style: TextStyle(
        color: widget.textColor,
        inherit: false,
        fontSize: widget.smallFontSize)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _timerValue(),
            style: TextStyle(
              inherit: false,
              color: widget.textColor,
              fontSize: widget.largeFontSize, fontWeight: FontWeight.bold),
          )
        ],
      ), SizedBox(height: 25,)
    ]));
  }
}
