import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expandable/expandable.dart';
import 'package:date_format/date_format.dart';
import 'sharedParts.dart';
import 'settingPage.dart';
import 'createMemoPage.dart';

class ShowNotificationInfo extends StatefulWidget {
  final String frequency;
  final DateTime notificationDate;
  ShowNotificationInfo(this.frequency, this.notificationDate);
  @override
  _ShowNotificationInfoState createState() =>
      new _ShowNotificationInfoState(frequency, notificationDate);
}

class _ShowNotificationInfoState extends State<ShowNotificationInfo> {
  final String frequency;
  final DateTime notificationDate;
  _ShowNotificationInfoState(this.frequency, this.notificationDate);
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);
    double mediaSize = 0.5 * MediaQuery.of(context).size.height;
    return Container(
      height: mediaSize,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Column(
        children: [],
      ),
    );
  }
}
