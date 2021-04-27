import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

void main() => runApp(TabWithHorizontalListDemo());

class TabWithHorizontalListDemo extends StatelessWidget {
  final List<Widget> _tabScreen = [
    HorizontalListJumbo(
      key: PageStorageKey<String>("Tab 1"),
    ),
    HorizontalListJumbo(
      key: PageStorageKey<String>("Tab 2"),
    ),
    HorizontalListJumbo(
      key: PageStorageKey<String>("Tab 3"),
    )
  ];
  final List<Widget> _tabMenu = [Tab(child: Text('Tab 1')), Tab(child: Text('Tab 2')), Tab(child: Text('Tab 3'))];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jumbo List Demo',
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Tab test',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(tabs: _tabMenu),
          ),
          body: TabBarView(
            children: _tabScreen,
          ),
        ),
      ),
    );
  }
}

class HorizontalListJumbo extends StatefulWidget {
  final Key? key;

  HorizontalListJumbo({this.key});
  @override
  _HorizontalListJumboState createState() => _HorizontalListJumboState();
}

class _HorizontalListJumboState extends State<HorizontalListJumbo> {
  List<int> data = [];
  int _focusedIndex = 0;
  GlobalKey<ScrollSnapListState> sslKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 30; i++) {
      data.add(i + 1);
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
    return Container(
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
              listViewKey: widget.key,
            ),
          ),
          _buildItemDetail(),
        ],
      ),
    );
  }
}
