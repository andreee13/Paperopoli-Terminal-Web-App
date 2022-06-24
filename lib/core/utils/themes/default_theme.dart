// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

final ThemeData DEFAULT_THEME = ThemeData(
  fontFamily: 'SFProDisplay',
  scaffoldBackgroundColor: Colors.white,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  dialogTheme: const DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(
          12,
        ),
      ),
    ),
  ),
  visualDensity: VisualDensity.comfortable,
  appBarTheme: const AppBarTheme(
    color: Colors.red,
    elevation: 1,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: const Color(0xff5564E8),
  ),
);
