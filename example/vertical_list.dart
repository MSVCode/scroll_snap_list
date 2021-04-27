import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

void main() => runApp(VerticalListDemo());

class VerticalListDemo extends StatefulWidget {
  @override
  _VerticalListDemoState createState() => _VerticalListDemoState();
}

class _VerticalListDemoState extends State<VerticalListDemo> {
  List<int> data = [];
  int _focusedIndex = 0;
  GlobalKey<ScrollSnapListState> sslKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 30; i++) {
      data.add(i);
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
      height: 50,
      child: Material(
        color: _focusedIndex == index ? Colors.lightBlueAccent : Colors.white,
        child: InkWell(
          child: Text("Index: $index | Value: ${data[index]}"),
          onTap: () {
            print("Do anything here");

            //trigger focus manually
            sslKey.currentState!.focusToItem(index);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vertical List Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Vertical List"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(border: Border.all(width: 2)),
                  width: 250,
                  height: 300,
                  child: ScrollSnapList(
                    onItemFocus: _onItemFocus,
                    itemExtent: 50,
                    // selectedItemAnchor: SelectedItemAnchor.START, //to change item anchor uncomment this line
                    // dynamicItemOpacity: 0.3, //to set unselected item opacity uncomment this line
                    itemBuilder: _buildListItem,
                    itemCount: data.length,
                    key: sslKey,
                    scrollDirection: Axis.vertical,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              _buildItemDetail(),
            ],
          ),
        ),
      ),
    );
  }
}
