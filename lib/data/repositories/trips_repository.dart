import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/data/models/trip/trip_model.dart';

class TripsRepository {
  Future<List<TripModel>> fetch({
    required User user,
  }) async =>
      await ServerService(user).fetchTrips().then(
        (response) {
          if (response.statusCode == HttpStatus.ok ||
              response.statusCode == HttpStatus.notModified) {
            var v = <TripModel>[];
            jsonDecode(response.body).forEach(
              (String k, value) => v.add(
                TripModel.fromJson(
                  value,
                ),
              ),
            );
            return v;
          } else {
            throw ServerException();
          }
        },
      );
}
