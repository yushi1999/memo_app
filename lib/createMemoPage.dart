import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'sharedParts.dart';
import 'widgets/reorderable_list_simple.dart';

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
  DateTime dateTime;
  bool isFavorite;

  @override
  initState() {
    super.initState();
    if (memoItem == null)
      isMemoAlreadyCreated = false;
    else
      isMemoAlreadyCreated = true;
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          ),
        ),
      ),
    );
  }
}
