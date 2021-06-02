import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:date_format/date_format.dart';
import 'sharedParts.dart';
import 'widgets/ruledLineTextField.dart';
import 'package:timezone/timezone.dart' as tz;

class CreateMemoPage extends StatefulWidget {
  CreateMemoPage(this.memoItem, this.index);
  final MemoItem memoItem;
  final int index;
  @override
  _CreateMemoPageState createState() =>
      new _CreateMemoPageState(memoItem, index);
}

class _CreateMemoPageState extends State<CreateMemoPage> {
  _CreateMemoPageState(this.memoItem, this.index);
  final MemoItem memoItem;
  final int index;
  bool isMemoAlreadyCreated;
  String value;
  DateTime notificationDate;
  bool isFavorite, isRemindValid;

  final globalKeyGetTextField = GlobalKey();
  var _textController;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // 追加

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

  //通知IDを作成して返す
  Future<int> _createNotificationKey(DateTime notificationDate) async {
    List<int> existingIdList = [];
    List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    p.forEach((value) {
      existingIdList.add(value.id);
    });
    int day = notificationDate.day;
    int hour = notificationDate.hour;
    int minute = notificationDate.minute;
    //日、時間、分を足した数字をIDにする
    int newId = day + hour + minute;
    while (existingIdList.contains(newId)) {
      newId += 1;
    }
    return newId;
  }

  // スケジュールに新しい通知を追加
  Future<void> _createNewNotification(MemoItem memoItem) async {
    var tzScheduleNotificationDateTime =
        tz.TZDateTime.from(memoItem.getNotificationDate, tz.local);

    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 1',
      'CHANNEL_NAME 1',
      "CHANNEL_DESCRIPTION 1",
      icon: 'app_icon',
      //sound: RawResourceAndroidNotificationSound('my_sound'),
      largeIcon: DrawableResourceAndroidBitmap('app_icon'),
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails(
        //sound: 'my_sound.aiff',
        );
    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );

    final int newId = memoItem.getnotificationId;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      newId,
      memoItem.value,
      memoItem.value,
      tzScheduleNotificationDateTime,
      platformChannelSpecifics,
      payload: 'Test Payload',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      //matchDateTimeComponents: DateTimeComponents.,
    );
    print('Notification was created. id:' + newId.toString());
  }

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    Color highlightColor = userState.colorsList[0];
    Color secondaryColor = userState.colorsList[1];
    Color backgroundColor = userState.colorsList[2];
    Color textColor = userState.colorsList[3];

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
        notificationId: isRemindValid
            ? await _createNotificationKey(notificationDate)
            : null,
        notificationDate: isRemindValid ? notificationDate : null,
        key: now.toString() + keyWord,
      );

      //新規作成時
      if (!isMemoAlreadyCreated) {
        //テキストが打ち込まれている場合のみ保存
        if (_textController.text.length > 0) {
          userState.setItems(newItem);
          //通知が設定されている場合はスケジュールに追加
          if (isRemindValid) {
            await _createNewNotification(newItem);
          }
        }
      }
      //編集時
      else {
        //テキスト、お気に入り、通知のデータに変化がある時
        if (newItem.value != memoItem.getValue ||
            newItem.isFavorite != memoItem.isFavorite ||
            newItem.notificationDate != memoItem.notificationDate) {
          List<MemoItem> itemsList = userState.itemsList;
          itemsList[index] = newItem;
          userState.updateItemsList(itemsList);
          if (isRemindValid &&
              newItem.notificationDate.isAfter(DateTime.now())) {
            //通知が新たに設定された時
            if (memoItem.notificationDate == null &&
                newItem.notificationDate != null) {
              await _createNewNotification(newItem);
            } //通知の時間が変更された時
            else if (memoItem.notificationDate != newItem.notificationDate &&
                newItem.notificationDate != null) {
              newItem.updateNotificationId(memoItem.getnotificationId);
              await _createNewNotification(newItem);
            }
          } else {
            if (memoItem.notificationDate != null &&
                newItem.notificationDate == null &&
                memoItem.notificationDate.isAfter(DateTime.now())) {
              //指定したIDの通知を消去
              await flutterLocalNotificationsPlugin
                  .cancel(memoItem.getnotificationId);
            }
          }
        }
      }
      Navigator.of(context).pop();
      return true;
    }

    return WillPopScope(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0.0,
          title: Text(
            isMemoAlreadyCreated ? 'メモを編集' : '新規作成',
            style: GoogleFonts.mPlus1p(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: textColor,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 24,
              color: textColor,
            ),
            onPressed: () async {
              await _willPopCallback();
            },
          ),
          actions: [
            favoriteButton(highlightColor),
            remindButton(secondaryColor),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              child: Column(
                children: [
                  if (isRemindValid) remindSettings(),
                  //罫線付き入力フォーム
                  ruledLineInput(textColor, secondaryColor),
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
  Widget favoriteButton(Color highlightColor) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: highlightColor,
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
  Widget remindButton(Color secondaryColor) {
    return IconButton(
      icon: Icon(
        isRemindValid ? Icons.notifications : Icons.notifications_outlined,
        color: secondaryColor,
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

  //通知の設定フォーム
  //通知が単発か、毎日か、毎週かをチェックボックスで選択するのと時刻を選択できるようにする
  Widget remindSettings() {
    return Container(
      child: Text(
        'リマインド  ' +
            formatDate(
              notificationDate,
              [mm, '/', dd, ' ', HH, ':', nn, ''],
            ),
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  //罫線付き入力フォーム
  Widget ruledLineInput(textColor, secondaryColor) {
    return Stack(
      children: <Widget>[
        CustomPaint(
          painter:
              TextUnderLinePainter(globalKeyGetTextField, 150, secondaryColor),
        ),
        TextField(
          controller: _textController,
          style: TextStyle(
            fontSize: 20,
            color: textColor,
          ),
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
