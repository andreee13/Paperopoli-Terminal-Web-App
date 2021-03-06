// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/core/utils/utils.dart';
import 'package:paperopoli_terminal/data/models/vehicle/vehicle_model.dart';
import 'package:paperopoli_terminal/data/models/vehicle/vehicle_status.dart';
import 'package:paperopoli_terminal/presentation/screens/home_screen.dart';
import 'package:paperopoli_terminal/presentation/widgets/loading_indicator.dart';
import 'package:flash/flash.dart';

class CreateVehicleWidget extends StatefulWidget {
  const CreateVehicleWidget({Key? key}) : super(key: key);

  @override
  CreateVehicleWidgetState createState() => CreateVehicleWidgetState();
}

class CreateVehicleWidgetState extends State<CreateVehicleWidget> {
  late final VehicleModel _vehicleToCreate;
  List<String> _types = [];
  List _statusNames = [];
  dynamic _currentStatusName;
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
          ).fetchVehicleTypes().then(
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
          ).fetchVehiclesStatusNames().then(
                (value) => value.body,
              ),
        );
        _vehicleToCreate = VehicleModel(
          status: [],
          type: _types.first,
          plate: '',
        );
      } catch (e) {
        HomeScreen.of(context)!.setCreatingMode(1);
        await context.showErrorBar(
          content: const Text(
            'Si ?? verificato un errore',
          ),
        );
      }
    }
  }

  Widget _vehicleStatusBuilder(int index, setState) =>
      index == _vehicleToCreate.status.length
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
                          () => _vehicleToCreate.status.add(
                            VehicleStatus(
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
          : ListTile(
              leading: Text(
                _vehicleToCreate.status[index].timestamp.toIso8601String().substring(0, 19).replaceAll("T", " "),
              ),
              title: Text(
                _vehicleToCreate.status[index].name,
              ),
              trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: () => setState(
                        () => _vehicleToCreate.status.removeAt(index),
                      )),
            );

  Future _createVehicle() async {
    if (_vehicleToCreate.status.isEmpty) {
      await context.showErrorBar(
        content: const Text(
          'Inserire almeno uno stato',
        ),
      );
    } else {
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .createVehicle(
        _vehicleToCreate
          ..plate = _descriptionTextController.text.toUpperCase()
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
              content: const Text(
                'Veicolo creato con successo',
              ),
            );
            HomeScreen.of(context)!.setCreatingMode(0);
          } else {
            context.showErrorBar(
              content: const Text(
                'Si ?? verificato un errore',
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
                        const Text(
                          'Nuovo veicolo',
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
                                value: _vehicleToCreate.type,
                                onChanged: (value) => setState(
                                  () => _vehicleToCreate.type = _types
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
                            'Targa',
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
                                    'Targa',
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
                                        builder: (context, setState) =>
                                            ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              _vehicleToCreate.status.length +
                                                  1,
                                          itemBuilder: (ctx, index) =>
                                              _vehicleStatusBuilder(
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
                                  color: Theme.of(context)
                                      .colorScheme.secondary
                                      .withOpacity(0.8),
                                  onPressed: () => _createVehicle(),
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
                )
              : const LoadingIndicator(),
        ),
      );
}
