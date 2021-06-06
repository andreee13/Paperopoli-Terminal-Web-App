import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/data/models/category_model.dart';

const bool IS_WEB = kIsWeb;

const String TERMINAL_API_URL = 'http://192.168.0.4/paperopoli_terminal';
//const String TERMINAL_API_URL = 'http://paperopoliterminal.ddns.net/data';

const String OPEN_WEATHER_API_KEY = '3fad3e73d27847a54f8ba8da4f5c8112';

const String VAPID_KEY =
    'BAoc_hlGANox3xfvs0bD515G-gcTQHOJe2-RHaMrazFrO74CrpJNLZ5VfnVv7oIMW39R1Jya8kKWCqnHF7TSIBA';

const List<Color> ACCENT_COLORS = [
  Color(0xffF9FEDF),
  Color(0xffe6fbff),
  Color(0xffF3F1FF),
];

const List<CategoryModel> CATEGORIES = [
  CategoryModel(
    primaryName: 'Dashboard',
    secondaryName: 'Dashboard',
    mainIcon: Ionicons.grid_outline,
  ),
  CategoryModel(
    primaryName: 'Viaggi',
    secondaryName: 'Viaggio',
    mainIcon: Icons.calendar_today_outlined,
  ),
  CategoryModel(
    primaryName: 'Movimentazioni',
    secondaryName: 'Movimentazione',
    mainIcon: Icons.stacked_line_chart_outlined,
  ),
  CategoryModel(
    primaryName: 'Navi',
    secondaryName: 'Nave',
    mainIcon: Ionicons.boat_outline,
  ),
  CategoryModel(
    primaryName: 'Merci',
    secondaryName: 'Merce',
    mainIcon: Ionicons.cube_outline,
  ),
  CategoryModel(
    primaryName: 'Persone',
    secondaryName: 'Persona',
    mainIcon: Ionicons.people_outline,
  ),
  CategoryModel(
    primaryName: 'Veicoli',
    secondaryName: 'Veicolo',
    mainIcon: Ionicons.car_outline,
  ),
];
