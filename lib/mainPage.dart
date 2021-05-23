import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expandable/expandable.dart';
import 'package:date_format/date_format.dart';
import 'sharedParts.dart';
import 'settingPage.dart';
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

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    itemsList = userState.itemsList;
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
          child: itemsList != null
              ? ReorderableListSimple(
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
                      userState.updateItemsList(itemsList);
                    });
                  },
                  children: itemsList.map((MemoItem item) {
                    Key itemKey = Key(item.getKey);
                    //カードの色と日付・アイコンの色
                    var color, subColor = white;
                    if (itemKey.toString().contains('favorite')) {
                      color = lightOrange;
                    } else if (itemKey.toString().contains('remind')) {
                      color = lightBlue;
                    } else {
                      color = white;
                      subColor = lightGrey;
                    }
                    return Slidable(
                      key: Key(item.getKey),
                      actionExtentRatio: 0.3,
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: [
                        IconSlideAction(
                          icon: Icons.delete,
                          caption: '削除',
                          color: Colors.red[400],
                          onTap: () async {
                            await Future.delayed(Duration(milliseconds: 300),
                                () => itemsList.remove(item));
                            userState.updateItemsList(itemsList);
                            setState(() {});
                          },
                        )
                      ],
                      child: memoCard(item, color, subColor),
                    );
                  }).toList(),
                )
              : Container(),
        ),
      ),
    );
  }

  //メモのカード一つ分の内容
  Widget memoCard(MemoItem item, color, subColor) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.only(
          right: 0,
        ),
        child: ScrollOnExpand(
          child: Card(
            color: color,
            clipBehavior: Clip.antiAlias,
            elevation: 0.0,
            child: Builder(
              builder: (context) {
                var controller =
                    ExpandableController.of(context, required: true);
                return Container(
                  child: TextButton(
                    child: Expandable(
                      collapsed: buildCollapsed(item, subColor),
                      expanded: buildExpanded(item, subColor),
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

  //デフォルトのメモの表示内容
  Widget buildCollapsed(item, subColor) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  item.getValue,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    color: black,
                  ),
                ),
              ),
            ),
            TextButton(
              child: Padding(
                padding: EdgeInsets.all(3),
                child: Icon(
                  Icons.edit_sharp,
                  color: subColor,
                  size: 28,
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
        //通知の日付
        if (item.getNotificationDate != null)
          Container(
            padding: EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: lightYellow,
                ),
                Text(
                  formatDate(
                    item.getNotificationDate,
                    [yyyy, '/', mm, '/', dd, ' ', HH, ':', nn, ''],
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    color: lightYellow,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  //タップした後のメモの表示内容
  Widget buildExpanded(item, subColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  item.getValue,
                  style: TextStyle(
                    fontSize: 18,
                    color: black,
                  ),
                ),
              ),
            ),
          ],
        ),
        //通知の日付
        if (item.getNotificationDate != null)
          Container(
            padding: EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: lightYellow,
                ),
                Text(
                  formatDate(
                    item.getNotificationDate,
                    [yyyy, '/', mm, '/', dd, ' ', HH, ':', nn, ''],
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    color: lightYellow,
                  ),
                ),
              ],
            ),
          ),

        //日付と編集ボタン
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.only(right: 12, bottom: 4),
              child: Text(
                formatDate(
                  item.getCreatedDate,
                  [yyyy, '/', mm, '/', dd, ' ', HH, ':', nn, ''],
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: subColor,
                ),
              ),
            ),
            TextButton(
              child: Padding(
                padding: EdgeInsets.all(3),
                child: Icon(
                  Icons.edit_sharp,
                  color: subColor,
                  size: 28,
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
