import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/core/constants/constants.dart';
import 'package:paperopoli_terminal/core/services/ws_service.dart';
import 'package:paperopoli_terminal/cubits/trips/trips_cubit.dart';
import 'package:paperopoli_terminal/data/models/chat/message_model.dart';
import 'package:paperopoli_terminal/data/models/chat/user_model.dart';
import 'package:paperopoli_terminal/data/models/operation/operation_model.dart';
import 'package:paperopoli_terminal/data/models/operation/operation_status.dart';
import 'package:paperopoli_terminal/data/models/trip/trip_model.dart';
import 'package:paperopoli_terminal/presentation/screens/home_screen.dart';

import '../loading_indicator.dart';

class DashboardWidget extends StatefulWidget {
  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();

  static _DashboardWidgetState? of(BuildContext context) =>
      context.findAncestorStateOfType<_DashboardWidgetState>();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _chatTextController = TextEditingController();
  final List<OperationsChartData> _operationsCounterChartData = [];
  final List<FlSpot> _completedOperationsChartSpots = [];
  final List<FlSpot> _workingOperationsChartSpots = [];
  late List<TripModel> _trips;
  late int _totalOperations;
  late Map<DateTime, List<Event>> _mappedTrips;
  int _totalCompletedOperations = 0;
  int _totalWorkingOperations = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatTextController.dispose();
    super.dispose();
  }

  Future _fetch() async => await context
      .read<TripsCubit>()
      .fetch(
        user: HomeScreen.of(context)!.getUser(),
      )
      .then(
        (value) async => await WsService.connect(
          context,
          _scrollController,
        ),
      );

  int checkDate(TripModel trip) {
    if (DateTime.now().year == trip.time.expectedArrivalTime.year &&
        DateTime.now().month == trip.time.expectedArrivalTime.month &&
        DateTime.now().day == trip.time.expectedArrivalTime.day) {
      return 1;
    } else if (DateTime.now().year == trip.time.expectedDepartureTime.year &&
        DateTime.now().month == trip.time.expectedDepartureTime.month &&
        DateTime.now().day == trip.time.expectedDepartureTime.day) {
      return 2;
    } else {
      return 0;
    }
  }

  Widget _tripsBuilder(
    BuildContext context,
    int index,
  ) =>
      checkDate(
                _trips[index],
              ) !=
              0
          ? Container(
              padding: const EdgeInsets.fromLTRB(
                24,
                16,
                16,
                24,
              ),
              height: 160,
              width: MediaQuery.of(context).size.width * 0.16,
              margin: EdgeInsets.only(
                right: 20,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: ACCENT_COLORS[index.remainder(ACCENT_COLORS.length)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Viaggio #${_trips[index].id.toString()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff262539),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_horiz,
                          color: Color(0xff262539),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${checkDate(_trips[index]) == 1 ? "Arrivo" : "Partenza"} alle ${_trips[index].time.expectedArrivalTime.toIso8601String().substring(11, 16)} - ${_trips[index].time.actualArrivalTime.toIso8601String().substring(11, 16)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    '${_trips[index].operations.length} movimentazioni',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    _trips[index].quay.description,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : SizedBox();

  void manageTrips(List<TripModel> trips) {
    _trips = trips;
    _operationsCounterChartData.clear();
    _completedOperationsChartSpots.clear();
    _workingOperationsChartSpots.clear();
    _totalCompletedOperations = 0;
    _totalOperations = 0;
    _totalWorkingOperations = 0;
    _mappedTrips = {};
    var tr2 = <DateTime>[];
    _trips.forEach(
      (element) {
        tr2.addAll(
          [
            DateTime(
              element.time.expectedArrivalTime.year,
              element.time.expectedArrivalTime.month,
              element.time.expectedArrivalTime.day,
            ),
            DateTime(
              element.time.expectedDepartureTime.year,
              element.time.expectedDepartureTime.month,
              element.time.expectedDepartureTime.day,
            ),
          ],
        );
      },
    );
    tr2.forEach((element) {
      _mappedTrips.addAll({
        element: tr2
            .where(
              (e) =>
                  e.year == element.year &&
                  e.month == element.month &&
                  e.day == element.day,
            )
            .map(
              (e) => Event(
                date: e,
              ),
            )
            .toList(),
      });
    });

    _totalOperations = tr2.length;
    //daily operations counter
    var count1 = <OperationModel>[];
    _trips.forEach((element) {
      count1.addAll(element.operations);
    });
    var count2 = <DateTime>[];
    count1.forEach(
      (element) {
        count2.addAll(
          element.status.map(
            (e) => e.timestamp,
          ),
        );
      },
    );
    _totalOperations = count2.length;
    var count3 = groupBy(
      count2,
      (DateTime obj) => obj.toIso8601String().substring(0, 10),
    );
    count3.keys.forEach(
      (key) {
        _operationsCounterChartData.add(
          OperationsChartData(
            count3[key]!.length,
            key,
          ),
        );
      },
    );
    //daily operations
    final work1 = <OperationStatus>[];
    count1.map(
      (e) => work1.addAll(
        e.status,
      ),
    );
    var work2 = <OperationStatus>[];
    count1.forEach(
      (element) {
        work2.addAll(
          element.status,
        );
      },
    );
    Map<String, dynamic> work3 = groupBy(
      work2,
      (OperationStatus status) =>
          status.timestamp.toIso8601String().substring(0, 10),
    );
    var work4 = <String, dynamic>{};
    work3.forEach((key, value) {
      work4[key] = groupBy(
        work3[key],
        (OperationStatus e) => e.name,
      );
    });
    work4.forEach(
      (key, value) {
        _totalCompletedOperations +=
            value['Completata'] != null ? value['Completata'].length as int : 0;
        _totalWorkingOperations += value['In lavorazione'] != null
            ? value['In lavorazione'].length as int
            : 0;
        _workingOperationsChartSpots.add(
          FlSpot(
            work4.keys.toList().indexOf(key).toDouble(),
            value['In lavorazione'] != null
                ? value['In lavorazione'].length.toDouble()
                : 0,
          ),
        );
        _completedOperationsChartSpots.add(
          FlSpot(
            work4.keys.toList().indexOf(key).toDouble(),
            value['Completata'] != null
                ? value['Completata'].length.toDouble()
                : 0,
          ),
        );
      },
    );
  }

  void _sendMessage(String text) {
    if (text != '') {
      WsService.send(
        MessageModel(
          sender: UserModel.fromFirebaseUser(
            HomeScreen.of(context)!.getUser(),
          ),
          body: text,
          date: DateTime.now(),
        ),
        _scrollController,
      ).then(
        (value) {
          setState(() {});
          _chatTextController.clear();
          SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(
                milliseconds: 200,
              ),
              curve: Curves.easeOut,
            );
          });
        },
      );
    }
  }

  Widget _chatBuilder(
    BuildContext context,
    int index,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: WsService.messages[index].sender.uid !=
                    HomeScreen.of(context)!.getUser().uid
                ? [
                    Tooltip(
                      message: WsService.messages[index].sender.displayName,
                      child: GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  minRadius: 30,
                                  backgroundColor: ACCENT_COLORS[
                                      index.remainder(ACCENT_COLORS.length)],
                                  foregroundColor: Colors.black,
                                  child: Text(
                                    WsService.messages[index].sender.displayName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
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
                                    WsService
                                        .messages[index].sender.displayName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  WsService.messages[index].sender.email,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Divider(),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          WsService.messages[index].sender
                                              .creationTime
                                              .toIso8601String()
                                              .substring(
                                                0,
                                                10,
                                              ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          WsService.messages[index].sender
                                              .lastSignInTime
                                              .toIso8601String()
                                              .substring(
                                                0,
                                                10,
                                              ),
                                          style: TextStyle(
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
                        ),
                        child: CircleAvatar(
                          backgroundColor: ACCENT_COLORS[
                              index.remainder(ACCENT_COLORS.length)],
                          foregroundColor: Colors.black,
                          child: Text(
                            WsService.messages[index].sender.displayName
                                .substring(0, 1)
                                .toUpperCase(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 24,
                        ),
                        margin: const EdgeInsets.only(
                          left: 16,
                        ),
                        decoration: BoxDecoration(
                          color: ACCENT_COLORS[
                              index.remainder(ACCENT_COLORS.length)],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          WsService.messages[index].body,
                        ),
                      ),
                    ),
                  ]
                : [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 24,
                        ),
                        margin: const EdgeInsets.only(
                          right: 16,
                        ),
                        decoration: BoxDecoration(
                          color: ACCENT_COLORS[
                              index.remainder(ACCENT_COLORS.length)],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          WsService.messages[index].body,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: WsService.messages[index].sender.displayName,
                      child: GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  minRadius: 30,
                                  backgroundColor: ACCENT_COLORS[
                                      index.remainder(ACCENT_COLORS.length)],
                                  foregroundColor: Colors.black,
                                  child: Text(
                                    WsService.messages[index].sender.displayName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
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
                                    WsService.messages[index].sender
                                            .displayName +
                                        (WsService.messages[index].sender.uid ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? ' (Tu)'
                                            : ''),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  WsService.messages[index].sender.email,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Divider(),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          WsService.messages[index].sender
                                              .creationTime
                                              .toIso8601String()
                                              .substring(
                                                0,
                                                10,
                                              ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          WsService.messages[index].sender
                                              .lastSignInTime
                                              .toIso8601String()
                                              .substring(
                                                0,
                                                10,
                                              ),
                                          style: TextStyle(
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
                        ),
                        child: CircleAvatar(
                          backgroundColor: ACCENT_COLORS[
                              index.remainder(ACCENT_COLORS.length)],
                          foregroundColor: Colors.black,
                          child: Text(
                            WsService.messages[index].sender.displayName
                                .substring(0, 1)
                                .toUpperCase(),
                          ),
                        ),
                      ),
                    ),
                  ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 8,
              top: 8,
              bottom: 16,
            ),
            child: Align(
              alignment: WsService.messages[index].sender.uid !=
                      HomeScreen.of(context)!.getUser().uid
                  ? Alignment.topRight
                  : Alignment.topLeft,
              child: Text(
                WsService.messages[index].date.toIso8601String().substring(
                      11,
                      16,
                    ),
                style: TextStyle(
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => BlocBuilder<TripsCubit, TripsState>(
        builder: (context, tripState) {
          if (tripState is TripsLoaded) {
            manageTrips(tripState.trips);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  32,
                  32,
                  0,
                  0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.51,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 40,
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Ionicons.search,
                                  color: Colors.grey.shade400,
                                ),
                                hintText: 'Cosa vuoi fare?',
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
                              Text(
                                'Viaggi di oggi',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff262539),
                                  fontSize: 40,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  MaterialButton(
                                    onPressed: () async => await _fetch(),
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
                          SizedBox(
                            height: 180,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 24,
                              ),
                              child: _trips
                                      .where(
                                        (element) => checkDate(element) != 0,
                                      )
                                      .isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _trips.length,
                                      itemBuilder: _tripsBuilder,
                                    )
                                  : Center(
                                      child: Text(
                                        'Nessun viaggio',
                                        style: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 48,
                              bottom: 80,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Attività giornaliera',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff262539),
                                    fontSize: 24,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xffF9F9F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: Text(
                                          'Filtra',
                                          style: TextStyle(
                                            color: Color(0xff262539),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Transform.rotate(
                                        angle: 1.5708,
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Color(0xff262539),
                                          size: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.width * 0.20,
                            child: Row(
                              children: [
                                Expanded(
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: false,
                                      ),
                                      titlesData: FlTitlesData(
                                        bottomTitles: SideTitles(
                                          getTitles: (value) =>
                                              value.toString(),
                                          showTitles: false,
                                          margin: 16,
                                          getTextStyles: (value) => TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        leftTitles: SideTitles(
                                          getTitles: (value) =>
                                              value.toStringAsFixed(0),
                                          showTitles: true,
                                          margin: 24,
                                          getTextStyles: (value) => TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      minX: 0,
                                      maxX: _completedOperationsChartSpots
                                              .length
                                              .toDouble() -
                                          1,
                                      minY: 0,
                                      lineTouchData: LineTouchData(
                                        getTouchedSpotIndicator: (barData,
                                                spotIndexes) =>
                                            spotIndexes
                                                .map(
                                                  (e) =>
                                                      TouchedSpotIndicatorData(
                                                    FlLine(
                                                      color:
                                                          Colors.grey.shade400,
                                                      strokeWidth: 2,
                                                      dashArray: [
                                                        5,
                                                      ],
                                                    ),
                                                    FlDotData(
                                                      getDotPainter: (_, __,
                                                              ___, ____) =>
                                                          FlDotCirclePainter(
                                                        color: Colors.white,
                                                        strokeColor: Colors
                                                            .grey.shade100,
                                                        radius: 6,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        touchTooltipData: LineTouchTooltipData(
                                          fitInsideVertically: true,
                                          tooltipBgColor: Colors.grey.shade100,
                                          tooltipRoundedRadius: 25,
                                          getTooltipItems: (touchedSpots) =>
                                              touchedSpots
                                                  .map(
                                                    (touchedSpot) =>
                                                        LineTooltipItem(
                                                      touchedSpot.y
                                                          .toStringAsFixed(0),
                                                      TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _operationsCounterChartData
                                              .map(
                                                (e) => FlSpot(
                                                  _operationsCounterChartData
                                                      .indexOf(e)
                                                      .toDouble(),
                                                  e.lenght.toDouble(),
                                                ),
                                              )
                                              .toList(),
                                          isCurved: true,
                                          colors: [
                                            Color(0xff18293F),
                                          ],
                                          barWidth: 4,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(
                                            show: false,
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            colors: [
                                              Colors.white.withOpacity(0.0),
                                              Color(0xff8CE4F4),
                                            ],
                                            gradientColorStops: [0.0, 0.8],
                                            gradientFrom: Offset(0, 1),
                                            gradientTo: Offset(0, 0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 32,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: 180,
                                      margin: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.17,
                                      decoration: BoxDecoration(
                                        color: Color(0xff232343),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.all(24),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Totale completate',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8,
                                                  top: 16,
                                                ),
                                                child: Text(
                                                  '${(_totalCompletedOperations / _totalOperations * 100).toInt()} %',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '$_totalCompletedOperations su $_totalOperations',
                                                style: TextStyle(
                                                  color: Colors.white60,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                                right: 8,
                                                left: 24,
                                              ),
                                              child: LineChart(
                                                LineChartData(
                                                  gridData: FlGridData(
                                                    show: false,
                                                  ),
                                                  titlesData: FlTitlesData(
                                                    bottomTitles: SideTitles(
                                                      showTitles: false,
                                                    ),
                                                    leftTitles: SideTitles(
                                                      showTitles: false,
                                                    ),
                                                  ),
                                                  borderData: FlBorderData(
                                                    show: false,
                                                  ),
                                                  minX: 0,
                                                  maxX:
                                                      _completedOperationsChartSpots
                                                              .length
                                                              .toDouble() -
                                                          1,
                                                  minY: 0,
                                                  lineTouchData: LineTouchData(
                                                    getTouchedSpotIndicator:
                                                        (barData,
                                                                spotIndexes) =>
                                                            spotIndexes
                                                                .map(
                                                                  (e) =>
                                                                      TouchedSpotIndicatorData(
                                                                    FlLine(
                                                                      color: Colors
                                                                          .white54,
                                                                      strokeWidth:
                                                                          2,
                                                                      dashArray: [
                                                                        5,
                                                                      ],
                                                                    ),
                                                                    FlDotData(
                                                                      getDotPainter: (_,
                                                                              __,
                                                                              ___,
                                                                              ____) =>
                                                                          FlDotCirclePainter(
                                                                        color: Colors
                                                                            .white,
                                                                        strokeColor:
                                                                            Colors.white,
                                                                        radius:
                                                                            6,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                                .toList(),
                                                    touchTooltipData:
                                                        LineTouchTooltipData(
                                                      fitInsideVertically: true,
                                                      tooltipBgColor: Colors
                                                          .white
                                                          .withOpacity(0.9),
                                                      tooltipRoundedRadius: 25,
                                                      getTooltipItems:
                                                          (touchedSpots) =>
                                                              touchedSpots
                                                                  .map(
                                                                    (touchedSpot) =>
                                                                        LineTooltipItem(
                                                                      touchedSpot
                                                                          .y
                                                                          .toStringAsFixed(
                                                                              0),
                                                                      TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                    ),
                                                  ),
                                                  lineBarsData: [
                                                    LineChartBarData(
                                                      spots:
                                                          _completedOperationsChartSpots,
                                                      //isCurved: true,
                                                      colors: [Colors.white70],
                                                      barWidth: 4,
                                                      isStrokeCapRound: true,
                                                      dotData: FlDotData(
                                                        show: false,
                                                      ),
                                                      belowBarData: BarAreaData(
                                                        show: true,
                                                        colors: [
                                                          Colors.white
                                                              .withOpacity(0.0),
                                                          Colors.white30,
                                                        ],
                                                        gradientColorStops: [
                                                          0.2,
                                                          0.8
                                                        ],
                                                        gradientFrom:
                                                            Offset(0, 1),
                                                        gradientTo:
                                                            Offset(0, 0),
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
                                    Container(
                                      height: 180,
                                      width: MediaQuery.of(context).size.width *
                                          0.17,
                                      decoration: BoxDecoration(
                                        color: Color(0xff5564E8),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.all(24),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Totale in lavorazione',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8,
                                                  top: 16,
                                                ),
                                                child: Text(
                                                  '${(_totalWorkingOperations / _totalOperations * 100).toInt()} %',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '$_totalWorkingOperations su $_totalOperations',
                                                style: TextStyle(
                                                  color: Colors.white60,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                                right: 8,
                                                left: 24,
                                              ),
                                              child: LineChart(
                                                LineChartData(
                                                  gridData: FlGridData(
                                                    show: false,
                                                  ),
                                                  titlesData: FlTitlesData(
                                                    bottomTitles: SideTitles(
                                                      showTitles: false,
                                                    ),
                                                    leftTitles: SideTitles(
                                                      showTitles: false,
                                                    ),
                                                  ),
                                                  borderData: FlBorderData(
                                                    show: false,
                                                  ),
                                                  minX: 0,
                                                  maxX:
                                                      _workingOperationsChartSpots
                                                              .length
                                                              .toDouble() -
                                                          1,
                                                  minY: 0,
                                                  lineTouchData: LineTouchData(
                                                    getTouchedSpotIndicator:
                                                        (barData,
                                                                spotIndexes) =>
                                                            spotIndexes
                                                                .map(
                                                                  (e) =>
                                                                      TouchedSpotIndicatorData(
                                                                    FlLine(
                                                                      color: Colors
                                                                          .white54,
                                                                      strokeWidth:
                                                                          2,
                                                                      dashArray: [
                                                                        5,
                                                                      ],
                                                                    ),
                                                                    FlDotData(
                                                                      getDotPainter: (
                                                                        _,
                                                                        __,
                                                                        ___,
                                                                        ____,
                                                                      ) =>
                                                                          FlDotCirclePainter(
                                                                        color: Colors
                                                                            .white,
                                                                        strokeColor:
                                                                            Colors.white,
                                                                        radius:
                                                                            6,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                                .toList(),
                                                    touchTooltipData:
                                                        LineTouchTooltipData(
                                                      fitInsideVertically: true,
                                                      tooltipBgColor: Colors
                                                          .white
                                                          .withOpacity(0.9),
                                                      tooltipRoundedRadius: 25,
                                                      getTooltipItems:
                                                          (touchedSpots) =>
                                                              touchedSpots
                                                                  .map(
                                                                    (touchedSpot) =>
                                                                        LineTooltipItem(
                                                                      touchedSpot
                                                                          .y
                                                                          .toStringAsFixed(
                                                                              0),
                                                                      TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                    ),
                                                  ),
                                                  lineBarsData: [
                                                    LineChartBarData(
                                                      spots:
                                                          _workingOperationsChartSpots,
                                                      //isCurved: true,
                                                      colors: [Colors.white70],
                                                      barWidth: 4,
                                                      isStrokeCapRound: true,
                                                      dotData: FlDotData(
                                                        show: false,
                                                      ),
                                                      belowBarData: BarAreaData(
                                                        show: true,
                                                        colors: [
                                                          Colors.white
                                                              .withOpacity(0.0),
                                                          Colors.white30,
                                                        ],
                                                        gradientColorStops: [
                                                          0.2,
                                                          0.8
                                                        ],
                                                        gradientFrom:
                                                            Offset(0, 1),
                                                        gradientTo:
                                                            Offset(0, 0),
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                            ),
                            child: CalendarCarousel<Event>(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.width * 0.22,
                              daysTextStyle: TextStyle(
                                color: Color(0xff232343),
                                fontWeight: FontWeight.bold,
                              ),
                              weekendTextStyle: TextStyle(
                                color: Color(0xff232343),
                                fontWeight: FontWeight.bold,
                              ),
                              weekdayTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff232343),
                              ),
                              headerTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff232343),
                                fontSize: 24,
                              ),
                              locale: 'it',
                              markedDateWidget: Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.fromLTRB(
                                  0,
                                  0,
                                  1.5,
                                  3,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffFD774C),
                                ),
                              ),
                              markedDateMoreShowTotal: true,
                              markedDateIconMaxShown: 3,
                              markedDatesMap: EventList<Event>(
                                events: _mappedTrips,
                              ),
                              weekDayMargin: const EdgeInsets.all(0),
                              headerMargin: const EdgeInsets.only(
                                bottom: 32,
                              ),
                              iconColor: Color(0xff232343),
                              selectedDayButtonColor: Color(0xff232343),
                              todayButtonColor: Color(0xff232343),
                            ),
                          ),
                          Text(
                            'Chat operatori',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xff262539),
                              fontSize: 24,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.23,
                                width: MediaQuery.of(context).size.width * 0.2,
                                padding: const EdgeInsets.only(
                                  top: 24,
                                  bottom: 16,
                                ),
                                child: Stack(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      controller: _scrollController,
                                      itemCount: WsService.messages.length,
                                      physics: BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                      itemBuilder: _chatBuilder,
                                    ),
                                    Visibility(
                                      visible: WsService.messages.isEmpty,
                                      child: LoadingIndicator(),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: TextField(
                                        controller: _chatTextController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Color(0xffF9F9F9),
                                          contentPadding: const EdgeInsets.only(
                                            right: 24,
                                            left: 24,
                                          ),
                                          hintText: 'Scrivi..',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(25),
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(25),
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        onSubmitted: (value) =>
                                            _sendMessage(value),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Ionicons.send,
                                          color: Color(0xff242443),
                                          size: 18,
                                        ),
                                        onPressed: () => _sendMessage(
                                          _chatTextController.text,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (tripState is TripsInitial || tripState is TripsLoading) {
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

class OperationsChartData {
  final int lenght;
  final String dateTime;

  OperationsChartData(
    this.lenght,
    this.dateTime,
  );
}
