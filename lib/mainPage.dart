import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
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
    Color highlightColor = userState.colorsList[0];
    Color secondaryColor = userState.colorsList[1];
    Color backgroundColor = userState.colorsList[2];
    Color textColor = userState.colorsList[3];
    itemsList = userState.itemsList;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0.0,
        title: Text(
          "Simple Memo Pad",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.rotate_left,
              color: textColor,
            ),
            onPressed: () {
              var rand = new math.Random();
              int index = rand.nextInt(colorCombinations.length);
              userState.setColorsList(
                  colorCombinations[index][0],
                  colorCombinations[index][1],
                  colorCombinations[index][2],
                  colorCombinations[index][3]);
              print(index);
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: textColor,
            ),
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
          foregroundColor: highlightColor,
          icon: Icon(
            Icons.add,
            color: backgroundColor,
          ),
          label: Text(
            '作成',
            style: TextStyle(
              color: backgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return CreateMemoPage(null, -1);
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
                    color: textColor,
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
                  children: itemsList
                      .asMap()
                      .map(
                        (int index, MemoItem item) {
                          Key itemKey = Key(item.getKey);
                          //カードの色と日付・アイコンの色
                          var bgColor, txColor; //white;
                          if (itemKey.toString().contains('favorite')) {
                            bgColor = highlightColor;
                            txColor = backgroundColor;
                          } else {
                            bgColor = backgroundColor;
                            txColor = textColor;
                          }
                          /*
                          if (itemKey.toString().contains('favorite')) {
                            color = highlightColor;
                          } else if (itemKey.toString().contains('remind')) {
                            color = white; //secondaryColor;
                          } else {
                            color = white;
                            //subColor = teritiaryColor;
                          }*/
                          return MapEntry(
                            index,
                            Slidable(
                              key: Key(item.getKey),
                              actionExtentRatio: 0.3,
                              actionPane: SlidableDrawerActionPane(),
                              secondaryActions: [
                                IconSlideAction(
                                  icon: Icons.delete,
                                  caption: '削除',
                                  color: Colors.red[400],
                                  onTap: () async {
                                    await Future.delayed(
                                        Duration(milliseconds: 300),
                                        () => itemsList.remove(item));
                                    userState.updateItemsList(itemsList);
                                    setState(() {});
                                  },
                                )
                              ],
                              child: memoCard(item, bgColor, txColor, index,
                                  secondaryColor, backgroundColor, textColor),
                            ),
                          );
                        },
                      )
                      .values
                      .toList(),
                )
              : Container(),
        ),
      ),
    );
  }

  //メモのカード一つ分の内容
  Widget memoCard(MemoItem item, bgColor, txColor, index, secondaryColor,
      teritiaryColor, textColor) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.only(
          right: 0,
        ),
        child: ScrollOnExpand(
          child: Card(
            color: bgColor,
            clipBehavior: Clip.antiAlias,
            elevation: 0.0,
            child: Builder(
              builder: (context) {
                var controller =
                    ExpandableController.of(context, required: true);
                return Container(
                  child: TextButton(
                    child: Expandable(
                      collapsed: buildCollapsed(item, txColor, index,
                          secondaryColor, teritiaryColor, textColor),
                      expanded: buildExpanded(item, txColor, index,
                          secondaryColor, teritiaryColor, textColor),
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
  Widget buildCollapsed(
      item, txColor, index, secondaryColor, backgroundColor, penColor) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  item.getValue,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    color: txColor,
                  ),
                ),
              ),
              //通知の日付
              if (item.getNotificationDate != null)
                Container(
                  color: secondaryColor,
                  margin: EdgeInsets.only(top: 8),
                  width: 180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications,
                        color: backgroundColor,
                      ),
                      Text(
                        formatDate(
                          item.getNotificationDate,
                          [yyyy, '/', mm, '/', dd, ' ', HH, ':', nn, ''],
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: backgroundColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        TextButton(
          child: Padding(
            padding: EdgeInsets.all(3),
            child: Icon(
              Icons.edit_sharp,
              color: penColor,
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
                  return CreateMemoPage(item, index);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  //タップした後のメモの表示内容
  Widget buildExpanded(
      item, txColor, index, secondaryColor, backgroundColor, penColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: txColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        //通知の日付
        if (item.getNotificationDate != null)
          Container(
            color: secondaryColor,
            margin: EdgeInsets.only(top: 8),
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications,
                  color: backgroundColor,
                ),
                Text(
                  formatDate(
                    item.getNotificationDate,
                    [yyyy, '/', mm, '/', dd, ' ', HH, ':', nn, ''],
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: backgroundColor,
                    fontWeight: FontWeight.w400,
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
                  color: txColor,
                ),
              ),
            ),
            TextButton(
              child: Padding(
                padding: EdgeInsets.all(3),
                child: Icon(
                  Icons.edit_sharp,
                  color: penColor,
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
                      return CreateMemoPage(item, index);
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
