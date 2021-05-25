import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
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
          style: GoogleFonts.montserrat(
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
            onPressed: () async {
              //var rand = new math.Random();
              //int colorIndex = rand.nextInt(colorCombinations.length);
              int colorIndex =
                  userState.themeNumber != colorCombinations.length - 1
                      ? userState.themeNumber + 1
                      : 0;
              userState.setColorsList(
                  colorCombinations[colorIndex][0],
                  colorCombinations[colorIndex][1],
                  colorCombinations[colorIndex][2],
                  colorCombinations[colorIndex][3]);
              userState.setThemeNumber(colorIndex);
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
      floatingActionButton: textColor != transparent
          ? Container(
              margin: EdgeInsets.only(bottom: 60),
              child: FloatingActionButton.extended(
                backgroundColor: highlightColor,
                icon: Icon(
                  Icons.add,
                  color: backgroundColor,
                ),
                label: Text(
                  '作成',
                  style: GoogleFonts.mPlus1p(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: backgroundColor,
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
            )
          : Container(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 4, left: 4, top: 6, bottom: 6),
          child: (itemsList != null && highlightColor != null)
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
                          return MapEntry(
                            index,
                            Slidable(
                              key: Key(item.getKey),
                              actionExtentRatio: 0.3,
                              actionPane: SlidableDrawerActionPane(),
                              secondaryActions: [
                                IconSlideAction(
                                  iconWidget: Container(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Icon(
                                      Icons.delete,
                                      color: backgroundColor,
                                      size: 30,
                                    ),
                                  ),
                                  caption: '削除',
                                  foregroundColor: backgroundColor,
                                  color: secondaryColor,
                                  onTap: () async {
                                    await Future.delayed(
                                        Duration(milliseconds: 300),
                                        () => itemsList.remove(item));
                                    userState.updateItemsList(itemsList);
                                    setState(() {});
                                  },
                                )
                              ],
                              child: memoCard(item, index, highlightColor,
                                  secondaryColor, backgroundColor, textColor),
                            ),
                          );
                        },
                      )
                      .values
                      .toList())
              : Container(),
        ),
      ),
    );
  }

  //メモのカード一つ分の内容
  Widget memoCard(MemoItem item, index, highlightColor, secondaryColor,
      backgroundColor, textColor) {
    String itemKey = Key(item.getKey).toString();
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.only(
          right: 0,
        ),
        child: ScrollOnExpand(
          child: Card(
            color:
                itemKey.contains('favorite') ? highlightColor : backgroundColor,
            clipBehavior: Clip.antiAlias,
            elevation: 0.0,
            child: Builder(
              builder: (context) {
                var controller =
                    ExpandableController.of(context, required: true);
                return Container(
                  child: TextButton(
                    child: Expandable(
                      collapsed: buildCollapsed(item, index, secondaryColor,
                          backgroundColor, textColor),
                      expanded: buildExpanded(item, index, secondaryColor,
                          backgroundColor, textColor),
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
      item, index, secondaryColor, backgroundColor, textColor) {
    String itemKey = Key(item.getKey).toString();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  item.getValue.replaceAll(RegExp(r'\n'), ' '),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    color: itemKey.contains('favorite')
                        ? backgroundColor
                        : textColor,
                  ),
                ),
              ),
              //通知の日付
              if (item.getNotificationDate != null)
                Container(
                  color: secondaryColor,
                  margin: EdgeInsets.only(top: 8),
                  width: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.notifications,
                          color: backgroundColor,
                        ),
                      ),
                      Text(
                        formatDate(
                          item.getNotificationDate,
                          [mm, '/', dd, ' ', HH, ':', nn, ''],
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
            padding: EdgeInsets.only(left: 3),
            child: Icon(
              Icons.edit_sharp,
              color: textColor,
              size: 26,
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
      item, index, secondaryColor, backgroundColor, textColor) {
    String itemKey = Key(item.getKey).toString();
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
                    color: itemKey.contains('favorite')
                        ? backgroundColor
                        : textColor,
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
            width: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.notifications,
                    color: backgroundColor,
                  ),
                ),
                Text(
                  formatDate(
                    item.getNotificationDate,
                    [mm, '/', dd, ' ', HH, ':', nn, ''],
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
                  fontSize: 14,
                  color: itemKey.contains('favorite')
                      ? backgroundColor
                      : textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            TextButton(
              child: Padding(
                padding: EdgeInsets.only(left: 3),
                child: Icon(
                  Icons.edit_sharp,
                  color: textColor,
                  size: 26,
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
