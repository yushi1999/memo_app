import 'package:flutter/material.dart';
import '../sharedParts.dart';

//int maxLines = 300;

class RuledLineTextField extends StatelessWidget {
  RuledLineTextField(this.globalKeyGetTextField);
  final GlobalKey globalKeyGetTextField;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          CustomPaint(
            painter: TextUnderLinePainter(globalKeyGetTextField, 150),
          ),
          TextField(
            key: globalKeyGetTextField,
            keyboardType: TextInputType.multiline,
            maxLines: 150,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ],
      ),
    );
  }
}

class TextUnderLinePainter extends CustomPainter {
  TextUnderLinePainter(this.globalKeyGetTextField, this.maxLines);
  final GlobalKey globalKeyGetTextField;
  final int maxLines;

  @override
  void paint(Canvas canvas, Size size) {
    //これで描画されているテキストフィールドが取得できる
    final textFieldRenderBox =
        globalKeyGetTextField.currentContext.findRenderObject() as RenderBox;

    final ruledLineWidth = textFieldRenderBox.size.width;
    //TextFieldの高さをmaxLinesの値で割ることで段落１行分の高さを求めている
    final ruledLineSpace = textFieldRenderBox.size.height / maxLines;
    //テキストフィールドにはデフォルトで上部分に12のパディングがつくため(InputDecoration)、
    //最初の罫線の位置もこれに合わせる必要がある。
    const ruledLineContentPadding = 12;

    //maxLines行分の線を引く
    final paint = Paint()
      ..color = lightGrey
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
