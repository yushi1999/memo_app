import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expandable/expandable.dart';
import 'sharedParts.dart';
import 'createMemoPage.dart';
import 'widgets/reorderable_list_simple.dart';
import 'widgets/customExpansionTile.dart';
import 'dart:math' as math;

class SettingPage extends StatefulWidget {
  @override
  State createState() {
    return SettingPageState();
  }
}

class SettingPageState extends State<SettingPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _nameController = TextEditingController();
  String _name;
  @override
  void initState() {
    super.initState();
    getName().then((value) {
      setState(() {
        _name = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0.0,
        title: Text(
          "設定",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 24,
          ),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_name',
              style: TextStyle(fontSize: 32),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(hintText: '名前を入力してね'),
            ),
            RaisedButton(
              child: Text('保存'),
              onPressed: () {
                setName().then((success) {
                  _nameController.clear();
                });
              },
            ),
            RaisedButton(
              child: Text('削除'),
              onPressed: () {
                removeName();
              },
            ),
          ],
        ),
      )),
    );
  }

  setName() async {
    SharedPreferences prefs = await _prefs;
    prefs.setString('name', _nameController.text);
    setState(() {
      _name = prefs.getString('name');
    });
  }

  getName() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getString('name');
  }

  removeName() async {
    SharedPreferences prefs = await _prefs;
    prefs.remove('name');
    setState(() {
      _name = null;
    });
  }
}
