import 'package:ffx/ffx.dart';
import 'package:flutter/material.dart';

// @FxWidget()
// Widget _app() {
//   return Text('App');
// }

@FxWidget()
Widget _simpleText({required X x, required String text, int? fontSize}) {
  return Text(text);
}

// //不支持无法自动加入 Modifier modifier 放到最后不太合适
// @FxWidget()
// Widget _simpleText(String text2, X x, [String text = '', int? fontSize]) {
//   return Text(text);
// }

//
// class _SimpleTextWidget extends XWidget {
//   final Modifier modifier;
//   final String text;
//
//   const _SimpleTextWidget(
//       {super.key, this.modifier = Modifior, required this.text});
//
//   @override
//   Widget build() {
//     return modifier.apply(SimpleText(text: text));
//   }
// }
//
// extension WExt$SimpleText on X {
//   Widget SimpleText({Modifier modifier = Modifior, required String text}) =>
//       _SimpleTextWidget(
//           key: ParametersKey([text], 'SimpleText'),
//           modifier: modifier,
//           text: text);
// }
//

// Widget SimpleText({
//   Modifier modifier = Modifior,
//   required String text,
//   int? fontSize,
// }) =>
//     FXWidget(
//         key: FXKey("SimpleText", [
//           text,
//           fontSize,
//         ]),
//         builder: (x) => modifier.apply(_simpleText(
//               text: text,
//               fontSize: fontSize,
//             )));
// Widget SimpleText(
//   String text2, {
//   Modifier modifier = Modifior,
//   required String text,
//   int? fontSize,
// }) =>
//     FXWidget(
//         key: FXKey("SimpleText", [
//           text2,
//           text,
//           fontSize,
//         ]),
//         builder: (x) => modifier.apply(_simpleText(
//               text2,
//               x,
//               x2: x,
//               text: text,
//               fontSize: fontSize,
//             )));
