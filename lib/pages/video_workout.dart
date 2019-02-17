import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

import '../widgets/workout/timer_gauge.dart';
import '../widgets/workout/heart_rate_gauge.dart';
import '../widgets/workout/cadence_gauge.dart';

import '../controller/video_workout.dart';
import '../controller/workout_state.dart';
import '../controller/playlist_state.dart';

class VideoWorkoutPage extends StatefulWidget {
  final VideoWorkoutController controller;

  VideoWorkoutPage(this.controller);

  @override
  State<StatefulWidget> createState() {
    return _VideoWorkoutState(controller);
  }
}

class _VideoWorkoutState extends State<VideoWorkoutPage> {
  final VideoWorkoutController controller;

  _VideoWorkoutState(this.controller);

  @override
  void initState() {
    super.initState();
    // Video mode - always landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);

    controller.addListener(_controllerChange);
    controller.initialize();
  }

  void _controllerChange() {
    setState(() {});
  }

  @override
  void dispose() {
    // Restore portrait ability
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  void _tap() {
    controller.toggle();
  }

  int _smalFontSize() {
    return (MediaQuery.of(context).size.height * .10).floor();
  }

  NumberFormat numberFormat = NumberFormat("00");
  String _videoTimeRemaining() {
    Duration remaining = controller.currentVideoRemaining;
    if (remaining == null) {
      return "--:--";
    }

    if (remaining.inHours > 0) {
      return "${numberFormat.format(remaining.inHours)}" +
          ":${numberFormat.format(remaining.inMinutes)}" +
          ":${numberFormat.format(remaining.inSeconds)}";
    } else {
      return "${numberFormat.format(remaining.inMinutes)}" +
          ":${numberFormat.format(remaining.inSeconds)}";
    }
  }

  Widget _getGauges() {
    MediaQueryData data = MediaQuery.of(context);
    var largeFontSize = .07 * data.size.height;
    var smallFontSize = .05 * data.size.height;
    return Positioned(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              HeartRateGauge(
                controller.heartRateNotifier,
                smallFontSize: smallFontSize,
                largeFontSize: largeFontSize,
                textColor: Colors.white30,
              ),
              TimerGauge(
                controller.timeNotifier,
                smallFontSize: smallFontSize,
                largeFontSize: largeFontSize,
                textColor: Colors.white30,
              ),
              CadenceGauge(
                controller.cadenceNotifier,
                smallFontSize: smallFontSize,
                largeFontSize: largeFontSize,
                textColor: Colors.white30,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _getPermanentControls() {
    var controls = <Widget>[_getGauges()];
    return controls;
  }

  void _end() {
    controller.end().then((id) {
      Navigator.pushReplacementNamed(context, "/details/${id}");
    });
  }

  List<Widget> _getDisappearingControls() {
    if (controller.controlsViewState == ControlsViewState.hidden) {
      return [];
    }
    var controls = <Widget>[];
    var height = MediaQuery.of(context).size.height;
    var iconHeight = 0.2 * height;
    Icon icon = Icon(
        controller.currentState == WorkoutState.running
            ? Icons.pause
            : Icons.play_arrow,
        color: Colors.white30,
        size: iconHeight);
    controls.addAll([
      Positioned(
        child: Align(alignment: Alignment.center, child: icon),
      ),
      Positioned(
          child: Align(
              alignment: Alignment.topRight,
              child: FlatButton(
                onPressed: _end,
                child: Text("End"),
                color: Colors.white30,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ))),
    ]);
    if (controller.playlistState != PlaylistState.ended) {
      double fontSize = .04 * height;
      controls.add(
        Positioned(
          child: Align(
              alignment: Alignment.topLeft,
              child: Column(children: <Widget>[
                Text(
                  "Current Video Remaining",
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white30,
                    inherit: false,
                  ),
                ),
                Text(
                  _videoTimeRemaining(),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white30,
                    inherit: false,
                  ),
                ),
              ])),
        ),
      );
    }
    return controls;
  }

  Widget _getVideoBackground() {
    return VideoPlayer(controller.playerController);
  }

  Widget _getStaticBackground() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
          decoration: BoxDecoration(color: Colors.black26),
          width: constraints.maxWidth,
          height: constraints.maxHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller.currentState == WorkoutState.initializing) {
      return Container(
        child: Align(
            alignment: Alignment.center, child: CircularProgressIndicator()),
      );
    }
    return GestureDetector(
        onTap: _tap,
        child: AspectRatio(
            aspectRatio: 16 / 9.0,
            child: Stack(
                children: <Widget>[
                      controller.playlistState == PlaylistState.ended
                          ? _getStaticBackground()
                          : _getVideoBackground()
                    ] +
                    _getDisappearingControls() +
                    _getPermanentControls())));
  }
}
