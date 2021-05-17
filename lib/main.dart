import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mainPage.dart';
import 'sharedParts.dart';

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
        home: MainPage(title: 'mainPage'),
      ),
    );
  }
}
