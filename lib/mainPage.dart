import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'sharedParts.dart';
import 'createMemoPage.dart';
import 'widgets/reorderable_list_simple.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<MemoItem> itemsList;

  //AppBar
  final _appBar = AppBar(
    backgroundColor: white,
    elevation: 0.0,
    title: Text(
      "Simple Memo Pad",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {},
      ),
    ],
  );

  //スライドしてメモを削除
  final _deleteMemoAction = IconSlideAction(
    icon: Icons.delete,
    caption: '削除',
    color: Colors.red[400],
    onTap: () {},
  );

  @override
  initState() {
    super.initState();
    /*
    List memoList = [
      '洗剤を買い足すあああああああああああああああああああああああああああああ',
      '勉強メモ',
      'シャンプー買う\nリンス買う\nボディーソープ買う\n歯磨き粉買う\nリップ買う',
      '今年の目標\nアプリを作る\n自然言語処理をマスターする\nお金いっぱい稼ぐ'
    ];
    for (int i = 0; i < memoList.length; i++) {
      final newItem = MemoItem(memoList[i], i.toString());
      itemsList.add(newItem);
    }*/
  }

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    itemsList = userState.itemsList != null ? userState.itemsList : [];
    userState.updateItemsList(itemsList);

    return Scaffold(
      backgroundColor: white,
      appBar: _appBar,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 60),
        child: FloatingActionButton.extended(
          icon: Icon(
            Icons.add,
            color: white,
          ),
          label: Text(
            '作成',
            style: TextStyle(
              color: white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return CreateMemoPage(null);
                },
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: ReorderableListSimple(
            handleSide: ReorderableListSimpleSide.Left,
            //ドラッグハンドルのアイコン
            handleIcon: Icon(
              Icons.drag_handle,
              color: lightGrey,
              size: 25,
            ),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                MemoItem item = itemsList[oldIndex];
                itemsList.remove(item);
                itemsList.insert(newIndex, item);
              });
            },
            children: itemsList.map((MemoItem item) {
              return Slidable(
                actionExtentRatio: 0.3,
                actionPane: SlidableDrawerActionPane(),
                secondaryActions: [
                  _deleteMemoAction,
                ],
                child: memoCard(item),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  //メモのカード一つ分の内容
  Widget memoCard(MemoItem item) {
    return Card(
      color: white,
      elevation: 0.0,
      key: Key(item.key),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.getValue,
                maxLines: 4,
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.edit_sharp,
                  color: lightGrey,
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                minimumSize: MaterialStateProperty.all(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return CreateMemoPage(item);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
