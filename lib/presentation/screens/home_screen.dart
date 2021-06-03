import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/core/utils/constants.dart';
import 'package:paperopoli_terminal/cubits/authentication/authentication_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperopoli_terminal/data/models/category_model.dart';
import 'package:paperopoli_terminal/presentation/widgets/categories/goodsWidget.dart';
import 'package:paperopoli_terminal/presentation/widgets/categories/people_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/categories/shipsWidget.dart';
import 'package:paperopoli_terminal/presentation/widgets/categories/vehiclesWidget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_good_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_operation_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_person_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_ship_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_trip_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_vehicle_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/views/operationsWidget.dart';
import 'package:paperopoli_terminal/presentation/widgets/views/dashboardWidget.dart';
import 'package:paperopoli_terminal/presentation/widgets/views/tripsWidget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();

  static _HomeScreenState? of(
    BuildContext context,
  ) =>
      context.findAncestorStateOfType<_HomeScreenState>();
}

class _HomeScreenState extends State<HomeScreen> {
  CategoryModel _selectedCategory = CATEGORIES[0];
  int _inCreatingMode = 0;
  Widget? _createWidget;

  void setCreatingMode(int i) => setState(
        () => _inCreatingMode = i,
      );

  User getUser() =>
      (context.read<AuthenticationCubit>().state as AuthenticationLogged).user!;

  Widget _buildCategories(
    BuildContext _,
    int index,
  ) =>
      index == 0
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSeparator(_, 6),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    0,
                    8,
                  ),
                  child: ListTile(
                    title: Text(
                      CATEGORIES[index].name,
                      style: TextStyle(
                        color: _selectedCategory == CATEGORIES[index]
                            ? Colors.white
                            : Color(0xff909399),
                      ),
                    ),
                    leading: Icon(
                      CATEGORIES[index].mainIcon,
                      color: _selectedCategory == CATEGORIES[index]
                          ? Colors.white
                          : Color(0xff909399),
                    ),
                    selected: _selectedCategory == CATEGORIES[index],
                    hoverColor: Colors.white10,
                    selectedTileColor: Colors.white10,
                    onTap: () {
                      setState(() {
                        _inCreatingMode = 0;
                        _selectedCategory = CATEGORIES[index];
                      });
                    },
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                0,
                8,
              ),
              child: ListTile(
                title: Text(
                  CATEGORIES[index].name,
                  style: TextStyle(
                    color: _selectedCategory == CATEGORIES[index]
                        ? Colors.white
                        : Color(0xff909399),
                  ),
                ),
                leading: Icon(
                  CATEGORIES[index].mainIcon,
                  color: _selectedCategory == CATEGORIES[index]
                      ? Colors.white
                      : Color(0xff909399),
                ),
                selected: _selectedCategory == CATEGORIES[index],
                hoverColor: Colors.white10,
                selectedTileColor: Colors.white10,
                onTap: () {
                  setState(() {
                    _inCreatingMode = 0;
                    _selectedCategory = CATEGORIES[index];
                  });
                },
              ),
            );

  Widget _buildSeparator(
    BuildContext _,
    int index,
  ) =>
      index == 2 || index == 6
          ? Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 24,
                  right: 32,
                ),
                child: Text(
                  index == 2 ? 'CATEGORIE' : 'VISTE',
                  style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            )
          : SizedBox();

  Widget _getCreateWidgetWidget(String s) {
    switch (s) {
      case 'Viaggio':
        return CreateTripWidget();
      case 'Movimentazione':
        return CreateOperationWidget();
      case 'Nave':
        return CreateShipWidget();
      case 'Merce':
        return CreateGoodWidget();
      case 'Persona':
        return CreatePersonWidget();
      case 'Veicolo':
        return CreateVehicleWidget();
      default:
        return SizedBox();
    }
  }

  Widget _buildMainWidget() {
    switch (_selectedCategory.name) {
      case 'Dashboard':
        return DashboardWidget();
      case 'Viaggi':
        return TripsWidget();
      case 'Movimentazioni':
        return OperationsWidget();
      case 'Navi':
        return ShipsWidget();
      case 'Merci':
        return GoodsWidget();
      case 'Persone':
        return PeopleWidget();
      case 'Veicoli':
        return VehiclesWidget();
      default:
        return SizedBox();
    }
  }

  Widget _buildCreateWidget() => AnimatedSwitcher(
        duration: Duration(
          milliseconds: 500,
        ),
        child: _inCreatingMode == 1
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNewItemWidget(
                          Icons.calendar_today_outlined,
                          'Viaggio',
                        ),
                        _buildNewItemWidget(
                          Icons.stacked_line_chart_outlined,
                          'Movimentazione',
                        ),
                        _buildNewItemWidget(
                          Ionicons.boat_outline,
                          'Nave',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNewItemWidget(
                          Ionicons.cube_outline,
                          'Merce',
                        ),
                        _buildNewItemWidget(
                          Ionicons.people_outline,
                          'Persona',
                        ),
                        _buildNewItemWidget(
                          Ionicons.car_outline,
                          'Veicolo',
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : _createWidget,
      );

  Widget _buildNewItemWidget(
    IconData icon,
    String title,
  ) =>
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: MaterialButton(
          minWidth: 210,
          height: 210,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Color(0xffF9F9F9),
          onPressed: () => setState(
            () {
              _inCreatingMode = 2;
              _createWidget = _getCreateWidgetWidget(
                title,
              );
            },
          ),
          child: Column(
            children: [
              Icon(
                icon,
              ),
              SizedBox(
                height: 24,
              ),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(
            () => _inCreatingMode == 1 || _inCreatingMode == 2
                ? _inCreatingMode = 0
                : _inCreatingMode = 1,
          ),
          backgroundColor: _inCreatingMode == 1 || _inCreatingMode == 2
              ? Colors.red.withOpacity(0.9)
              : Color(0xff5564E8),
          child: Icon(
            _inCreatingMode == 1 || _inCreatingMode == 2
                ? Icons.close
                : Icons.add,
            color: Colors.white,
          ),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Drawer(
              elevation: 0,
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: Material(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox.expand(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 32,
                      ),
                      child: Material(
                        color: Color(0xff242342),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        8,
                        48,
                        16,
                      ),
                      child: Image.asset(
                        'assets/images/ship_icon_white.png',
                        height: 125,
                        width: 125,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 140,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: _buildSeparator,
                        itemBuilder: _buildCategories,
                        itemCount: CATEGORIES.length,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 32,
                        bottom: 32,
                      ),
                      child: MaterialButton(
                        onPressed: () async => await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              'Logout',
                            ),
                            content: Text(
                              'Vuoi davverro effetuare il logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(
                                  context,
                                  false,
                                ),
                                child: Text(
                                  'Annulla',
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(
                                  context,
                                  true,
                                ),
                                child: Text(
                                  'Logout',
                                ),
                              ),
                            ],
                          ),
                        ).then(
                          (value) async => value
                              ? await context
                                  .read<AuthenticationCubit>()
                                  .logOut()
                              : {},
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.white70,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(
                  milliseconds: 500,
                ),
                child: _inCreatingMode == 1 || _inCreatingMode == 2
                    ? _buildCreateWidget()
                    : _buildMainWidget(),
              ),
            ),
          ],
        ),
      );
}
