import 'package:flutter/material.dart';
import '../sharedParts.dart';

//int maxLines = 300;

class RuledLineTextField extends StatelessWidget {
  RuledLineTextField(this.globalKeyGetTextField, this.color);
  final GlobalKey globalKeyGetTextField;
  final Color color;
  final int maxLines = 180;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          CustomPaint(
            painter:
                TextUnderLinePainter(globalKeyGetTextField, maxLines, color),
          ),
          TextField(
            maxLength: 2500,
            key: globalKeyGetTextField,
            keyboardType: TextInputType.multiline,
            maxLines: maxLines,
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ],
      ),
    );
  }
}

class TextUnderLinePainter extends CustomPainter {
  TextUnderLinePainter(this.globalKeyGetTextField, this.maxLines, this.color);
  final GlobalKey globalKeyGetTextField;
  final int maxLines;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    //これで描画されているテキストフィールドが取得できる
    final textFieldRenderBox =
        globalKeyGetTextField.currentContext.findRenderObject() as RenderBox;

    final ruledLineWidth = textFieldRenderBox.size.width;
    //TextFieldの高さをmaxLinesの値で割ることで段落１行分の高さを求めている
    final ruledLineSpace = textFieldRenderBox.size.height / maxLines - 0.15;
    //テキストフィールドにはデフォルトで上部分に12のパディングがつくため(InputDecoration)、
    //最初の罫線の位置もこれに合わせる必要がある。
    const ruledLineContentPadding = 12;

    //maxLines行分の線を引く
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var i = 1; i <= maxLines; i++) {
      canvas.drawLine(
          Offset(0, ruledLineSpace * i + ruledLineContentPadding),
          Offset(ruledLineWidth, ruledLineSpace * i + ruledLineContentPadding),
          paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
