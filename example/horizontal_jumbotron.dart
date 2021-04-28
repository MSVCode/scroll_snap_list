import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

void main() => runApp(HorizontalListJumboDemo());

class HorizontalListJumboDemo extends StatefulWidget {
  @override
  _HorizontalListJumboDemoState createState() => _HorizontalListJumboDemoState();
}

class _HorizontalListJumboDemoState extends State<HorizontalListJumboDemo> {
  List<int> data = [];
  int _focusedIndex = 0;
  GlobalKey<ScrollSnapListState> sslKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 30; i++) {
      data.add(Random().nextInt(100) + 1);
    }
  }

  void _onItemFocus(int index) {
    setState(() {
      _focusedIndex = index;
    });
  }

  Widget _buildItemDetail() {
    if (data.length > _focusedIndex)
      return Container(
        height: 350,
        child: Text("index $_focusedIndex: ${data[_focusedIndex]}"),
      );

    return Container(
      height: 350,
      child: Text("No Data"),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: 350,
      child: Material(
        color: Colors.lightBlueAccent,
        child: InkWell(
          onTap: () {
            sslKey.currentState!.focusToItem(index);
          },
          child: Text("Child index $index"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jumbo List Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Jumbo List"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ScrollSnapList(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  onItemFocus: _onItemFocus,
                  itemExtent: 360,
                  itemBuilder: _buildListItem,
                  itemCount: data.length,
                  key: sslKey,
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
