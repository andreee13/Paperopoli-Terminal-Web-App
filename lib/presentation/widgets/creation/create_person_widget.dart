import 'dart:convert';
import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/core/utils/utils.dart';
import 'package:paperopoli_terminal/data/models/person/person_model.dart';
import 'package:paperopoli_terminal/data/models/person/person_status.dart';
import 'package:paperopoli_terminal/presentation/screens/home_screen.dart';
import 'package:paperopoli_terminal/presentation/widgets/loading_indicator.dart';
import 'package:flash/flash.dart';

class CreatePersonWidget extends StatefulWidget {
  @override
  _CreatePersonWidgetState createState() => _CreatePersonWidgetState();
}

class _CreatePersonWidgetState extends State<CreatePersonWidget> {
  late final PersonModel _personToCreate;
  List<String> _types = [];
  List _statusNames = [];
  var _currentStatusName;
  final TextEditingController _idTextController = TextEditingController();
  final TextEditingController _fullnameTextController = TextEditingController();
  final TextEditingController _cfTextController = TextEditingController();
  final TextEditingController _newStateDateTimeController =
      TextEditingController();

  @override
  void dispose() {
    _fullnameTextController.dispose();
    _cfTextController.dispose();
    _newStateDateTimeController.dispose();
    super.dispose();
  }

  Future _fetch() async {
    if (_types.isEmpty || _statusNames.isEmpty) {
      try {
        _types = await jsonDecode(
          await ServerService(
            HomeScreen.of(context)!.getUser(),
          ).fetchPersonTypes().then(
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
          ).fetchPeopleStatusNames().then(
                (value) => value.body,
              ),
        );
        _personToCreate = PersonModel(
          status: [],
          type: _types.first,
          fullname: '',
          cf: '',
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

  Widget _personStatusBuilder(int index, setState) =>
      index == _personToCreate.status.length
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
                          () => _personToCreate.status.add(
                            PersonStatus(
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
                '${_personToCreate.status[index].timestamp.toIso8601String().substring(0, 19).replaceAll("T", " ")}',
              ),
              title: Text(
                _personToCreate.status[index].name,
              ),
              trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: () => setState(
                        () => _personToCreate.status.removeAt(index),
                      )),
            );

  Future _createPerson() async {
    if (_personToCreate.status.isEmpty) {
      await context.showErrorBar(
        content: Text(
          'Inserire almeno uno stato',
        ),
      );
    } else {
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .createPerson(
        _personToCreate
          ..cf = _cfTextController.text
          ..fullname = _fullnameTextController.text
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
                'Persona creata con successo',
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
                          'Nuova persona',
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
                                value: _personToCreate.type,
                                onChanged: (value) => setState(
                                  () => _personToCreate.type = _types
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
                            'Nome completo',
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
                                    'Nome completo',
                                  ),
                                  controller: _fullnameTextController,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Codice fiscale',
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
                                    'Codice fiscale',
                                  ),
                                  maxLength: 16,
                                  controller: _cfTextController,
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
                                              _personToCreate.status.length + 1,
                                          itemBuilder: (ctx, index) =>
                                              _personStatusBuilder(
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
                                  onPressed: () => _createPerson(),
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
