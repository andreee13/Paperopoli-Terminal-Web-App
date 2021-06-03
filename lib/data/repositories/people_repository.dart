import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/core/utils/constants.dart';
import 'package:paperopoli_terminal/data/models/person/person_model.dart';

class PeopleRepository {
  Future<List<PersonModel>> fetch({
    required User user,
  }) async =>
      await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/people/index',
        ),
        headers: {
          HttpHeaders.authorizationHeader: await user.getIdToken(),
          HttpHeaders.contentTypeHeader: ContentType.json.value,
        },
      ).then((response) {
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
      });
}
