import 'package:flutter/material.dart';
import '../../model/devices/heart_rate.dart';

class HeartRateMonitorListElement extends StatefulWidget {
  HearRateMonitor hrm;
  bool isRegistered;
  Function registerClicked;

  HeartRateMonitorListElement(
      this.hrm, this.isRegistered, this.registerClicked);

  @override
  State<StatefulWidget> createState() {
    return _HRMElementState(hrm);
  }
}

class _HRMElementState extends State<HeartRateMonitorListElement> {
  int currentHeartRate = 0;
  final HearRateMonitor monitor;

  _HRMElementState(this.monitor);

  void _handleHeartRateUpdate(HeartRateReading reading) {
    if (mounted) {
      setState(() => currentHeartRate = reading.hearRateBpm);
    }
  }

  @override
  void initState() {
    super.initState();
    monitor.subscribe(_handleHeartRateUpdate);
    monitor.connect();
  }

  @override
  void dispose() {
    super.dispose();
    widget.hrm.disconnect();
    widget.hrm = null;
  }

  void _onButtonPress() {
    setState(() {
      widget.isRegistered = widget.registerClicked();
    });
  }

  @override
  Widget build(BuildContext context) {
    String buttonText = widget.isRegistered ? "Disconnect" : "Connect";
    return Container(
        child: ListTile(
      leading: Icon(Icons.favorite_border),
      title: Text('Heart Rate: $currentHeartRate'),
      subtitle: Text('Device: ${widget.hrm.device.name}'),
      trailing: RaisedButton(
        child: Text(buttonText),
        onPressed: _onButtonPress,
      ),
    ));
  }
}
