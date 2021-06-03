import 'package:flutter/material.dart';

class OperationsWidget extends StatefulWidget {
  @override
  _OperationsWidgetState createState() => _OperationsWidgetState();
}

class _OperationsWidgetState extends State<OperationsWidget> {

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  /*Widget _itemBuilder(
    OperationModel operationModel,
    List<OperationModel> operations,
  ) =>
      Padding(
        padding: EdgeInsets.fromLTRB(
          8,
          0,
          8,
          0,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: operations
                        .where((element) =>
                            element.status == operationModel.status)
                        .first ==
                    operationModel
                ? Radius.circular(
                    10,
                  )
                : Radius.zero,
            bottom: operations
                        .where((element) =>
                            element.status == operationModel.status)
                        .last ==
                    operationModel
                ? Radius.circular(
                    10,
                  )
                : Radius.zero,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 16,
            ),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            title: Text(
              operationModel.id.toString(),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(
                top: 5,
                right: 32,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 15,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            children: [
              SizedBox(
                height: 80,
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: [
                    Timeline.tileBuilder(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ),
                      theme: TimelineThemeData(
                        nodePosition: 0,
                        nodeItemOverlap: true,
                        connectorTheme: ConnectorThemeData(
                          color: Color(0xffe6e7e9),
                          thickness: 15.0,
                        ),
                      ),
                      builder: TimelineTileBuilder.connected(
                        indicatorBuilder: (context, currIndex) {
                          return OutlinedDotIndicator(
                            color: operationModel.status == OperationStatus.done
                                ? Color(0xff6ad192)
                                : Color(0xffe6e7e9),
                            backgroundColor:
                                operationModel.status == OperationStatus.done
                                    ? Color(0xffd4f5d6)
                                    : Color(0xffc2c5c9),
                            borderWidth:
                                operationModel.status == OperationStatus.done
                                    ? 3.0
                                    : 2.5,
                          );
                        },
                        connectorBuilder: (context, index, connectorType) {
                          var color;
                          if (index + 1 < data.length - 1 &&
                              data[index].isInProgress &&
                              data[index + 1].isInProgress) {
                            color = data[index].isInProgress
                                ? Color(0xff6ad192)
                                : null;
                          }
                          return SolidLineConnector(
                            color: color,
                          );
                        },
                        contentsBuilder: (context, index) {
                          var height;
                          if (index + 1 < data.length - 1 &&
                              data[index].isInProgress &&
                              data[index + 1].isInProgress) {
                            height = kTileHeight - 10;
                          } else {
                            height = kTileHeight + 5;
                          }
                          return SizedBox(
                            height: height,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(),
                            ),
                          );
                        },
                        itemCount: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: operationStatus.values
                      .where(
                        (element) => element != operationStatus.values.last,
                      )
                      .map(
                        (status) => MaterialButton(
                          elevation: 0,
                          color:
                              operationModel.status == status ? Colors.green : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              25,
                            ),
                          ),
                          child: Text(
                            operationModel.getStatusName(
                              status,
                            ),
                            style: TextStyle(
                              color: operationModel.status == status
                                  ? Colors.white
                                  : null,
                            ),
                          ),
                          onPressed: () => _changeStatus(
                            operationModel,
                            status,
                          ),
                        ),
                      )
                      .toList()
                      .cast<Widget>() +
                  <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                        ),
                        onPressed: () async => await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              'Elimina nave',
                            ),
                            content: Text(
                              'Vuoi davvero eliminare la nave con ID ${operationModel.id}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(
                                  context,
                                  false,
                                ),
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
                                  'Elimina',
                                ),
                              ),
                            ],
                          ),
                        ).then(
                          (value) => value
                              ? _delete(
                                  operationModel,
                                  operations,
                                )
                              : {},
                        ),
                      ),
                    ),
                  ],
            ),
            
          ),
        ),
      );

  Widget _buildStatusView(
    OperationStatus status,
    List<OperationModel> operations,
  ) =>
      operations
              .where(
                (element) => element.status.last == status,
              )
              .isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
                top: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: Text(
                          OperationModel.getStatusName(
                            operations
                                .where(
                                  (element) => element.status.last == status,
                                )
                                .first
                                .status,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] +
                    operations
                        .where(
                          (element) => element.status == status,
                        )
                        .map(
                          (operation) => _itemBuilder(
                            operation,
                            operations,
                          ),
                        )
                        .toList(),
              ),
            )
          : SizedBox();

  @override
  Widget build(BuildContext context) => Expanded(
        child: BlocBuilder<OperationsCubit, OperationsState>(
          builder: (context, operationState) {
            if (operationState is OperationsLoaded) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  32,
                  32,
                  32,
                  0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Countup(
                          begin: 0,
                          end: operationState.operations.length.toDouble(),
                          curve: Curves.decelerate,
                          duration: Duration(
                            milliseconds: 300,
                          ),
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                          ),
                          child: Text(
                            'Navi',
                            style: TextStyle(
                              fontSize: 45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: OperationStatus.values
                                  .map(
                                    (status) => _buildStatusView(
                                      status,
                                      operationState.operations,
                                    ),
                                  )
                                  .toList() +
                              [
                                SizedBox(
                                  height: 64,
                                ),
                              ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (operationState is OperationsError) {
              return Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Si è verificato un errore',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                      ),
                      child: TextButton(
                        onPressed: () => _fetch(),
                        child: Text(
                          'Riprova',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );
}*/
}
