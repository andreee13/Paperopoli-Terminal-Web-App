// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flash/flash.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/core/constants/ui.dart';
import 'package:paperopoli_terminal/core/utils/packages/flutter-countup/lib/countup.dart';
import 'package:paperopoli_terminal/core/utils/utils.dart';
import 'package:paperopoli_terminal/cubits/ships/ships_cubit.dart';
import 'package:paperopoli_terminal/data/models/ship/ship_model.dart';
import 'package:paperopoli_terminal/data/models/ship/ship_status.dart';
import 'package:paperopoli_terminal/presentation/screens/home_screen.dart';

import '../loading_indicator.dart';

class ShipsWidget extends StatefulWidget {
  const ShipsWidget({Key? key}) : super(key: key);

  @override
  ShipsWidgetState createState() => ShipsWidgetState();
}

class ShipsWidgetState extends State<ShipsWidget> {
  late List<ShipModel> _ships;
  final TextEditingController _descriptionTextController =
      TextEditingController();
  final TextEditingController _newStateDateTimeController =
      TextEditingController();
  late final TextEditingController _searchTextController =
      TextEditingController()..addListener(() => setState(() {}));
  ShipModel? _shipToEdit;
  List<String> _types = [];
  List _statusNames = [];
  dynamic _currentStatusName;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _descriptionTextController.dispose();
    _newStateDateTimeController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  Future _fetch() async {
    await context.read<ShipsCubit>().fetch(
          user: HomeScreen.of(context)!.getUser(),
        );
    _types = await jsonDecode(
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      ).fetchShipTypes().then(
            (value) => value.body,
          ),
    )
        .map<String>(
          (item) => item['nome'] as String,
        )
        .toList();
    _statusNames = await jsonDecode(
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      ).fetchShipsStatusNames().then(
            (value) => value.body,
          ),
    );
  }

  Widget _shipStatusBuilder(int index, setState) =>
      index == _shipToEdit!.status.length
          ? ListTile(
              title: const Text(
                'Nuovo stato',
              ),
              leading: const Icon(
                Icons.add,
              ),
              onTap: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text(
                    'Nuovo stato',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Annulla',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(
                          () => _shipToEdit!.status.add(
                            ShipStatus(
                              timestamp: DateTime.parse(
                                _newStateDateTimeController.text,
                              ),
                              name: _currentStatusName['nome'],
                              nameId: _currentStatusName['ID'],
                              isNew: true,
                              isDeleted: false,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Salva',
                      ),
                    ),
                  ],
                  content: StatefulBuilder(
                    builder: (ctx, setState1) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DateTimePicker(
                          icon: const Padding(
                            padding: EdgeInsets.only(
                              top: 8,
                            ),
                            child: Icon(
                              Icons.calendar_today,
                            ),
                          ),
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2021),
                          lastDate: DateTime(2050),
                          type: DateTimePickerType.dateTime,
                          controller: _newStateDateTimeController,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        DropdownButton<Map<String, dynamic>>(
                          value: _currentStatusName,
                          onChanged: (value) => setState1(
                            () => _currentStatusName = value,
                          ),
                          items: _statusNames
                              .map(
                                (e) => DropdownMenuItem<Map<String, dynamic>>(
                                  value: e,
                                  child: Text(
                                    e['nome'],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : _shipToEdit!.status[index].isDeleted == false
              ? ListTile(
                  leading: Text(
                    _shipToEdit!.status[index].timestamp.toIso8601String().substring(0, 19).replaceAll("T", " "),
                  ),
                  title: Text(
                    _shipToEdit!.status[index].name,
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                    onPressed: () => setState(
                      () => _shipToEdit!.status[index].isDeleted = true,
                    ),
                  ),
                )
              : const SizedBox();

  Widget _getInfoWidgets(int index, ShipModel ship) {
    switch (index) {
      case 0:
        return Text(
          'Tipo: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
      case 1:
        return Text(
          ship.type,
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      case 2:
        return Text(
          'Descrizione: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
      case 3:
        return Text(
          ship.description,
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      case 4:
        return Text(
          'Stato: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
      case 5:
        return Text(
          ship.status.last.name,
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _shipsBuilder(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) =>
      FadeTransition(
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(animation),
          child: GestureDetector(
            onTap: () => setState(
              () {
                _shipToEdit = ShipModel.deepCopy(
                  _ships[index],
                );
                _descriptionTextController.text = _shipToEdit!.description;
                _currentStatusName = _statusNames.first;
              },
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                24,
                16,
                16,
                16,
              ),
              height: 160,
              margin: const EdgeInsets.only(
                right: 24,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: _ships[index].id.toString().contains(
                              _searchTextController.text,
                            ) ||
                        _ships[index].description.toLowerCase().contains(
                              _searchTextController.text.toLowerCase(),
                            ) ||
                        _ships[index].type.toLowerCase().contains(
                              _searchTextController.text.toLowerCase(),
                            ) ||
                        _ships[index].status.last.name.toLowerCase().contains(
                              _searchTextController.text.toLowerCase(),
                            )
                    ? ACCENT_COLORS[index.remainder(ACCENT_COLORS.length)]
                    : Colors.grey.shade100,
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nave #${_ships[index].id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff262539),
                              fontSize: 16,
                            ),
                          ),
                          PopupMenuButton(
                            elevation: 48,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Color(0xff262539),
                            ),
                            onSelected: (value) async {
                              switch (value) {
                                case 0:
                                  return await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      actionsPadding: const EdgeInsets.only(
                                        right: 16,
                                      ),
                                      title: const Text(
                                        'Elimina nave',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            'Annulla',
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                            true,
                                          ),
                                          child: const Text(
                                            'ELIMINA',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.20,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text(
                                              'Eliminando la nave non sarà più visibile in questa sezione e tutti gli stati associati saranno rimossi dal sistema.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ).then(
                                    (value) => value != null && value
                                        ? _deleteShip(
                                            _ships[index],
                                          )
                                        : {},
                                  );
                                default:
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<int>(
                                value: 0,
                                enabled: true,
                                height: 40,
                                child: Text(
                                  'Elimina',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        itemCount: 8,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 8,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                        ),
                        itemBuilder: (context, gridIndex) => _getInfoWidgets(
                          gridIndex,
                          _ships[index],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildAllShipsWidget() => Column(
        key: const ValueKey('Column 1'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 40,
            ),
            child: TextField(
              controller: _searchTextController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Ionicons.search,
                  color: Colors.grey.shade400,
                ),
                hintText: 'Cerca navi',
                contentPadding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  0,
                ),
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Countup(
                    begin: 0,
                    end: _ships.length.toDouble(),
                    duration: const Duration(
                      seconds: 1,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xff262539),
                      fontSize: 40,
                    ),
                  ),
                  const Text(
                    ' Navi',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xff262539),
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  MaterialButton(
                    onPressed: () => context.read<ShipsCubit>().fetch(
                          user: HomeScreen.of(context)!.getUser(),
                        ),
                    elevation: 0,
                    padding: const EdgeInsets.all(16),
                    hoverElevation: 0,
                    highlightElevation: 0,
                    shape: const CircleBorder(),
                    color: const Color(0xffF9F9F9),
                    child: const Icon(
                      Icons.refresh,
                      color: Color(0xff333333),
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Color(0xff333333),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Color(0xff333333),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 48,
            ),
            child: LiveGrid(
              shrinkWrap: true,
              showItemDuration: const Duration(
                milliseconds: 300,
              ),
              showItemInterval: const Duration(
                microseconds: 200,
              ),
              itemCount: _ships.length,
              itemBuilder: _shipsBuilder,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2,
              ),
            ),
          ),
        ],
      );

  Widget _buildShipToEditWidget() => Column(
        key: const ValueKey('Column 2'),
        children: [
          Row(
            children: [
              MaterialButton(
                onPressed: () => setState(
                  () => _shipToEdit = null,
                ),
                elevation: 0,
                padding: const EdgeInsets.all(16),
                hoverElevation: 0,
                highlightElevation: 0,
                shape: const CircleBorder(),
                color: const Color(0xffF9F9F9),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xff333333),
                  size: 24,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Text(
                'Nave #${_shipToEdit!.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xff262539),
                  fontSize: 40,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 64,
              left: 32,
            ),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 10,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              children: [
                Text(
                  'ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _shipToEdit!.id.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Tipo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    fontSize: 18,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: _shipToEdit!.type,
                      onChanged: (value) => setState(
                        () => _shipToEdit!.type = _types
                            .where(
                              (element) => element == value,
                            )
                            .first,
                      ),
                      items: _types
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                Text(
                  'Descrizione',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    fontSize: 18,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: 500,
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: TextField(
                        decoration: getDefaultInputDecoration(
                          'Descrizione',
                        ),
                        controller: _descriptionTextController,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Stati',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    fontSize: 18,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MaterialButton(
                      height: 50,
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 16,
                        right: 16,
                      ),
                      onPressed: () async => await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Chiudi',
                              ),
                            ),
                          ],
                          title: const Text(
                            'Stati',
                          ),
                          content: SizedBox(
                            height: 500,
                            width: 500,
                            child: StatefulBuilder(
                              builder: (context, setState) => ListView.builder(
                                shrinkWrap: true,
                                itemCount: _shipToEdit!.status.length + 1,
                                itemBuilder: (ctx, index) => _shipStatusBuilder(
                                  index,
                                  setState,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: const Text(
                        'VISUALIZZA',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        right: 16,
                      ),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                        elevation: 0,
                        highlightElevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 24,
                        ),
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                        onPressed: () => _editShip(),
                        child: Row(
                          children: const [
                            Icon(
                              Ionicons.save_outline,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Salva',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

  Future _editShip() async {
    if (_shipToEdit!.status.isEmpty ||
        _shipToEdit!.status.where((element) => element.isDeleted).length ==
            _shipToEdit!.status.length) {
      await context.showErrorBar(
        content: const Text(
          'Inserire almeno uno stato',
        ),
      );
    } else {
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .editShip(
            _shipToEdit!..description = _descriptionTextController.text,
          )
          .then(
            (value) async => value.statusCode == HttpStatus.ok
                ? await _fetch().then(
                    (value) {
                      context.showInfoBar(
                        content: const Text(
                          'Nave aggiornata con successo',
                        ),
                      );
                      setState(() {
                        _shipToEdit = null;
                      });
                    },
                  )
                : context.showErrorBar(
                    content: const Text(
                      'Si è verificato un errore',
                    ),
                  ),
          );
    }
  }

  Future _deleteShip(
    ShipModel shipModel,
  ) async =>
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .deleteShip(
            shipModel,
          )
          .then(
            (value) async => value.statusCode == HttpStatus.ok
                ? await _fetch().then(
                    (value) => context.showInfoBar(
                      content: const Text(
                        'Nave eliminata con successo',
                      ),
                    ),
                  )
                : context.showErrorBar(
                    content: const Text(
                      'Si è verificato un errore',
                    ),
                  ),
          );

  @override
  Widget build(BuildContext context) => BlocBuilder<ShipsCubit, ShipsState>(
        builder: (context, shipState) {
          if (shipState is ShipsLoaded) {
            _ships = shipState.ships;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  32,
                  32,
                  56,
                  32,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 500,
                  ),
                  child: _shipToEdit == null
                      ? _buildAllShipsWidget()
                      : _buildShipToEditWidget(),
                ),
              ),
            );
          } else if (shipState is ShipsLoading || shipState is ShipsInitial) {
            return const LoadingIndicator();
          } else {
            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.grey.shade800,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Si è verificato un errore. ',
                          ),
                          TextSpan(
                            text: 'Riprova',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _fetch(),
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
}
