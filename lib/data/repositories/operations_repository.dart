import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/core/utils/constants.dart';
import 'package:paperopoli_terminal/data/models/operation/operation_model.dart';

class OperationsRepository {
  Future<List<OperationModel>> fetch({
    required User user,
  }) async =>
      await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/operations/index',
        ),
        headers: {
          HttpHeaders.authorizationHeader: await user.getIdToken(),
          HttpHeaders.contentTypeHeader: ContentType.json.value,
        },
      ).then(
        (response) {
          if (response.statusCode == HttpStatus.ok ||
              response.statusCode == HttpStatus.notModified) {
            return jsonDecode(
              response.body,
            )
                .map<OperationModel>(
                  (item) => OperationModel.fromJson(
                    item,
                  ),
                )
                .toList();
          } else {
            throw ServerException();
          }
        },
      );

  Future<void> delete({
    required int id,
    required User user,
  }) async =>
      http.delete(
        Uri.parse(
          '$TERMINAL_API_URL/operations/delete/$id',
        ),
        headers: {
          HttpHeaders.authorizationHeader: await user.getIdToken(),
          HttpHeaders.contentTypeHeader: ContentType.json.value,
        },
      ).then(
        (response) {
          if (response.statusCode != HttpStatus.ok) {
            throw ServerException();
          }
        },
      );

  Future<void> edit({
    required OperationModel operationModel,
    required User user,
  }) async =>
      http.patch(
        Uri.parse(
          '$TERMINAL_API_URL/operations/edit/${operationModel.id}',
        ),
        headers: {
          HttpHeaders.authorizationHeader: await user.getIdToken(),
          HttpHeaders.contentTypeHeader: ContentType.json.value,
        },
      ).then(
        (response) {
          if (response.statusCode != HttpStatus.ok) {
            throw ServerException();
          }
        },
      );

  Future<OperationModel> create({
    required OperationModel operationModel,
    required User user,
  }) async =>
      http.post(
        Uri.parse(
          '$TERMINAL_API_URL/operations/create',
        ),
        headers: {
          HttpHeaders.authorizationHeader: await user.getIdToken(),
          HttpHeaders.contentTypeHeader: ContentType.json.value,
        },
      ).then(
        (response) {
          if (response.statusCode == HttpStatus.ok) {
            return operationModel
              ..id = int.parse(
                response.body,
              );
          } else {
            throw ServerException();
          }
        },
      );
}
