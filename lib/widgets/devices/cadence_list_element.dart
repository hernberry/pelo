import 'package:flutter/material.dart';
import '../../model/devices/cadence.dart';

class CadenceListElement extends StatefulWidget {
  
  CadenceMonitor monitor;
  bool isRegistered;
  final Function registerClicked;

  CadenceListElement(this.monitor, this.isRegistered, this.registerClicked);

  @override
  State<StatefulWidget> createState() {
    return _CadenceElementState();
  }
}

class _CadenceElementState extends State<CadenceListElement> {

  int currentCadence = 0;

  void _handleCadenceUpdate(int reading) {
    setState(() => currentCadence = reading);
  }

  @override
  void initState() {
    super.initState();
    widget.monitor.subscribe(_handleCadenceUpdate);
    widget.monitor.connect();
  }

  @override
  void dispose() {
    super.dispose();
    widget.monitor.disconnect();
    widget.monitor = null;
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
      height: 30.0,
      child: ListTile(
      leading: Icon(Icons.data_usage),
      title: Text('Cadence: $currentCadence'),
      subtitle: Text('Device: ${widget.monitor.device.name}'),
      trailing: RaisedButton(child: Text(buttonText), onPressed: _onButtonPress,),
    ));
  }
}
