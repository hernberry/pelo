import 'package:flutter/material.dart';

import '../../controller/ride_list.dart';

class VideoFilterBottomSheet extends StatefulWidget {
  final RideListController controller;

  VideoFilterBottomSheet(this.controller);

  @override
  State<StatefulWidget> createState() {
    return _PageState(controller);
  }
}

class _PageState extends State<StatefulWidget> {
  final RideListController controller;

  _PageState(this.controller);

  @override
  void initState() {
    super.initState();
    controller.addListener(_controllerChange);
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_controllerChange);
  }

  void _controllerChange() {
    setState(() {});
  }

  DropdownMenuItem<T> createMenuItem<T>(T item) {
    return DropdownMenuItem(child: Text(item.toString()), value: item);
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
        onClosing: controller.refresh,
        builder: (context) {
          return Container(
            alignment: Alignment.topCenter,
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 150,
                  child: DropdownButton(
                      onChanged: controller.updateCaegoryFilter,
                      hint: Text("Activity"),
                      value: controller.classCategoryFilter,
                      isExpanded: false,
                      items: Category.ALL.map(createMenuItem).toList()),
                ),
                SizedBox(
                    width: 150,
                    child: DropdownButton(
                        onChanged: controller.updateClassTypeFilter,
                        hint: Text("Class Type"),
                        value: controller.classTypeFilter,
                        isExpanded: false,
                        items: controller.supportedClassTypes
                            .map(createMenuItem)
                            .toList())),
                SizedBox(
                    width: 150,
                    child: DropdownButton(
                        onChanged: controller.updateClassLength,
                        hint: Text("Class Length"),
                        value: controller.classLengthFilter,
                        isExpanded: false,
                        items: ClassLength.ALL.map(createMenuItem).toList())),
              ],
            ),
          );
        });
  }
}
