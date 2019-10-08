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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 10; i++) {
      data.add(Random().nextInt(100) + 1);
    }
  }

  void _onItemFocus(int index) {
    setState(() {
      _focusedIndex = index;
    });
  }

  void _loadMoreData() {
    setState(() {
      _isLoading = true;  
    });
    
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        for (int i = 0; i < 10; i++) {
          data.add(Random().nextInt(100) + 1);
        }
        _isLoading = false;  
      });
    });
  }

  Widget _buildItemDetail() {
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
      width: 35,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            height: data[index].toDouble() * 2,
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
                  onReachEnd: _loadMoreData,
                  itemSize: 35,
                  itemBuilder: _buildListItem,
                  itemCount: _isLoading?data.length+1:data.length,
                  reverse: true,
                  endOfListTolerance: 100,
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
