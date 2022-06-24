import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/core/constants/ui.dart';
import 'package:paperopoli_terminal/cubits/authentication/authentication_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperopoli_terminal/data/models/category_model.dart';
import 'package:paperopoli_terminal/presentation/widgets/categories/goods_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/categories/people_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/categories/ships_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/categories/vehicles_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_good_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_operation_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_person_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_ship_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_trip_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/creation/create_vehicle_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/views/operations_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/views/dashboard_widget.dart';
import 'package:paperopoli_terminal/presentation/widgets/views/trips_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();

  static HomeScreenState? of(
    BuildContext context,
  ) =>
      context.findAncestorStateOfType<HomeScreenState>();
}

class HomeScreenState extends State<HomeScreen> {
  CategoryModel _selectedCategory = CATEGORIES[0];
  int _inCreatingMode = 0;
  Widget? _createWidget;

  void setCreatingMode(int i) => setState(
        () => _inCreatingMode = i,
      );

  User getUser() => (context.read<AuthenticationCubit>().state as AuthenticationLogged).user!;

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
                      CATEGORIES[index].primaryName,
                      style: TextStyle(
                        color: _selectedCategory == CATEGORIES[index]
                            ? Colors.white
                            : const Color(0xff909399),
                      ),
                    ),
                    leading: Icon(
                      CATEGORIES[index].mainIcon,
                      color: _selectedCategory == CATEGORIES[index]
                          ? Colors.white
                          : const Color(0xff909399),
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
                  CATEGORIES[index].primaryName,
                  style: TextStyle(
                    color: _selectedCategory == CATEGORIES[index]
                        ? Colors.white
                        : const Color(0xff909399),
                  ),
                ),
                leading: Icon(
                  CATEGORIES[index].mainIcon,
                  color: _selectedCategory == CATEGORIES[index]
                      ? Colors.white
                      : const Color(0xff909399),
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
          : const SizedBox();

  Widget _getCreateWidgetWidget(String s) {
    switch (s) {
      case 'Viaggio':
        return const CreateTripWidget();
      case 'Movimentazione':
        return const CreateOperationWidget();
      case 'Nave':
        return const CreateShipWidget();
      case 'Merce':
        return const CreateGoodWidget();
      case 'Persona':
        return const CreatePersonWidget();
      case 'Veicolo':
        return const CreateVehicleWidget();
      default:
        return const SizedBox();
    }
  }

  Widget _buildMainWidget() {
    switch (_selectedCategory.primaryName) {
      case 'Dashboard':
        return const DashboardWidget();
      case 'Viaggi':
        return const TripsWidget();
      case 'Movimentazioni':
        return const OperationsWidget();
      case 'Navi':
        return const ShipsWidget();
      case 'Merci':
        return const GoodsWidget();
      case 'Persone':
        return const PeopleWidget();
      case 'Veicoli':
        return const VehiclesWidget();
      default:
        return const SizedBox();
    }
  }

  Widget _buildCreateWidget() => AnimatedSwitcher(
        duration: const Duration(
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
          color: const Color(0xffF9F9F9),
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
              const SizedBox(
                height: 24,
              ),
              Text(
                title,
                style: const TextStyle(
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
              : const Color(0xff5564E8),
          child: Icon(
            _inCreatingMode == 1 || _inCreatingMode == 2 ? Icons.close : Icons.add,
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
                  const SizedBox.expand(
                    child: Material(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox.expand(
                    child: Padding(
                      padding: EdgeInsets.only(
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
                        physics: const BouncingScrollPhysics(),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              var currentUser = FirebaseAuth.instance.currentUser!;
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                        context,
                                        true,
                                      ),
                                      child: const Text(
                                        'Logout',
                                      ),
                                    ),
                                  ],
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        minRadius: 30,
                                        backgroundColor: const Color(0xff3A3955),
                                        foregroundColor: Colors.white,
                                        child: Text(
                                          currentUser.displayName!.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 24,
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          currentUser.displayName!,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        currentUser.email!,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Divider(),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'Registrazione:',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                'Ultimo accesso:',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                currentUser.metadata.creationTime!
                                                    .toIso8601String()
                                                    .substring(
                                                      0,
                                                      10,
                                                    ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                currentUser.metadata.lastSignInTime!
                                                    .toIso8601String()
                                                    .substring(
                                                      0,
                                                      10,
                                                    ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ).then(
                                (value) async => value != null
                                    ? await context.read<AuthenticationCubit>().logOut()
                                    : {},
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white10,
                                  foregroundColor: Colors.white,
                                  child: Text(
                                    getUser().displayName!.substring(0, 1).toUpperCase(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                  ),
                                  child: Text(
                                    getUser().displayName!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(
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
