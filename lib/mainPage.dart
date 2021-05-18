import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:expandable/expandable.dart';
import 'package:date_format/date_format.dart';
import 'sharedParts.dart';
import 'settingPage.dart';
import 'createMemoPage.dart';
import 'widgets/reorderable_list_simple.dart';
import 'widgets/customExpansionTile.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<MemoItem> itemsList;

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
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0.0,
        title: Text(
          "Simple Memo Pad",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return SettingPage();
                  },
                ),
              );
            },
          ),
        ],
      ),
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
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: ScrollOnExpand(
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0.0,
            child: Builder(
              builder: (context) {
                var controller =
                    ExpandableController.of(context, required: true);
                return Container(
                  child: TextButton(
                    child: Expandable(
                      collapsed: buildCollapsed(item),
                      expanded: buildExpanded(item),
                    ),
                    onPressed: () {
                      controller.toggle();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCollapsed(item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              item.getValue,
              maxLines: 4,
              style: TextStyle(
                fontSize: 18,
                color: black,
              ),
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
    );
  }

  Widget buildExpanded(item) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                item.getValue,
                style: TextStyle(
                  fontSize: 18,
                  color: black,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(right: 12),
              child: Text(
                formatDate(
                  item.getCreatedDate,
                  [yyyy, '/', mm, '/', dd, ' ', HH, ':', nn, ''],
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              child: Padding(
                padding: EdgeInsets.all(6),
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
      ],
    );
  }
}
