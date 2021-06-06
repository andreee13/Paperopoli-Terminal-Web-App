import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/data/models/vehicle/vehicle_model.dart';

class VehiclesRepository {
  Future<List<VehicleModel>> fetch({
    required User user,
  }) async =>
      await ServerService(user).fetchVehicles().then(
        (response) {
          if (response.statusCode == HttpStatus.ok ||
              response.statusCode == HttpStatus.notModified) {
            var v = <VehicleModel>[];
            jsonDecode(response.body).forEach(
              (String k, value) => v.add(
                VehicleModel.fromJson(
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
