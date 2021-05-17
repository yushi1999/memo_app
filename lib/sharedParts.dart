import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';

Color white = Colors.white;

class UserState extends ChangeNotifier {}

class MemoItem {
  final String value;
  final String key;
  //DateTime createdDate, notificationDate;
  //bool isFavorite;
  //_MemoItem(value, createdDate, isFavorite);
  MemoItem(this.value, this.key);

  get getValue => value;
}
