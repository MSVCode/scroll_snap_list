import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

void main() => runApp(DynamicHorizontalDemo());

class DynamicHorizontalDemo extends StatefulWidget {
  @override
  _DynamicHorizontalDemoState createState() => _DynamicHorizontalDemoState();
}

class _DynamicHorizontalDemoState extends State<DynamicHorizontalDemo> {
  List<int> data = [];
  int _focusedIndex = -1;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 10; i++) {
      data.add(Random().nextInt(100) + 1);
    }
  }

  void _onItemFocus(int index) {
    print(index);
    setState(() {
      _focusedIndex = index;
    });
  }


  Widget _buildItemDetail() {
    if (_focusedIndex<0) return Container(
      height: 250,
      child: Text("Nothing selected"),
    );

    if (data.length > _focusedIndex)
      return Container(
        height: 250,
        child: Text("index $_focusedIndex: ${data[_focusedIndex]}"),
      );

    return Container(
      height: 250,
      child: Text("No Data"),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    if (index == data.length)
      return Center(child: CircularProgressIndicator(),);

    //horizontal
    return Container(
      width: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 200,
            width: 150,
            color: Colors.lightBlueAccent,
            child: Text("i:$index\n${data[index]}"),
          )
        ],
      ),
    );
  }

  ///Override default dynamicItemSize calculation
  double customEquation(double distance){
    // return 1-min(distance.abs()/500, 0.2);
    return 1-(distance/1000);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horizontal List Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Horizontal List"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ScrollSnapList(
                  onItemFocus: _onItemFocus,
                  itemSize: 150,
                  itemBuilder: _buildListItem,
                  itemCount: data.length,
                  dynamicItemSize: true,
                  // dynamicSizeEquation: customEquation, //optional
                ),
              ),
              _buildItemDetail(),
            ],
          ),
        ),
      ),
    );
  }
}
