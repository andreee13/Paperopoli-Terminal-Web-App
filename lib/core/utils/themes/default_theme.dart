import 'package:flutter/material.dart';

final ThemeData DEFAULT_THEME = ThemeData(
  fontFamily: 'SFProDisplay',
  accentColor: Color(0xff5564E8),
  scaffoldBackgroundColor: Colors.white,
  iconTheme: IconThemeData(
    color: Colors.white,
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(
          12,
        ),
      ),
    ),
  ),
  visualDensity: VisualDensity.comfortable,
  appBarTheme: AppBarTheme(
    color: Colors.red,
    elevation: 1,
  ),
);
