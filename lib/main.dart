import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'mainPage.dart';
import 'sharedParts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final UserState userState = UserState();

  @override
  initState() {
    super.initState();
    var rand = new math.Random();
    //int colorIndex = rand.nextInt(colorCombinations.length);
    int colorIndex = 6;
    userState.setColorsList(
        colorCombinations[colorIndex][0],
        colorCombinations[colorIndex][1],
        colorCombinations[colorIndex][2],
        colorCombinations[colorIndex][3]);
    syncDataWithSharedPreferences();
  }

  //SharedPreferencesのデータを読み出しUserStateに代入
  Future syncDataWithSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getStringList('memoItemsList');
    List<MemoItem> itemsList = result != null
        ? result.map((f) => MemoItem.fromJson(json.decode(f))).toList()
        : <MemoItem>[];
    userState.updateItemsList(itemsList);
    //print('syncSharedPreferences: $itemsList');
    itemsList.forEach((item) => print('syncSharedPreferences: $item'));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserState>.value(
      value: userState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false, //デバッグの帯を消す
        title: 'memoApp',
        theme: ThemeData(
          primarySwatch: Colors.grey,
          backgroundColor: Colors.white,
        ),
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ja', 'JP'),
        ],
        home: MainPage(title: 'mainPage'),
      ),
    );
  }
}
