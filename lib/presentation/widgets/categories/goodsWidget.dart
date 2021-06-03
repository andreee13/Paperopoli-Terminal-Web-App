import 'dart:convert';
import 'dart:html';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:ionicons/ionicons.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/core/utils/constants.dart';
import 'package:paperopoli_terminal/core/utils/packages/flutter-countup/lib/countup.dart';
import 'package:paperopoli_terminal/cubits/goods/goods_cubit.dart';
import 'package:paperopoli_terminal/data/models/good/good_model.dart';
import 'package:paperopoli_terminal/data/models/good/good_status.dart';
import 'package:paperopoli_terminal/presentation/screens/home_screen.dart';

import '../loading_indicator.dart';

class GoodsWidget extends StatefulWidget {
  @override
  _GoodsWidgetState createState() => _GoodsWidgetState();
}

class _GoodsWidgetState extends State<GoodsWidget> {
  late List<GoodModel> _goods;
  final TextEditingController _descriptionTextController =
      TextEditingController();
  final TextEditingController _newStateDateTimeController =
      TextEditingController();
  GoodModel? _goodToEdit;
  List<String> _types = [];
  List _statusNames = [];
  var _currentStatusName;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _descriptionTextController.dispose();
    _newStateDateTimeController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    await context.read<GoodsCubit>().fetch(
          user: HomeScreen.of(context)!.getUser(),
        );
    _types = await jsonDecode(
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      ).fetchGoodTypes().then(
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
      ).fetchGoodsStatusNames().then(
            (value) => value.body,
          ),
    );
  }

  Widget _goodStatusBuilder(int index, setState) =>
      index == _goodToEdit!.status.length
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
                          () => _goodToEdit!.status.add(
                            GoodStatus(
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
          : _goodToEdit!.status[index].isDeleted == false
              ? ListTile(
                  leading: Text(
                    '${_goodToEdit!.status[index].timestamp.toIso8601String().substring(0, 19).replaceAll("T", " ")}',
                  ),
                  title: Text(
                    _goodToEdit!.status[index].name,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                    ),
                    onPressed: () => _goodToEdit!.status
                                .where(
                                  (element) => !element.isDeleted,
                                )
                                .length >
                            1
                        ? setState(
                            () => _goodToEdit!.status[index].isDeleted = true,
                          )
                        : {},
                  ),
                )
              : SizedBox();

  InputDecoration _getInputDecoration(
    String hintText,
  ) =>
      InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        fillColor: Colors.grey.withOpacity(0.1),
        filled: false,
        hintStyle: TextStyle(
          color: Colors.black45,
        ),
        hintText: hintText,
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7),
          ),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7),
          ),
        ),
      );

  Widget _getInfoWidgets(int index, GoodModel good) {
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
          good.type,
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
          good.description,
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
          good.status.last.name,
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        );
      default:
        return SizedBox();
    }
  }

  Widget _goodsBuilder(
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
                _goodToEdit = GoodModel.deepCopy(
                  _goods[index],
                );
                _descriptionTextController.text = _goodToEdit!.description;
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
                color: ACCENT_COLORS[index.remainder(ACCENT_COLORS.length)],
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
                            'Merce #${_goods[index].id}',
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
                                        'Elimina merce',
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
                                              'Eliminando la merce non sarà più visibile in questa sezione e tutti gli stati associati saranno rimossi dal sistema.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ).then(
                                    (value) => value != null && value
                                        ? _deleteGood(
                                            _goods[index],
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
                          _goods[index],
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

  Widget _buildAllGoodsWidget() => Column(
        key: ValueKey('Column 1'),
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
                hintText: 'Cerca merci',
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
                    end: _goods.length.toDouble(),
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
                    ' Merci',
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
                    onPressed: () => context.read<GoodsCubit>().fetch(
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
              itemCount: _goods.length,
              itemBuilder: _goodsBuilder,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2,
              ),
            ),
          ),
        ],
      );

  Widget _buildGoodToEditWidget() => Column(
        key: ValueKey('Column 2'),
        children: [
          Row(
            children: [
              MaterialButton(
                onPressed: () => setState(
                  () => _goodToEdit = null,
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
                'Merce #${_goodToEdit!.id}',
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
                  _goodToEdit!.id.toString(),
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
                      value: _goodToEdit!.type,
                      onChanged: (value) => setState(
                        () => _goodToEdit!.type = _types
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
                      width: 800,
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: TextField(
                        decoration: _getInputDecoration(
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
                              builder: (context, setState) => ListView.builder(
                                shrinkWrap: true,
                                itemCount: _goodToEdit!.status.length + 1,
                                itemBuilder: (ctx, index) => _goodStatusBuilder(
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
                        onPressed: () => _editGood(),
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

  Future _editGood() async => await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .editGood(
            _goodToEdit!..description = _descriptionTextController.text,
          )
          .then(
            (value) async => value.statusCode == HttpStatus.ok
                ? await _fetch().then(
                    (value) {
                      setState(() {
                        _goodToEdit = null;
                      });
                      return context.showInfoBar(
                        content: Text(
                          'Merce aggiornata',
                        ),
                      );
                    },
                  )
                : context.showErrorBar(
                    content: Text(
                      'Si è verificato un errore',
                    ),
                  ),
          );

  Future _deleteGood(
    GoodModel goodModel,
  ) async =>
      await ServerService(
        HomeScreen.of(context)!.getUser(),
      )
          .deleteGood(
            goodModel,
          )
          .then(
            (value) async => value.statusCode == HttpStatus.ok
                ? await _fetch().then(
                    (value) => context.showInfoBar(
                      content: Text(
                        'Merce eliminata',
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
  Widget build(BuildContext context) => BlocBuilder<GoodsCubit, GoodsState>(
        builder: (context, goodState) {
          if (goodState is GoodsLoaded) {
            _goods = goodState.goods;
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
                  child: _goodToEdit == null
                      ? _buildAllGoodsWidget()
                      : _buildGoodToEditWidget(),
                ),
              ),
            );
          } else if (goodState is GoodsLoading || goodState is GoodsInitial) {
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
