import 'package:flutter/material.dart';
import '../../bluetooth/device.dart';

class HeartRateMonitorListElement extends StatefulWidget {
  HearRateMonitor hrm;
  bool isRegistered;
  Function registerClicked;

  HeartRateMonitorListElement(this.hrm, this.isRegistered, this.registerClicked);

  @override
  State<StatefulWidget> createState() {
    return _HRMElementState();
  }
}

class _HRMElementState extends State<HeartRateMonitorListElement> {

  int currentHeartRate = 0;

  void _handleHeartRateUpdate(int reading) {
    setState(() => currentHeartRate = reading);
  }

  @override
  void initState() {
    super.initState();
    widget.hrm.subscribe(_handleHeartRateUpdate);
    widget.hrm.connect();
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
    String buttonText= widget.isRegistered ? "Disconnect" : "Connect";
    return Container(
//      height: 80.0,
      child: ListTile(
      leading: Icon(Icons.favorite_border),
      title: Text('Heart Rate: $currentHeartRate'),
      subtitle: Text('Device: ${widget.hrm.device.name}'),
      trailing: RaisedButton(child: Text(buttonText), onPressed: _onButtonPress,),
    ));
  }
}
