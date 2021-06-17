import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/data/models/category_model.dart';
import 'package:paperopoli_terminal/presentation/widgets/views/dashboard_widget.dart';

late final DashboardWidget DASHBOARDWIDGET = DashboardWidget(
  key: DASHBOARDWIDGET_GLOBALKEY,
);

final DASHBOARDWIDGET_GLOBALKEY = GlobalKey<DashboardWidgetState>();


const String TERMINAL_WS_URL = 'wss://paperopoliterminal.ddns.net/ws/';
const String TERMINAL_API_URL = 'https://paperopoliterminal.ddns.net/data';

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
