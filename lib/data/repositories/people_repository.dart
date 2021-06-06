import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/core/services/server_service.dart';
import 'package:paperopoli_terminal/data/models/person/person_model.dart';

class PeopleRepository {
  Future<List<PersonModel>> fetch({
    required User user,
  }) async =>
      await ServerService(user).fetchPeople().then(
        (response) {
          if (response.statusCode == HttpStatus.ok ||
              response.statusCode == HttpStatus.notModified) {
            var v = <PersonModel>[];
            jsonDecode(response.body).forEach(
              (String k, value) => v.add(
                PersonModel.fromJson(
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
