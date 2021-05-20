import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';

Color white = Colors.white;
Color black = Colors.black;
Color red = Colors.red;
Color blue = Colors.blue;
Color yellow = Colors.yellow;
Color pink = Colors.pink;
Color lightGrey = Colors.grey[300];
Color lightOrange = Colors.orange[300];

class UserState extends ChangeNotifier {
  List<MemoItem> itemsList;

  setItems(MemoItem item) {
    itemsList.add(item);
    notifyListeners();
  }

  updateItemsList(List<MemoItem> newList) {
    itemsList = newList;
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
  get getIsFavorite => isFavorite;
}
