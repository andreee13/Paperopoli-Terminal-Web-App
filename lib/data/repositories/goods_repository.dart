import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/data/models/good/good_model.dart';

class GoodsRepository {
  Future<List<GoodModel>> fetch({
    required User user,
  }) async =>
      await ServerService(user).fetchGoods().then(
        (response) {
          if (response.statusCode == HttpStatus.ok ||
              response.statusCode == HttpStatus.notModified) {
            var v = <GoodModel>[];
            jsonDecode(response.body).forEach(
              (String k, value) => v.add(
                GoodModel.fromJson(
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
