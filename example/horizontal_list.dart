import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

void main() => runApp(HorizontalListDemo());

class HorizontalListDemo extends StatefulWidget {
  @override
  _HorizontalListDemoState createState() => _HorizontalListDemoState();
}

class _HorizontalListDemoState extends State<HorizontalListDemo> {
  List<int> data = [];
  int _focusedIndex = 0;

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
        height: 150,
        child: Text("index $_focusedIndex: ${data[_focusedIndex]}"),
      );

    return Container(
      height: 150,
      child: Text("No Data"),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    //horizontal
    return Container(
      width: 35,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            height: data[index].toDouble()*2,
            width: 25,
            color: Colors.lightBlueAccent,
            child: Text("i:$index\n${data[index]}"),
          )
        ],
      ),
    );
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
                  itemSize: 35,
                  buildListItem: _buildListItem,
                  itemCount: data.length,
                  reverse: true,
                ),
              ),
              _buildItemDetail(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Text("Add Item"),
                    onPressed: () {
                      setState(() {
                        data.add(Random().nextInt(100) + 1);
                      });
                    },
                  ),
                  RaisedButton(
                    child: Text("Remove Item"),
                    onPressed: () {
                      int index = data.length > 1
                          ? Random().nextInt(data.length - 1)
                          : 0;
                      setState(() {
                        data.removeAt(index);
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
