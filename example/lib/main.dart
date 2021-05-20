import 'package:flutter/material.dart';

import 'dynamic_horizontal.dart';
import 'horizontal_jumbotron.dart';
import 'horizontal_list.dart';
import 'tab_with_horizontal.dart';
import 'vertical_list.dart';

void main() => runApp(const SnapScrollListDemo());

class SnapScrollListDemo extends StatelessWidget {
  const SnapScrollListDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ListView(
            children: [
              _buildTile(context, DynamicHorizontalDemo()),
              _buildTile(context, HorizontalListJumboDemo()),
              _buildTile(context, HorizontalListDemo()),
              _buildTile(context, TabWithHorizontalListDemo()),
              _buildTile(context, VerticalListDemo()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, Widget page) {
    return ListTile(
      title: Text(page.runtimeType.toString()),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => page),
      ),
    );
  }
}
