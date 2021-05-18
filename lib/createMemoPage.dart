import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
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
  DateTime createdDate, notificationDate;
  bool isFavorite, isRemindValid;

  final globalKeyGetTextField = GlobalKey();

  @override
  initState() {
    super.initState();
    if (memoItem == null)
      isMemoAlreadyCreated = false;
    else
      isMemoAlreadyCreated = true;
    isFavorite = false;
    isRemindValid = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0.0,
        title: Text(
          isMemoAlreadyCreated ? 'メモを編集' : '新規作成',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
          style: TextStyle(fontSize: 20),
          key: globalKeyGetTextField,
          keyboardType: TextInputType.multiline,
          maxLines: 150,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: (String text) {
            setState(() {
              value = text;
            });
          },
        ),
      ],
    );
  }
}
