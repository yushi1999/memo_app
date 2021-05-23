import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color white = Colors.white;
Color black = Colors.black;
Color red = Colors.red;
Color blue = Colors.blue;
Color yellow = Colors.yellow;
Color pink = Colors.pink;
Color blueGrey = Colors.blueGrey;
Color middleGrey = Colors.grey[500];
Color lightBlue = Colors.blue[200];
Color lightYellow = Colors.yellow[300];
Color lightGrey = Colors.grey[300];
Color lightOrange = Colors.orange[300];
Color teritiary = Color(0xffbae8e8);
Color highlight = Color(0xffffd803);

List<List<Color>> colorCombinations = [
  [Color(0xff7EC2C2), Color(0xffe67a7a), white, blueGrey],
  [Color(0xff77AF9C), Color(0xffC5E99B), white, middleGrey],
  [Color(0xff4072b3), Color(0xffeb8686), white, middleGrey],
  [Color(0xff79a1d4), Color(0xffabcae8), white, blueGrey],
  [Color(0xffef866b), Color(0xffbcb5b5), white, blueGrey],
  [Color(0xffff9800), Color(0xff235180), white, middleGrey],
  [Color(0xff333333), Color(0xff60caad), Color(0xffe9e9e9), blueGrey]
];

//SharedPreferencesに保存
Future updateSharedPreferences(List<MemoItem> itemsList) async {
  //itemsListをMap型に変換→Json形式にエンコード→リスト化
  List<String> itemsListPref =
      itemsList.map((f) => json.encode(f.toJson())).toList();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //リストをSharedPreferencesに保存
  await prefs.setStringList('memoItemsList', itemsListPref);
  print('updateSharedPreferences: $itemsListPref');
}

class UserState extends ChangeNotifier {
  List<MemoItem> itemsList;
  List<Color> colorsList;

  setItems(MemoItem item) async {
    itemsList.add(item);
    notifyListeners();
    await updateSharedPreferences(itemsList);
  }

  updateItemsList(List<MemoItem> newList) async {
    itemsList = newList;
    notifyListeners();
    await updateSharedPreferences(itemsList);
  }

  setColorsList(
      Color highlight, Color secondary, Color background, Color text) {
    colorsList = [highlight, secondary, background, text];
    notifyListeners();
  }
}

class MemoItem {
  String value;
  String key;
  DateTime createdDate, notificationDate;
  bool isFavorite;
  MemoItem({
    @required this.value,
    @required this.isFavorite,
    @required this.createdDate,
    @required this.notificationDate,
    @required this.key,
  });

  get getValue => value;
  get getCreatedDate => createdDate;
  get getNotificationDate => notificationDate;
  get getIsFavorite => isFavorite;
  get getKey => key;

  //Map型に変換
  var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
  Map toJson() => {
        'value': value,
        'key': key,
        //'createdDate': createdDate.toString(),
        //'notificationDate': notificationDate.toString(),
        'createdDate': formatter.format(createdDate),
        'notificationDate': notificationDate != null
            ? formatter.format(notificationDate)
            : null,
        'isFavorite': isFavorite,
      };

  //JSONオブジェクトを代入
  MemoItem.fromJson(Map json)
      : value = json['value'],
        key = json['key'],
        createdDate = DateTime.parse(json['createdDate']),
        notificationDate = json['notificationDate'] != null
            ? DateTime.parse(json['notificationDate'])
            : null,
        isFavorite = json['isFavorite'];
}
