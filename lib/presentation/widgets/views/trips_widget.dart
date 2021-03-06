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
import 'package:paperopoli_terminal/cubits/trips/trips_cubit.dart';
import 'package:paperopoli_terminal/data/models/quay/quay_model.dart';
import 'package:paperopoli_terminal/data/models/trip/trip_model.dart';
import 'package:paperopoli_terminal/presentation/screens/home_screen.dart';

import '../loading_indicator.dart';

class TripsWidget extends StatefulWidget {
  const TripsWidget({Key? key}) : super(key: key);

  @override
  TripsWidgetState createState() => TripsWidgetState();
}

class TripsWidgetState extends State<TripsWidget> {
  late List<TripModel> _trips;
  late final TextEditingController _searchTextController = TextEditingController()
    ..addListener(() => setState(() {}));
  final TextEditingController _deleteTextController = TextEditingController();
  TripModel? _tripToEdit;
  List<QuayModel> _quays = [];
  final TextEditingController _expectedArrivalDateController = TextEditingController();
  final TextEditingController _actualArrivalDateController = TextEditingController();
  final TextEditingController _expectedDeparturedDateController = TextEditingController();
  final TextEditingController _actualDepartureDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _expectedArrivalDateController.dispose();
    _expectedDeparturedDateController.dispose();
    _actualArrivalDateController.dispose();
    _actualDepartureDateController.dispose();
    _deleteTextController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  Future _fetch() async {
    await context.read<TripsCubit>().fetch(
          user: HomeScreen.of(context)!.getUser(),
        );
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
  }

  Widget _getInfoWidgets(int index, TripModel trip) {
    switch (index) {
      case 0:
        return Text(
          'Orario arrivo: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
      case 1:
        return Text(
          '${trip.time.expectedArrivalTime.toIso8601String().substring(11, 16)} - ${trip.time.actualArrivalTime.toIso8601String().substring(11, 16)}',
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      case 2:
        return Text(
          'Orario partenza: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
      case 3:
        return Text(
          '${trip.time.expectedDepartureTime.toIso8601String().substring(11, 16)} - ${trip.time.actualDepartureTime.toIso8601String().substring(11, 16)}',
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      case 4:
        return Text(
          'Banchina: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
      case 5:
        return Text(
          trip.quay.description,
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      case 6:
        return Text(
          'Movimentazioni: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        );
      case 7:
        return Text(
          trip.operations.length.toString(),
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _tripsBuilder(
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
                _tripToEdit = TripModel.deepCopy(
                  _trips[index],
                );
                _expectedArrivalDateController.text =
                    _tripToEdit!.time.expectedArrivalTime.toIso8601String();
                _expectedDeparturedDateController.text =
                    _tripToEdit!.time.expectedDepartureTime.toIso8601String();
                _actualArrivalDateController.text =
                    _tripToEdit!.time.actualArrivalTime.toIso8601String();
                _actualDepartureDateController.text =
                    _tripToEdit!.time.actualDepartureTime.toIso8601String();
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
                color: _trips[index].id.toString().contains(
                              _searchTextController.text,
                            ) ||
                        _trips[index].quay.description.toLowerCase().contains(
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
                            'Viaggio #${_trips[index].id}',
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
                                  _deleteTextController.clear();
                                  return await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      actionsPadding: const EdgeInsets.only(
                                        right: 16,
                                      ),
                                      title: const Text(
                                        'Elimina viaggio',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text(
                                            'Annulla',
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            context,
                                            _deleteTextController.text,
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
                                        width: MediaQuery.of(context).size.width * 0.20,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text(
                                              'Eliminando il viaggio non sar?? pi?? visibile in questa sezione e tutte le movimentazioni associate saranno rimosse dal sistema.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ).then(
                                    (value) => value != null
                                        ? _deleteTrip(
                                            _trips[index],
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
                          _trips[index],
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

  Widget _buildAllTripsWidget() => Column(
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
                hintText: 'Cerca viaggi',
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
                    end: _trips.length.toDouble(),
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
                    ' Viaggi',
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
                    onPressed: () => context.read<TripsCubit>().fetch(
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
              itemCount: _trips.length,
              itemBuilder: _tripsBuilder,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2,
              ),
            ),
          ),
        ],
      );

  Widget _buildTripToEditWidget() => Column(
        key: const ValueKey('Column 2'),
        children: [
          Row(
            children: [
              MaterialButton(
                onPressed: () => setState(
                  () => _tripToEdit = null,
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
                'Viaggio #${_tripToEdit!.id}',
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
                  _tripToEdit!.id.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                  ),
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
                      value: _tripToEdit!.quay.id,
                      onChanged: (value) => setState(
                        () => _tripToEdit!.quay = _quays
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
                        icon: const Padding(
                          padding: EdgeInsets.only(
                            top: 8,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                          ),
                        ),
                        initialDate: _tripToEdit!.time.expectedArrivalTime,
                        firstDate: DateTime(2021),
                        lastDate: DateTime(2050),
                        onSaved: (s) => _expectedArrivalDateController.text = s!,
                        type: DateTimePickerType.dateTime,
                        controller: _expectedArrivalDateController,
                        style: const TextStyle(
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
                        icon: const Padding(
                          padding: EdgeInsets.only(
                            top: 8,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                          ),
                        ),
                        initialDate: _tripToEdit!.time.actualArrivalTime,
                        firstDate: DateTime(2021),
                        lastDate: DateTime(2050),
                        type: DateTimePickerType.dateTime,
                        onSaved: (s) => _actualArrivalDateController.text = s!,
                        controller: _actualArrivalDateController,
                        style: const TextStyle(
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
                        icon: const Padding(
                          padding: EdgeInsets.only(
                            top: 8,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                          ),
                        ),
                        initialDate: _tripToEdit!.time.expectedDepartureTime,
                        firstDate: DateTime(2021),
                        lastDate: DateTime(2050),
                        type: DateTimePickerType.dateTime,
                        onSaved: (s) => _expectedDeparturedDateController.text = s!,
                        controller: _expectedDeparturedDateController,
                        style: const TextStyle(
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
                        icon: const Padding(
                          padding: EdgeInsets.only(
                            top: 8,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                          ),
                        ),
                        initialDate: _tripToEdit!.time.actualDepartureTime,
                        firstDate: DateTime(2021),
                        lastDate: DateTime(2050),
                        type: DateTimePickerType.dateTime,
                        controller: _actualDepartureDateController,
                        onSaved: (s) => _actualDepartureDateController.text = s!,
                        style: const TextStyle(
                          fontSize: 18,
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
                        onPressed: () => _editTrip(),
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

  Future _editTrip() async {
    _tripToEdit!.time.expectedArrivalTime = DateTime.parse(
      _expectedArrivalDateController.text,
    );
    _tripToEdit!.time.expectedDepartureTime = DateTime.parse(
      _expectedDeparturedDateController.text,
    );
    _tripToEdit!.time.actualArrivalTime = DateTime.parse(
      _actualArrivalDateController.text,
    );
    _tripToEdit!.time.actualDepartureTime = DateTime.parse(
      _actualDepartureDateController.text,
    );
    return await ServerService(
      HomeScreen.of(context)!.getUser(),
    )
        .editTrip(
          _tripToEdit!,
        )
        .then(
          (value) async => value.statusCode == HttpStatus.ok
              ? await _fetch().then(
                  (value) {
                    context.showInfoBar(
                      content: const Text(
                        'Viaggio aggiornato con successo',
                      ),
                    );
                    setState(() {
                      _tripToEdit = null;
                    });
                  },
                )
              : context.showErrorBar(
                  content: const Text(
                    'Si ?? verificato un errore',
                  ),
                ),
        );
  }

  Future _deleteTrip(
    TripModel tripModel,
  ) async =>
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .deleteTrip(
            tripModel,
          )
          .then(
            (value) async => value.statusCode == HttpStatus.ok
                ? await _fetch().then(
                    (value) => context.showInfoBar(
                      content: const Text(
                        'Viaggio eliminato con successo',
                      ),
                    ),
                  )
                : context.showErrorBar(
                    content: const Text(
                      'Si ?? verificato un errore',
                    ),
                  ),
          );

  @override
  Widget build(BuildContext context) => BlocBuilder<TripsCubit, TripsState>(
        builder: (context, tripState) {
          if (tripState is TripsLoaded) {
            _trips = tripState.trips;
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
                  child: _tripToEdit == null ? _buildAllTripsWidget() : _buildTripToEditWidget(),
                ),
              ),
            );
          } else if (tripState is TripsLoading || tripState is TripsInitial) {
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
                            text: 'Si ?? verificato un errore. ',
                          ),
                          TextSpan(
                            text: 'Riprova',
                            recognizer: TapGestureRecognizer()..onTap = () => _fetch(),
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
