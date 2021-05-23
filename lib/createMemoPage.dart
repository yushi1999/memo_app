import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_format/date_format.dart';
import 'sharedParts.dart';
import 'widgets/ruledLineTextField.dart';

class CreateMemoPage extends StatefulWidget {
  CreateMemoPage(this.memoItem);
  final MemoItem memoItem;
  @override
  _CreateMemoPageState createState() => new _CreateMemoPageState(memoItem);
}

class _CreateMemoPageState extends State<CreateMemoPage> {
  _CreateMemoPageState(this.memoItem);
  final MemoItem memoItem;
  bool isMemoAlreadyCreated;
  String value;
  DateTime notificationDate;
  bool isFavorite, isRemindValid;

  final globalKeyGetTextField = GlobalKey();
  var _textController;

  @override
  initState() {
    super.initState();
    if (memoItem == null) {
      value = '';
      isMemoAlreadyCreated = false;
      isFavorite = false;
      isRemindValid = false;
    } else {
      isMemoAlreadyCreated = true;
      value = memoItem.getValue;
      notificationDate = memoItem.notificationDate;
      isFavorite = memoItem.isFavorite;
      if (notificationDate == null)
        isRemindValid = false;
      else
        isRemindValid = true;
    }
    _textController = TextEditingController(text: value);
  }

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);

    //メモをUserStateに保存
    Future<bool> _willPopCallback() async {
      var now = DateTime.now();
      var keyWord;
      if (isFavorite) {
        keyWord = 'favorite';
      } else if (isRemindValid) {
        keyWord = 'remind';
      } else {
        keyWord = 'normal';
      }
      var newItem = MemoItem(
        value: _textController.text,
        isFavorite: isFavorite,
        createdDate: now,
        notificationDate: isRemindValid ? notificationDate : null,
        key: now.toString() + keyWord,
      );

      //新規作成時
      if (!isMemoAlreadyCreated) {
        //テキストが打ち込まれている場合のみ保存
        if (_textController.text.length > 0) {
          userState.setItems(newItem);
        }
      }
      //編集時
      else {
        //テキスト、お気に入り、通知のデータに変化がある時
        if (newItem.value != _textController.text ||
            newItem.isFavorite != isFavorite ||
            newItem.notificationDate != notificationDate) {}
      }
      Navigator.of(context).pop();
      return true;
    }

    return WillPopScope(
      child: Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          backgroundColor: white,
          elevation: 0.0,
          title: Text(
            isMemoAlreadyCreated ? 'メモを編集' : '新規作成',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 24,
            ),
            onPressed: () async {
              await _willPopCallback();
            },
          ),
          actions: [
            favoriteButton(),
            remindButton(),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Column(
                children: [
                  if (isRemindValid)
                    Text(
                      'リマインド  ' +
                          formatDate(
                            notificationDate,
                            [mm, '/', dd, ' ', HH, ':', nn, ''],
                          ),
                      style: TextStyle(color: Colors.grey),
                    ),
                  //罫線付き入力フォーム
                  ruledLineInput(),
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: _willPopCallback,
    );
  }

  //お気に入りボタン
  Widget favoriteButton() {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: lightOrange,
        size: 32,
      ),
      onPressed: () {
        setState(() {
          isFavorite = !isFavorite;
        });
      },
    );
  }

  //通知ボタン
  Widget remindButton() {
    return IconButton(
      icon: Icon(
        isRemindValid ? Icons.notifications : Icons.notifications_outlined,
        color: lightOrange,
        size: 32,
      ),
      onPressed: () async {
        var now = DateTime.now();
        var picked;
        if (isRemindValid == false) {
          picked = await DatePicker.showDateTimePicker(
            context,
            minTime: now,
            currentTime: now,
            showTitleActions: true,
            locale: LocaleType.jp,
            onConfirm: (date) {
              notificationDate = date;
            },
          );
        } else {
          setState(() {
            isRemindValid = !isRemindValid;
          });
        }
        if (picked != null)
          setState(() {
            isRemindValid = !isRemindValid;
          });
      },
    );
  }

  //罫線付き入力フォーム
  Widget ruledLineInput() {
    return Stack(
      children: <Widget>[
        CustomPaint(
          painter: TextUnderLinePainter(globalKeyGetTextField, 150),
        ),
        TextField(
          controller: _textController,
          style: TextStyle(fontSize: 20),
          key: globalKeyGetTextField,
          keyboardType: TextInputType.multiline,
          maxLines: 150,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }
}
