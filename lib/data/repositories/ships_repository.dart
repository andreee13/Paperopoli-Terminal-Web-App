import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/data/models/ship/ship_model.dart';

class ShipsRepository {
  Future<List<ShipModel>> fetch({
    required User user,
  }) async =>
      await ServerService(user).fetchShips().then(
        (response) {
          if (response.statusCode == HttpStatus.ok ||
              response.statusCode == HttpStatus.notModified) {
            var v = <ShipModel>[];
            jsonDecode(response.body).forEach(
              (String k, value) => v.add(
                ShipModel.fromJson(
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
