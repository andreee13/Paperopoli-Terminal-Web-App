import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/core/utils/constants.dart';
import 'package:paperopoli_terminal/data/models/vehicle/vehicle_model.dart';

class VehiclesRepository {
  Future<List<VehicleModel>> fetch({
    required User user,
  }) async =>
      await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/vehicles/index',
        ),
        headers: {
          HttpHeaders.authorizationHeader: await user.getIdToken(),
          HttpHeaders.contentTypeHeader: ContentType.json.value,
        },
      ).then((response) {
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
      });
}
