import 'package:flutter/material.dart';
import '../controller/playlist.dart';
import '../widgets/ui_elements/drawer.dart';

class RideListPage extends StatefulWidget {
  final PlaylistController controller;

  RideListPage(this.controller);

  @override
  State<RideListPage> createState() {
    return RideListPageState(controller);
  }
}

class RideListPageState extends State<RideListPage> {
  final PlaylistController controller;

  RideListPageState(this.controller);

  void _ridesChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_ridesChanged);
    controller.fetchRides();
  }

  Widget _buildWorkoutItem(BuildContext context, int index) {
    RideInfo info = controller.rides[index];
    return SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.network(info.ride.imageUrl),
            Positioned(
                top: 200,
                left: 0,
                child: Column(
                  children: <Widget>[
                    Text(info.ride.title, style: TextStyle(fontSize: 20)),
                    Text(info.instructor.name, style: TextStyle(fontSize: 15))
                  ],
                ))
          ],
        ));
  }

  Widget _body() {
    if (controller.rides == null) {
      return CircularProgressIndicator();
    }

    return GridView.builder(
      itemCount: controller.rides.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: _buildWorkoutItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Peloton Videos"),
      ),
      drawer: PeloDrawer(),
      body: Column(
        children: <Widget>[_body()],
      ),
    );
  }
}
