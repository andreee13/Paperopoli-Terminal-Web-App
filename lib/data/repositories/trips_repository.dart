import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/core/utils/constants.dart';
import 'package:paperopoli_terminal/data/models/trip/trip_model.dart';

class TripsRepository {
  Future<List<TripModel>> fetch({
    required User user,
  }) async =>
      await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/trips/index',
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
                .values
                .map<TripModel>(
                  (item) => TripModel.fromJson(
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
          '$TERMINAL_API_URL/trips/delete/$id',
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
    required TripModel tripModel,
    required User user,
  }) async =>
      http.patch(
        Uri.parse(
          '$TERMINAL_API_URL/trips/edit/${tripModel.id}',
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

  Future<TripModel> create({
    required TripModel tripModel,
    required User user,
  }) async =>
      http.post(
        Uri.parse(
          '$TERMINAL_API_URL/trips/create',
        ),
        headers: {
          HttpHeaders.authorizationHeader: await user.getIdToken(),
          HttpHeaders.contentTypeHeader: ContentType.json.value,
        },
      ).then(
        (response) {
          if (response.statusCode == HttpStatus.ok) {
            return tripModel
              ..id = int.parse(
                response.body,
              );
          } else {
            throw ServerException();
          }
        },
      );
}
