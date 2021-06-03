import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paperopoli_terminal/core/utils/constants.dart';
import 'package:paperopoli_terminal/core/utils/encoder.dart';
import 'package:paperopoli_terminal/data/models/good/good_model.dart';
import 'package:paperopoli_terminal/data/models/person/person_model.dart';
import 'package:paperopoli_terminal/data/models/ship/ship_model.dart';
import 'package:paperopoli_terminal/data/models/trip/trip_model.dart';
import 'package:paperopoli_terminal/data/models/vehicle/vehicle_model.dart';

class ServerService {
  final User _user;

  const ServerService(
    this._user,
  );

  /* QUAYS */

  Future<http.Response> fetchQuays() async => await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/quays/index',
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  /* VEHICLES */

  Future<http.Response> editVehicle(
    VehicleModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/vehicles/edit',
        ),
        body: jsonEncode(
          model.toJson(),
          toEncodable: customEncoder,
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> createVehicle(
    VehicleModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/vehicles/create',
        ),
        body: jsonEncode(
          model.toJson(),
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> deleteVehicle(
    VehicleModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/vehicles/delete',
        ),
        body: jsonEncode({
          'id': model.id,
        }),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> fetchVehicleTypes() async => await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/vehicles/types',
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> fetchVehiclesStatusNames() async => await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/vehicles/status_names',
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  /* PEOPLE */ 

  Future<http.Response> editPerson(
    PersonModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/people/edit',
        ),
        body: jsonEncode(
          model.toJson(),
          toEncodable: customEncoder,
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> createPerson(
    PersonModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/people/create',
        ),
        body: jsonEncode(
          model.toJson(),
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> deletePerson(
    PersonModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/people/delete',
        ),
        body: jsonEncode({
          'id': model.id,
        }),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> fetchPersonTypes() async => await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/people/types',
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> fetchPeopleStatusNames() async => await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/people/status_names',
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );   

  /* GOODS */

  Future<http.Response> editGood(
    GoodModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/goods/edit',
        ),
        body: jsonEncode(
          model.toJson(),
          toEncodable: customEncoder,
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> createGood(
    GoodModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/goods/create',
        ),
        body: jsonEncode(
          model.toJson(),
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> deleteGood(
    GoodModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/goods/delete',
        ),
        body: jsonEncode({
          'id': model.id,
        }),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> fetchGoodTypes() async => await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/goods/types',
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> fetchGoodsStatusNames() async => await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/goods/status_names',
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  /* SHIPS */

  Future<http.Response> editShip(
    ShipModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/ships/edit',
        ),
        body: jsonEncode(
          model.toJson(),
          toEncodable: customEncoder,
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> createShip(
    ShipModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/ships/create',
        ),
        body: jsonEncode(
          model.toJson(),
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> deleteShip(
    ShipModel model,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/ships/delete',
        ),
        body: jsonEncode({
          'id': model.id,
        }),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> fetchShipTypes() async => await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/ships/types',
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> fetchShipsStatusNames() async => await http.get(
        Uri.parse(
          '$TERMINAL_API_URL/ships/status_names',
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  /* TRIPS */

  Future<http.Response> editTrip(
    TripModel tripModel,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/trips/edit',
        ),
        body: jsonEncode(tripModel),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> createTrip(
    TripModel tripModel,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/trips/create',
        ),
        body: jsonEncode(tripModel),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );

  Future<http.Response> deleteTrip(
    TripModel tripModel,
  ) async =>
      await http.post(
        Uri.parse(
          '$TERMINAL_API_URL/trips/delete',
        ),
        body: jsonEncode({
          'id': tripModel.id,
        }),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.authorizationHeader: await _user.getIdToken(),
        },
      );
}
