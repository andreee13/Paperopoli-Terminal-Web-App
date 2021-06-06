import 'dart:convert';
import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/core/utils/utils.dart';
import 'package:paperopoli_terminal/data/models/quay/quay_model.dart';
import 'package:paperopoli_terminal/data/models/trip/trip_model.dart';
import 'package:paperopoli_terminal/data/models/trip/trip_time.dart';
import 'package:paperopoli_terminal/presentation/screens/home_screen.dart';
import 'package:paperopoli_terminal/presentation/widgets/loading_indicator.dart';
import 'package:flash/flash.dart';

class CreateTripWidget extends StatefulWidget {
  @override
  _CreateTripWidgetState createState() => _CreateTripWidgetState();
}

class _CreateTripWidgetState extends State<CreateTripWidget> {
  late TripModel _tripToCreate;
  List<QuayModel> _quays = [];
  final TextEditingController _idTextController = TextEditingController();
  final TextEditingController _expectedArrivalDateController =
      TextEditingController();
  final TextEditingController _actualArrivalDateController =
      TextEditingController();
  final TextEditingController _expectedDeparturedDateController =
      TextEditingController();
  final TextEditingController _actualDepartureDateController =
      TextEditingController();

  @override
  void dispose() {
    _expectedArrivalDateController.dispose();
    _expectedDeparturedDateController.dispose();
    _actualArrivalDateController.dispose();
    _actualDepartureDateController.dispose();
    _idTextController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (_quays.isEmpty) {
      try {
        _quays = await jsonDecode(
          await ServerService(
            HomeScreen.of(context)!.getUser(),
          ).fetchQuays().then(
                (value) => value.body,
              ),
        )
            .map<QuayModel>(
              (
                item,
              ) =>
                  QuayModel.fromJson(
                item,
              ),
            )
            .toList();
        _tripToCreate = TripModel(
          operations: [],
          quay: _quays.first,
          time: TripTime(
            actualArrivalTime: DateTime.now(),
            actualDepartureTime: DateTime.now(),
            expectedArrivalTime: DateTime.now(),
            expectedDepartureTime: DateTime.now(),
          ),
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

  Future _createTrip() async {
    if (_expectedArrivalDateController.text.isNotEmpty &&
        _expectedDeparturedDateController.text.isNotEmpty) {
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .createTrip(
        _tripToCreate
          ..time.expectedArrivalTime =
              DateTime.parse(_expectedArrivalDateController.text)
          ..time.expectedDepartureTime =
              DateTime.parse(_expectedDeparturedDateController.text)
          ..time.actualArrivalTime = DateTime.parse(
            _actualArrivalDateController.text.isNotEmpty
                ? _actualArrivalDateController.text
                : _expectedArrivalDateController.text,
          )
          ..time.actualDepartureTime = DateTime.parse(
            _actualDepartureDateController.text.isNotEmpty
                ? _actualDepartureDateController.text
                : _expectedDeparturedDateController.text,
          )
          ..id = _idTextController.text.isEmpty
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
                'Viaggio creato con successo',
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
    } else {
      await context.showErrorBar(
        content: Text(
          'Inserire almeno le date di arrivo e partenza previste',
        ),
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
                          'Nuovo viaggio',
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
                            'Banchina',
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
                                value: _tripToCreate.quay.id,
                                onChanged: (value) => setState(
                                  () => _tripToCreate.quay = _quays
                                      .where(
                                        (element) => element.id == value,
                                      )
                                      .first,
                                ),
                                items: _quays
                                    .map(
                                      (e) => DropdownMenuItem<int>(
                                        value: e.id,
                                        child: Text(
                                          e.description,
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
                            'Arrivo previsto',
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
                                width: 250,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                ),
                                child: DateTimePicker(
                                  icon: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                    ),
                                    child: Icon(
                                      Icons.calendar_today,
                                    ),
                                  ),
                                  initialDate:
                                      _tripToCreate.time.expectedArrivalTime,
                                  firstDate: DateTime(2021),
                                  lastDate: DateTime(2050),
                                  onSaved: (s) =>
                                      _expectedArrivalDateController.text = s!,
                                  type: DateTimePickerType.dateTime,
                                  controller: _expectedArrivalDateController,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Arrivo effettivo',
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
                                width: 250,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                ),
                                child: DateTimePicker(
                                  icon: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                    ),
                                    child: Icon(
                                      Icons.calendar_today,
                                    ),
                                  ),
                                  initialDate:
                                      _tripToCreate.time.actualArrivalTime,
                                  firstDate: DateTime(2021),
                                  lastDate: DateTime(2050),
                                  type: DateTimePickerType.dateTime,
                                  onSaved: (s) =>
                                      _actualArrivalDateController.text = s!,
                                  controller: _actualArrivalDateController,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Partenza prevista',
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
                                width: 250,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                ),
                                child: DateTimePicker(
                                  icon: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                    ),
                                    child: Icon(
                                      Icons.calendar_today,
                                    ),
                                  ),
                                  initialDate:
                                      _tripToCreate.time.expectedDepartureTime,
                                  firstDate: DateTime(2021),
                                  lastDate: DateTime(2050),
                                  type: DateTimePickerType.dateTime,
                                  onSaved: (s) =>
                                      _expectedDeparturedDateController.text =
                                          s!,
                                  controller: _expectedDeparturedDateController,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Partenza effettiva',
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
                                width: 250,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                ),
                                child: DateTimePicker(
                                  icon: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                    ),
                                    child: Icon(
                                      Icons.calendar_today,
                                    ),
                                  ),
                                  initialDate:
                                      _tripToCreate.time.actualDepartureTime,
                                  firstDate: DateTime(2021),
                                  lastDate: DateTime(2050),
                                  type: DateTimePickerType.dateTime,
                                  controller: _actualDepartureDateController,
                                  onSaved: (s) =>
                                      _actualDepartureDateController.text = s!,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                                  onPressed: () => _createTrip(),
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
