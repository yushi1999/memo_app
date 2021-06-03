import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'mainPage.dart';
import 'sharedParts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  await setup();
  runApp(MyApp());
}

//タイムゾーンの設定
Future<void> setup() async {
  tz.initializeTimeZones();
  var tokyo = tz.getLocation('Asia/Tokyo');
  tz.setLocalLocation(tokyo);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final UserState userState = UserState();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // 追加

  @override
  initState() {
    super.initState();
    syncDataWithSharedPreferences();
    userState.setColorsList(white, white, white, transparent);
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    _initializePlatformSpecifics();
    //_showNotification();
    //設定した時間後に通知を設定
    //_scheduleNotification();
    //予約済みのローカル通知の数を取得
    _getPendingNotificationCount().then((value) =>
        debugPrint('getPendingNotificationCount:' + value.toString()));
    //通知をキャンセル
    //_cancelNotification().then((value) => debugPrint('cancelNotification'));
  }

  void _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
          alert: false,
          badge: true,
          sound: false,
        );
  }

  void _initializePlatformSpecifics() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // your call back to the UI
      },
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      //onNotificationClick(payload); // your call back to the UI
    });
  }

  Future<int> _getPendingNotificationCount() async {
    List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    p.forEach((value) {
      print('pendingNotificationRequests' + value.id.toString());
    });
    return p.length;
  }

  //SharedPreferencesのデータを読み出しUserStateに代入
  Future syncDataWithSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var memoItemsList = prefs.getStringList('memoItemsList');

    List<MemoItem> itemsList = memoItemsList != null
        ? memoItemsList.map((f) => MemoItem.fromJson(json.decode(f))).toList()
        : <MemoItem>[];
    userState.updateItemsList(itemsList);
    int themeNumber =
        prefs.getInt('themeNumber') != null ? prefs.getInt('themeNumber') : 0;
    userState.setThemeNumber(themeNumber);
    print('syncThemeNumber: $themeNumber');
    userState.setColorsList(
        colorCombinations[themeNumber][0],
        colorCombinations[themeNumber][1],
        colorCombinations[themeNumber][2],
        colorCombinations[themeNumber][3]);
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
          appBarTheme: AppBarTheme(
            brightness: Brightness.dark,
          ),
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
