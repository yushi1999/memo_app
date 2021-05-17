import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mainPage.dart';
import 'sharedParts.dart';
import 'reorderable_list_simple.dart';

import 'package:flutter_reorderable_list/flutter_reorderable_list.dart' as rol;

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<MemoItem> items;

  final _appBar = AppBar(
    backgroundColor: white,
    elevation: 0.0,
    title: Text(
      "メモ帳",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.add),
        onPressed: () {},
      ),
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {},
      ),
    ],
  );

  @override
  initState() {
    super.initState();
    items = [];
    List memoList = ['洗剤を買い足す', '勉強メモ', 'シャンプー買う', '今年の目標'];
    for (int i = 0; i < memoList.length; i++) {
      final newItem = MemoItem(memoList[i], i.toString());
      items.add(newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: _appBar,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: ReorderableListSimple(
            handleSide: ReorderableListSimpleSide.Left,
            handleIcon: Icon(
              Icons.drag_handle,
              color: lightGrey,
            ),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                MemoItem item = items[oldIndex];
                items.remove(item);
                items.insert(newIndex, item);
              });
            },
            children: items.map((MemoItem item) {
              return Card(
                color: white,
                elevation: 0.0,
                key: Key(item.key),
                child: ListTile(
                  title: item.getValue == null
                      ? Text('null')
                      : Text(item.getValue),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
