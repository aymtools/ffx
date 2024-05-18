import 'package:ffx/ffx.dart';
import 'package:flutter/material.dart' as fl;

extension F$AppBar on F {
  fl.PreferredSizeWidget AppBar(
      {fl.Widget? leading, fl.Widget? title, fl.Color? backgroundColor}) {
    return fl.AppBar(
      leading: leading,
      title: title,
      backgroundColor: backgroundColor,
    );
  }
}
