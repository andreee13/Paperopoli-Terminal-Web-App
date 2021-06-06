import 'dart:convert';
import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/core/models/main_model_abstract.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/core/constants/constants.dart';
import 'package:paperopoli_terminal/core/utils/packages/flutter-countup/lib/countup.dart';
import 'package:paperopoli_terminal/core/utils/utils.dart';
import 'package:paperopoli_terminal/cubits/operations/operations_cubit.dart';
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
import 'package:search_choices/search_choices.dart';

import '../loading_indicator.dart';

class OperationsWidget extends StatefulWidget {
  @override
  _OperationsWidgetState createState() => _OperationsWidgetState();
}

class _OperationsWidgetState extends State<OperationsWidget> {
  late List<OperationModel> _operations;
  final TextEditingController _descriptionTextController =
      TextEditingController();
  late final TextEditingController _searchTextController =
      TextEditingController()..addListener(() => setState(() {}));
  final TextEditingController _newStateDateTimeController =
      TextEditingController();
  OperationModel? _operationToEdit;
  List<String> _types = [];
  List _statusNames = [];
  List<ShipModel> _shipsAll = [];
  List<GoodModel> _goodsAll = [];
  List<PersonModel> _peopleAll = [];
  List<VehicleModel> _vehiclesAll = [];
  List<TripModel> _tripsAll = [];
  var _currentStatusName;
  MainModel? _currentNewItem;

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
    await context.read<OperationsCubit>().fetch(
          user: HomeScreen.of(context)!.getUser(),
        );
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
  }

  Widget _operationStatusBuilder(
    int index,
    setState,
  ) =>
      index == _operationToEdit!.status.length
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
                          () => _operationToEdit!.status.add(
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
          : _operationToEdit!.status[index].isDeleted == false
              ? ListTile(
                  leading: Text(
                    '${_operationToEdit!.status[index].timestamp.toIso8601String().substring(0, 19).replaceAll("T", " ")}',
                  ),
                  title: Text(
                    _operationToEdit!.status[index].name,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                    ),
                    onPressed: () => setState(
                      () => _operationToEdit!.status[index].isDeleted = true,
                    ),
                  ),
                )
              : SizedBox();

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

  Widget _getInfoWidgets(
    int index,
    OperationModel operation,
  ) {
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
          operation.type,
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      case 2:
        return Text(
          'Viaggio: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
      case 3:
        return Text(
          '#${operation.trip}',
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      case 4:
        return Text(
          'Descrizione: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
      case 5:
        return Text(
          operation.description,
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      case 6:
        return Text(
          'Stato: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
      case 7:
        return Text(
          operation.status.last.name,
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      default:
        return SizedBox();
    }
  }

  Widget _operationsBuilder(
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
            begin: Offset(0, -0.1),
            end: Offset.zero,
          ).animate(animation),
          child: GestureDetector(
            onTap: () => setState(
              () {
                _operationToEdit = OperationModel.deepCopy(
                  _operations[index],
                );
                _descriptionTextController.text = _operationToEdit!.description;
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
                color: _operations[index].id.toString().contains(
                              _searchTextController.text,
                            ) ||
                        _operations[index].description.toLowerCase().contains(
                              _searchTextController.text.toLowerCase(),
                            ) ||
                        _operations[index].type.toLowerCase().contains(
                              _searchTextController.text.toLowerCase(),
                            ) ||
                        _operations[index]
                            .status
                            .last
                            .name
                            .toLowerCase()
                            .contains(
                              _searchTextController.text.toLowerCase(),
                            ) ||
                        _operations[index].trip.toString().contains(
                              _searchTextController.text,
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
                            'Movimentazione #${_operations[index].id}',
                            style: TextStyle(
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
                            icon: Icon(
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
                                      title: Text(
                                        'Elimina movimentazione',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
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
                                          children: [
                                            Text(
                                              'Eliminando la movimentazione non sarà più visibile in questa sezione e tutti gli stati associati saranno rimossi dal sistema.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ).then(
                                    (value) => value != null && value
                                        ? _deleteOperation(
                                            _operations[index],
                                          )
                                        : {},
                                  );
                                default:
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<int>(
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 8,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                        ),
                        itemBuilder: (context, grid_index) => _getInfoWidgets(
                          grid_index,
                          _operations[index],
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

  Widget _buildAllOperationsWidget() => Column(
        key: ValueKey('Column 1'),
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
                hintText: 'Cerca movimentazioni',
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
                    end: _operations.length.toDouble(),
                    duration: Duration(
                      seconds: 1,
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xff262539),
                      fontSize: 40,
                    ),
                  ),
                  Text(
                    ' Movimentazioni',
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
                    onPressed: () => context.read<OperationsCubit>().fetch(
                          user: HomeScreen.of(context)!.getUser(),
                        ),
                    elevation: 0,
                    padding: const EdgeInsets.all(16),
                    hoverElevation: 0,
                    highlightElevation: 0,
                    shape: CircleBorder(),
                    color: Color(0xffF9F9F9),
                    child: Icon(
                      Icons.refresh,
                      color: Color(0xff333333),
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Color(0xff333333),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    icon: Icon(
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
              showItemDuration: Duration(
                milliseconds: 300,
              ),
              showItemInterval: Duration(
                microseconds: 200,
              ),
              itemCount: _operations.length,
              itemBuilder: _operationsBuilder,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2,
              ),
            ),
          ),
        ],
      );

  Widget _buildOperationToEditWidget() => Column(
        key: ValueKey('Column 2'),
        children: [
          Row(
            children: [
              MaterialButton(
                onPressed: () => setState(
                  () => _operationToEdit = null,
                ),
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
                'Movimentazione #${_operationToEdit!.id}',
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
                Text(
                  _operationToEdit!.id.toString(),
                  style: TextStyle(
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
                      value: _operationToEdit!.type,
                      onChanged: (value) => setState(
                        () => _operationToEdit!.type = _types
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
                      value: _operationToEdit!.trip,
                      onChanged: (value) => setState(
                        () => _operationToEdit!.trip = _tripsAll
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
                              builder: (context, setState) => ListView.builder(
                                shrinkWrap: true,
                                itemCount: _operationToEdit!.ships.length + 1,
                                itemBuilder: (ctx, index) =>
                                    _operationItemsBuilder(
                                  index,
                                  setState,
                                  _operationToEdit!.ships,
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
                              builder: (context, setState) => ListView.builder(
                                shrinkWrap: true,
                                itemCount: _operationToEdit!.goods.length + 1,
                                itemBuilder: (ctx, index) =>
                                    _operationItemsBuilder(
                                  index,
                                  setState,
                                  _operationToEdit!.goods,
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
                              builder: (context, setState) => ListView.builder(
                                shrinkWrap: true,
                                itemCount: _operationToEdit!.people.length + 1,
                                itemBuilder: (ctx, index) =>
                                    _operationItemsBuilder(
                                  index,
                                  setState,
                                  _operationToEdit!.people,
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
                              builder: (context, setState) => ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                    _operationToEdit!.vehicles.length + 1,
                                itemBuilder: (ctx, index) =>
                                    _operationItemsBuilder(
                                  index,
                                  setState,
                                  _operationToEdit!.vehicles,
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
                              builder: (context, setState) => ListView.builder(
                                shrinkWrap: true,
                                itemCount: _operationToEdit!.status.length + 1,
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
                        color: Theme.of(context).accentColor.withOpacity(0.8),
                        onPressed: () => _editOperation(),
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
      );

  Future _editOperation() async {
    if (_operationToEdit!.status.isEmpty ||
        _operationToEdit!.status.where((element) => element.isDeleted).length ==
            _operationToEdit!.status.length) {
      await context.showErrorBar(
        content: Text(
          'Inserire almeno uno stato',
        ),
      );
    } else {
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .editOperation(
        _operationToEdit!..description = _descriptionTextController.text,
      )
          .then(
        (value) async {
          return value.statusCode == HttpStatus.ok
              ? await _fetch().then(
                  (value) {
                    context.showInfoBar(
                      content: Text(
                        'Movimentazione aggiornata con successo',
                      ),
                    );
                    setState(() {
                      _operationToEdit = null;
                    });
                  },
                )
              : context.showErrorBar(
                  content: Text(
                    'Si è verificato un errore',
                  ),
                );
        },
      );
    }
  }

  Future _deleteOperation(
    OperationModel operationModel,
  ) async =>
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .deleteOperation(
            operationModel,
          )
          .then(
            (value) async => value.statusCode == HttpStatus.ok
                ? await _fetch().then(
                    (value) => context.showInfoBar(
                      content: Text(
                        'Movimentazione eliminata con successo',
                      ),
                    ),
                  )
                : context.showErrorBar(
                    content: Text(
                      'Si è verificato un errore',
                    ),
                  ),
          );

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OperationsCubit, OperationsState>(
        builder: (context, operationState) {
          if (operationState is OperationsLoaded) {
            _operations = operationState.operations;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  32,
                  32,
                  56,
                  32,
                ),
                child: AnimatedSwitcher(
                  duration: Duration(
                    milliseconds: 500,
                  ),
                  child: _operationToEdit == null
                      ? _buildAllOperationsWidget()
                      : _buildOperationToEditWidget(),
                ),
              ),
            );
          } else if (operationState is OperationsLoading ||
              operationState is OperationsInitial) {
            return LoadingIndicator();
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
                          TextSpan(
                            text: 'Si è verificato un errore. ',
                          ),
                          TextSpan(
                            text: 'Riprova',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _fetch(),
                            style: TextStyle(
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
