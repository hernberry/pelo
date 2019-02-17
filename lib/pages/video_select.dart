import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controller/ride_list.dart';
import '../widgets/ui_elements/drawer.dart';
import '../widgets/ui_elements/video_filter_bottom_sheet.dart';
import '../model/services/peloton/types.dart';

class RideListPage extends StatefulWidget {
  final RideListController controller;

  RideListPage(this.controller);

  @override
  State<RideListPage> createState() {
    return RideListPageState(controller);
  }
}

class RideListPageState extends State<RideListPage> {
  final RideListController controller;

  RideListPageState(this.controller);

  void _ridesChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_ridesChanged);
    controller.initialize();
  }

  Widget _buildWorkoutItem(BuildContext context, int index) {
    RideInfo info = controller.rides[index];
    var width = MediaQuery.of(context).size.width;
    var height = (9 / 16.0) * width;
    var textTop = height - 70;
    Widget image = CachedNetworkImage(
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
    );
    return GestureDetector(
        onTap: () => Navigator.pop(context, info),
        child: Container(
            padding: EdgeInsets.only(bottom: 2.5),
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                image,
                Positioned(
                    top: textTop,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(info.ride.title,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                            textAlign: TextAlign.left),
                        SizedBox(
                          height: 5,
                        ),
                        Text(info.instructor.name,
                            style: TextStyle(fontSize: 15, color: Colors.white),
                            textAlign: TextAlign.left),
                      ],
                    ))
              ],
            )));
  }

  Widget _loading() {
    if (controller.isLoading) {
      return Align(
          alignment: Alignment.center,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Loading More Rides"),
                CircularProgressIndicator(
                    backgroundColor: Theme.of(context).accentColor)
              ]));
    }
    return SizedBox(
      height: 0,
      width: 0,
    );
  }

  Widget _body() {
    if (controller.rides.isEmpty) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }

    return ListView.builder(
      controller: controller.scrollController,
      itemCount: controller.rides.length,
      itemBuilder: _buildWorkoutItem,
      shrinkWrap: true,
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
            context: context,
            builder: (context) => VideoFilterBottomSheet(controller))
        .then((a) => controller.refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Select Peloton Videos"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showFilterBottomSheet,
          child: Icon(Icons.filter_list),
        ),
        body: Align(
            alignment: Alignment.center,
            child: Stack(
              children: <Widget>[
                _body(),
                _loading(),
              ],
            )));
  }
}
