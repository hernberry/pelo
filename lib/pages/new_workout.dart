import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../model/services/peloton/types.dart';
import '../controller/new_workout_controller.dart';

class NewWorkoutPage extends StatefulWidget {
  final NewWorkoutController controller;

  NewWorkoutPage(this.controller);

  @override
  State<StatefulWidget> createState() {
    return _NewWorkoutPageState(controller);
  }
}

class _NewWorkoutPageState extends State<NewWorkoutPage> {
  final NewWorkoutController controller;

  _NewWorkoutPageState(this.controller);

  @override
  void initState() {
    super.initState();
    this.controller.addListener(_change);
  }

  void _change() {
    setState(() {});
  }

  Widget _createListItem(RideInfo info) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return _createRideView(info, constraints);
    });
  }

  Widget _createRideView(RideInfo info, BoxConstraints constraits) {
    var height = constraits.maxHeight;
    var width = constraits.maxWidth;
    return Container(
        width: width,
        height: height,
        child: Stack(children: <Widget>[
          CachedNetworkImage(
            placeholder: Container(
                width: width,
                height: height,
                color: Colors.black,
                child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ))),
            imageUrl: info.ride.imageUrl,
            fit: BoxFit.fill,
            width: width,
            height: height,
          ),
          Positioned(
              top: height - 20,
              left: 5,
              child: Text(info.ride.title,
                  style: TextStyle(fontSize: 13, color: Colors.white),
                  textAlign: TextAlign.left))
        ]));
  }

  Widget _buildListView() {
    return Expanded(
        flex: 3,
        child: GridView.count(
            childAspectRatio: 16 / 9.0,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            crossAxisCount: 2,
            children: controller.selectedRides.map(_createListItem).toList()));
  }

  Widget _workoutNameTextField() {
    return Expanded(
        flex: 1,
        child: ListTile(
          leading: Text("Workout Name"),
          title: TextField(controller: controller.nameController),
        ));
  }

  void _addRide() async {
    RideInfo info =
        await Navigator.pushNamed<RideInfo>(context, '/video_select');
    controller.addRide(info);
  }

  void _startWorkout() {
    String id = controller.createWorkout();
    Navigator.pushReplacementNamed(context, '/video_workout/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Workouts"),
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                _workoutNameTextField(),
                Row(children: [
                  RaisedButton(
                    child: Text("Add Peloton Video"),
                    onPressed: _addRide,
                  ),
                  RaisedButton(
                    child: Text("Start"),
                    onPressed: _startWorkout,
                  )
                 ]),
                _buildListView(),
              ],
            )));
  }
}
