import 'dart:convert';
import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/core/constants/constants.dart';
import 'package:paperopoli_terminal/core/models/main_model_abstract.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/core/utils/utils.dart';
import 'package:paperopoli_terminal/data/models/category_model.dart';
import 'package:paperopoli_terminal/data/models/good/good_model.dart';
import 'package:paperopoli_terminal/data/models/operation/operation_model.dart';
import 'package:paperopoli_terminal/data/models/operation/operation_status.dart';
import 'package:paperopoli_terminal/data/models/person/person_model.dart';
import 'package:paperopoli_terminal/data/models/ship/ship_model.dart';
import 'package:paperopoli_terminal/data/models/trip/trip_model.dart';
import 'package:paperopoli_terminal/data/models/vehicle/vehicle_model.dart';
import 'package:paperopoli_terminal/data/repositories/goods_repository.dart';
import 'package:paperopoli_terminal/data/repositories/people_repository.dart';
import 'package:paperopoli_terminal/data/repositories/ships_repository.dart';
import 'package:paperopoli_terminal/data/repositories/trips_repository.dart';
import 'package:paperopoli_terminal/data/repositories/vehicles_repository.dart';
import 'package:paperopoli_terminal/presentation/screens/home_screen.dart';
import 'package:paperopoli_terminal/presentation/widgets/loading_indicator.dart';
import 'package:flash/flash.dart';
import 'package:search_choices/search_choices.dart';

class CreateOperationWidget extends StatefulWidget {
  @override
  _CreateOperationWidgetState createState() => _CreateOperationWidgetState();
}

class _CreateOperationWidgetState extends State<CreateOperationWidget> {
  late final OperationModel _operationToCreate;
  List<String> _types = [];
  List _statusNames = [];
  var _currentStatusName;
  final TextEditingController _idTextController = TextEditingController();
  final TextEditingController _descriptionTextController =
      TextEditingController();
  final TextEditingController _newStateDateTimeController =
      TextEditingController();
  List<ShipModel> _shipsAll = [];
  List<GoodModel> _goodsAll = [];
  List<PersonModel> _peopleAll = [];
  List<VehicleModel> _vehiclesAll = [];
  List<TripModel> _tripsAll = [];
  var _currentNewItem;

  @override
  void dispose() {
    _descriptionTextController.dispose();
    _newStateDateTimeController.dispose();
    super.dispose();
  }

  Future _fetch() async {
    if (_types.isEmpty || _statusNames.isEmpty) {
      try {
        _types = await jsonDecode(
          await ServerService(
            HomeScreen.of(context)!.getUser(),
          ).fetchOperationTypes().then(
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
          ).fetchOperationsStatusNames().then(
                (value) => value.body,
              ),
        );
        _shipsAll = await ShipsRepository().fetch(
          user: HomeScreen.of(context)!.getUser(),
        );
        _goodsAll = await GoodsRepository().fetch(
          user: HomeScreen.of(context)!.getUser(),
        );
        _peopleAll = await PeopleRepository().fetch(
          user: HomeScreen.of(context)!.getUser(),
        );
        _vehiclesAll = await VehiclesRepository().fetch(
          user: HomeScreen.of(context)!.getUser(),
        );
        _tripsAll = await TripsRepository().fetch(
          user: HomeScreen.of(context)!.getUser(),
        );
        _operationToCreate = OperationModel(
          status: [],
          type: _types.first,
          description: '',
          goods: [],
          people: [],
          ships: [],
          trip: _tripsAll.first.id,
          vehicles: [],
        );
      } catch (e) {
        HomeScreen.of(context)!.setCreatingMode(1);
        await context.showErrorBar(
          content: Text(
            'Si è verificato un errore',
          ),
        );
      }
    }
  }

  Widget _operationStatusBuilder(int index, setState) =>
      index == _operationToCreate.status.length
          ? ListTile(
              title: Text(
                'Nuovo stato',
              ),
              leading: Icon(
                Icons.add,
              ),
              onTap: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'Nuovo stato',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Annulla',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(
                          () => _operationToCreate.status.add(
                            OperationStatus(
                              timestamp: DateTime.parse(
                                _newStateDateTimeController.text,
                              ),
                              name: _currentStatusName['nome'],
                              name_id: _currentStatusName['ID'],
                              isNew: true,
                              isDeleted: false,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Salva',
                      ),
                    ),
                  ],
                  content: StatefulBuilder(
                    builder: (ctx, setState1) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DateTimePicker(
                          icon: Padding(
                            padding: const EdgeInsets.only(
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
                        SizedBox(
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
          : ListTile(
              leading: Text(
                '${_operationToCreate.status[index].timestamp.toIso8601String().substring(0, 19).replaceAll("T", " ")}',
              ),
              title: Text(
                _operationToCreate.status[index].name,
              ),
              trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: () => setState(
                        () => _operationToCreate.status.removeAt(index),
                      )),
            );

  Future _createOperation() async {
    if (_operationToCreate.status.isEmpty) {
      await context.showErrorBar(
        content: Text(
          'Inserire almeno uno stato',
        ),
      );
    } else {
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .createOperation(
        _operationToCreate
          ..description = _descriptionTextController.text
          ..id = _idTextController.text == ''
              ? null
              : int.parse(
                  _idTextController.text,
                ),
      )
          .then(
        (value) {
          print(value.body);
          if (value.statusCode == HttpStatus.ok) {
            context.showSuccessBar(
              content: Text(
                'Movimentazione creata con successo',
              ),
            );
            HomeScreen.of(context)!.setCreatingMode(0);
          } else {
            context.showErrorBar(
              content: Text(
                'Si è verificato un errore',
              ),
            );
          }
        },
      );
    }
  }

  Widget _operationItemsBuilder(
    int index,
    setState,
    List<int> items,
    List<MainModel> allItems,
    CategoryModel category,
  ) =>
      index == items.length
          ? allItems
                  .where(
                    (element) => !items.contains(element.id!),
                  )
                  .isNotEmpty
              ? ListTile(
                  title: Text(
                    'Aggiungi',
                  ),
                  leading: Icon(
                    Icons.add,
                  ),
                  onTap: () {
                    _currentNewItem = null;
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          'Aggiungi',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Annulla',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(
                                () => _currentNewItem != null
                                    ? items.add(_currentNewItem!.id!)
                                    : {},
                              );
                            },
                            child: Text(
                              'Salva',
                            ),
                          ),
                        ],
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${allItems.length} elementi totali',
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                              ),
                              child: SearchChoices<MainModel>.single(
                                value: _currentNewItem,
                                hint: category.primaryName,
                                searchHint: 'Cerca',
                                onChanged: (value) => setState(() {
                                  _currentNewItem = value;
                                }),
                                closeButton: 'Chiudi',
                                isExpanded: true,
                                searchFn: (String keyword,
                                    List<DropdownMenuItem<MainModel>> items) {
                                  var v = items
                                      .where(
                                        (element) =>
                                            element.value!.id
                                                .toString()
                                                .contains(
                                                  keyword,
                                                ) ||
                                            element.value!.description
                                                .toLowerCase()
                                                .contains(
                                                  keyword.toLowerCase(),
                                                ),
                                      )
                                      .toList();
                                  var t = <int>[];
                                  v.forEach((element) {
                                    t.add(
                                      items.indexOf(
                                        element,
                                      ),
                                    );
                                  });
                                  return t;
                                },
                                items: allItems
                                    .where(
                                      (element) => !items.contains(element.id!),
                                    )
                                    .map(
                                      (e) => DropdownMenuItem<MainModel>(
                                        value: e,
                                        child: ListTile(
                                          leading: Icon(
                                            category.mainIcon,
                                          ),
                                          title: Text(
                                            '${category.secondaryName} #${e.id}',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          subtitle: Text(
                                            e.description,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : SizedBox()
          : ListTile(
              leading: Icon(
                category.mainIcon,
              ),
              title: Text(
                '${category.secondaryName} #${items[index]}',
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                ),
                onPressed: () => setState(
                  () => items.removeAt(
                    index,
                  ),
                ),
              ),
            );

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          32,
          32,
          56,
          32,
        ),
        child: FutureBuilder(
          future: _fetch(),
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.done
              ? Column(
                  children: [
                    Row(
                      children: [
                        MaterialButton(
                          onPressed: () =>
                              HomeScreen.of(context)!.setCreatingMode(0),
                          elevation: 0,
                          padding: const EdgeInsets.all(16),
                          hoverElevation: 0,
                          highlightElevation: 0,
                          shape: CircleBorder(),
                          color: Color(0xffF9F9F9),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xff333333),
                            size: 24,
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          'Nuova movimentazione',
                          style: TextStyle(
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 50,
                                width: 200,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                ),
                                child: TextField(
                                  decoration: getDefaultInputDecoration(
                                    'ID',
                                  ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]'),
                                    ),
                                  ],
                                  controller: _idTextController,
                                ),
                              ),
                            ],
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
                                value: _operationToCreate.type,
                                onChanged: (value) => setState(
                                  () => _operationToCreate.type = _types
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
                                          style: TextStyle(
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
                            'Viaggio',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                              fontSize: 18,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButton<int>(
                                value: _operationToCreate.trip,
                                onChanged: (value) => setState(
                                  () => _operationToCreate.trip = _tripsAll
                                      .where(
                                        (element) => element.id == value,
                                      )
                                      .first
                                      .id,
                                ),
                                items: _tripsAll
                                    .map(
                                      (e) => DropdownMenuItem<int>(
                                        value: e.id,
                                        child: Text(
                                          e.id.toString(),
                                          style: TextStyle(
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
                            'Navi',
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
                                        child: Text(
                                          'Chiudi',
                                        ),
                                      ),
                                    ],
                                    title: Text(
                                      'Navi',
                                    ),
                                    content: Container(
                                      height: 500,
                                      width: 500,
                                      child: StatefulBuilder(
                                        builder: (context, setState) =>
                                            ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              _operationToCreate.ships.length +
                                                  1,
                                          itemBuilder: (ctx, index) =>
                                              _operationItemsBuilder(
                                            index,
                                            setState,
                                            _operationToCreate.ships,
                                            _shipsAll,
                                            CATEGORIES[3],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'VISUALIZZA',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Merci',
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
                                        child: Text(
                                          'Chiudi',
                                        ),
                                      ),
                                    ],
                                    title: Text(
                                      'Merci',
                                    ),
                                    content: Container(
                                      height: 500,
                                      width: 500,
                                      child: StatefulBuilder(
                                        builder: (context, setState) =>
                                            ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              _operationToCreate.goods.length +
                                                  1,
                                          itemBuilder: (ctx, index) =>
                                              _operationItemsBuilder(
                                            index,
                                            setState,
                                            _operationToCreate.goods,
                                            _goodsAll,
                                            CATEGORIES[4],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'VISUALIZZA',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Persone',
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
                                        child: Text(
                                          'Chiudi',
                                        ),
                                      ),
                                    ],
                                    title: Text(
                                      'Persone',
                                    ),
                                    content: Container(
                                      height: 500,
                                      width: 500,
                                      child: StatefulBuilder(
                                        builder: (context, setState) =>
                                            ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              _operationToCreate.people.length +
                                                  1,
                                          itemBuilder: (ctx, index) =>
                                              _operationItemsBuilder(
                                            index,
                                            setState,
                                            _operationToCreate.people,
                                            _peopleAll,
                                            CATEGORIES[5],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'VISUALIZZA',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Veicoli',
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
                                        child: Text(
                                          'Chiudi',
                                        ),
                                      ),
                                    ],
                                    title: Text(
                                      'Veicoli',
                                    ),
                                    content: Container(
                                      height: 500,
                                      width: 500,
                                      child: StatefulBuilder(
                                        builder: (context, setState) =>
                                            ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _operationToCreate
                                                  .vehicles.length +
                                              1,
                                          itemBuilder: (ctx, index) =>
                                              _operationItemsBuilder(
                                            index,
                                            setState,
                                            _operationToCreate.vehicles,
                                            _vehiclesAll,
                                            CATEGORIES[6],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'VISUALIZZA',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
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
                                        child: Text(
                                          'Chiudi',
                                        ),
                                      ),
                                    ],
                                    title: Text(
                                      'Stati',
                                    ),
                                    content: Container(
                                      height: 500,
                                      width: 500,
                                      child: StatefulBuilder(
                                        builder: (context, setState) =>
                                            ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              _operationToCreate.status.length +
                                                  1,
                                          itemBuilder: (ctx, index) =>
                                              _operationStatusBuilder(
                                            index,
                                            setState,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'VISUALIZZA',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(),
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
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.8),
                                  onPressed: () => _createOperation(),
                                  child: Row(
                                    children: [
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
                )
              : LoadingIndicator(),
        ),
      );
}
