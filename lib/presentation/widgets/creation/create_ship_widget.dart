import 'dart:convert';
import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/core/utils/utils.dart';
import 'package:paperopoli_terminal/data/models/ship/ship_model.dart';
import 'package:paperopoli_terminal/data/models/ship/ship_status.dart';
import 'package:paperopoli_terminal/presentation/screens/home_screen.dart';
import 'package:paperopoli_terminal/presentation/widgets/loading_indicator.dart';
import 'package:flash/flash.dart';

class CreateShipWidget extends StatefulWidget {
  @override
  _CreateShipWidgetState createState() => _CreateShipWidgetState();
}

class _CreateShipWidgetState extends State<CreateShipWidget> {
  late final ShipModel _shipToCreate;
  List<String> _types = [];
  List _statusNames = [];
  var _currentStatusName;
  final TextEditingController _idTextController = TextEditingController();
  final TextEditingController _descriptionTextController =
      TextEditingController();
  final TextEditingController _newStateDateTimeController =
      TextEditingController();

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
        _shipToCreate = ShipModel(
          status: [],
          type: _types.first,
          description: '',
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

  Widget _shipStatusBuilder(int index, setState) =>
      index == _shipToCreate.status.length
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
                          () => _shipToCreate.status.add(
                            ShipStatus(
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
                '${_shipToCreate.status[index].timestamp.toIso8601String().substring(0, 19).replaceAll("T", " ")}',
              ),
              title: Text(
                _shipToCreate.status[index].name,
              ),
              trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: () => setState(
                        () => _shipToCreate.status.removeAt(index),
                      )),
            );

  Future _createShip() async {
    if (_shipToCreate.status.isEmpty) {
      await context.showErrorBar(
        content: Text(
          'Inserire almeno uno stato',
        ),
      );
    } else {
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .createShip(
        _shipToCreate
          ..description = _descriptionTextController.text
          ..id = _idTextController.text == ''
              ? null
              : int.parse(
                  _idTextController.text,
                ),
      )
          .then(
        (value) {
          if (value.statusCode == HttpStatus.ok) {
            context.showSuccessBar(
              content: Text(
                'Nave creata con successo',
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
                          'Nuova nave',
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
                                value: _shipToCreate.type,
                                onChanged: (value) => setState(
                                  () => _shipToCreate.type = _types
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
                                              _shipToCreate.status.length + 1,
                                          itemBuilder: (ctx, index) =>
                                              _shipStatusBuilder(
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
                                  onPressed: () => _createShip(),
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
