import 'dart:io';

import 'package:flutter/material.dart';

class EfisStyle {
  static const double fieldSize = 170.0;
  static const double paramFieldSize = 100.0;
  static const settingsTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
  );
  static const appbarTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
  );
  static final codeBlockStyle = TextStyle(
    color: Colors.amberAccent,
    fontSize: 20.0,
    fontWeight: FontWeight.normal,
    fontFamily: Platform.isIOS ? 'Courier' : 'monospace',
    backgroundColor: Colors.transparent,
  );
  static const efisPageButtonStyle = TextStyle(
    color: Colors.white,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );
  static const settingsErrorTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
  );
}
