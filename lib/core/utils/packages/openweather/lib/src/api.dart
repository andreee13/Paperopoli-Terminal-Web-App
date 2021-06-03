import 'dart:async';
import 'dart:convert';
import '../openweather.dart';
import './global.dart';
import 'exeptions.dart';
import 'package:http/http.dart' as http;

class OpenWeatherClient {
  /// API Client for openweather
  String? unit;
  String? language;
  String apiKey;
  String? apiURL;
  String? triggerAPIURL;
  OpenWeatherClient(this.apiKey,
      {String language = 'en',
      String baseURL = BASE_URL,
      String version = VERSION,
      String? unit}) {
    this.language = language;
    apiURL = '$baseURL/data/$version';
    triggerAPIURL = '$baseURL/data/3.0';
    this.unit = unit;
  }

  /// Helper method to genereate timestamp of midday of any given date.
  static int generateMiddayTimestamp(DateTime dateTime) {
    dateTime = dateTime.toUtc();
    var midDay = DateTime.utc(dateTime.year, dateTime.month, dateTime.day, 12);
    return midDay.millisecondsSinceEpoch ~/ 1000;
  }

  /// Helper function to build query parameter string from map data.
  String buildParams([Map<String, dynamic>? params]) {
    var allParams = params ?? {};
    allParams['lang'] = language;
    allParams['APPID'] = apiKey;
    if (unit != null) {
      allParams['unit'] = unit;
    }
    // print(allParams);

    var paramStrings = <String>[];
    allParams.forEach((key, val) => paramStrings.add('$key=${val.toString()}'));
    // print(paramStrings);
    if (paramStrings.isNotEmpty) {
      return "?${paramStrings.join('&')}";
    } else {
      return '';
    }
  }

  /// Helper function to build full URL from path and params.
  String buildURL(String path, [Map<String, dynamic>? params, String? url]) {
    url ??= apiURL;
    return '$url$path${buildParams(params)}';
  }

  /// Get map data from get request.
  Future<Map<String, dynamic>?> mapFromGet(String path,
      [Map<String, dynamic>? params, String? apiURL]) async {
    var url = buildURL(path, params, apiURL);
    try {
      var response = await http.get(
        Uri.parse(url),
      );
      // print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  /// Get map data from post request.
  Future<Map<String, dynamic>?> mapFromPost(String path, dynamic data,
      [Map<String, dynamic>? params, String? apiURL]) async {
    var url = buildURL(path, params, apiURL);
    try {
      var response = await http.post(Uri.parse(url),
          body: jsonEncode(data),
          headers: {'Content-Type': 'application/json'});
      // print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  /// Get map data from put request.
  Future<Map<String, dynamic>?> mapFromPut(String path, dynamic data,
      [Map<String, dynamic>? params, String? apiURL]) async {
    var url = buildURL(path, params, apiURL);
    try {
      var response = await http.put(Uri.parse(url),
          body: jsonEncode(data),
          headers: {'Content-Type': 'application/json'});
      // print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  /// Get list data from get request.
  Future<List<dynamic>?> listFromGet(String path,
      [Map<String, dynamic>? params, String? apiURL]) async {
    var url = buildURL(path, params, apiURL);
    try {
      var response = await http.get(
        Uri.parse(url),
      );
      // print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  /// Get list data from get request.
  Future<bool> statusFromDelete(String path,
      [Map<String, dynamic>? params, String? apiURL]) async {
    var url = buildURL(path, params, apiURL);
    try {
      await http.delete(
        Uri.parse(url),
      );
      // print(response.body);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current weather data by City Name and optionally with country code.
  Future<CityWeather> getCityWeatherByCityName(String city,
      [String? country]) async {
    var params = <String, dynamic>{
      'q': (country == null) ? city : '$city,$country'
    };
    try {
      var data = await (mapFromGet('/weather', params));
      return CityWeather.fromJSON(data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current weather data by City ID.
  Future<CityWeather> getCityWeatherByCityID(int cityID) async {
    var params = <String, dynamic>{'id': cityID};
    try {
      var data = await (mapFromGet('/weather', params)
          as FutureOr<Map<String, dynamic>>);
      return CityWeather.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current weather data by Coordinate.
  Future<CityWeather> getCityWeatherByCoordinate(
      {double? lat, double? lon}) async {
    var params = <String, dynamic>{'lat': lat, 'lon': lon};
    try {
      var data = await (mapFromGet('/weather', params)
          as FutureOr<Map<String, dynamic>>);
      return CityWeather.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current weather data by ZIP code and optionally with country code.
  Future<CityWeather> getCityWeatherByZIPCode(int zip,
      [String? country]) async {
    var params = <String, dynamic>{
      'zip': (country == null) ? '$zip' : '$zip,$country'
    };
    try {
      var data = await (mapFromGet('/weather', params)
          as FutureOr<Map<String, dynamic>>);
      return CityWeather.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current weather from cities in a rectangular geographic region.
  Future<RectLocResponse> getCityWeatherByRectangle(double lonLeft,
      double latBottom, double lonRight, double latTop, int zoom) async {
    var params = <String, dynamic>{
      'bbox': '$lonLeft,$latBottom,$lonRight,$latTop,$zoom'
    };
    try {
      var data = await (mapFromGet('/box/city', params)
          as FutureOr<Map<String, dynamic>>);
      return RectLocResponse.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current weather from cities centered in a coordinate.
  Future<CitiesInCycleResponse> getCitiesWeatherInCycle(double lat, double lon,
      [int cnt = 10]) async {
    var params = <String, dynamic>{'lat': lat, 'lon': lon, 'cnt': cnt};
    try {
      var data =
          await (mapFromGet('/find', params) as FutureOr<Map<String, dynamic>>);
      return CitiesInCycleResponse.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Bulk fetch cities weather by IDs.
  Future<CitiesByIDResponse> getCitiesWeatherbyID(List<int> citiesID) async {
    var params = <String, dynamic>{'id': citiesID.join(',')};
    try {
      var data = await (mapFromGet('/group', params)
          as FutureOr<Map<String, dynamic>>);
      return CitiesByIDResponse.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get hourly forcast by city name, and optionally with country code.
  Future<ForecastResponse> getHourlyForecastByCityName(String city,
      [String? country]) async {
    var params = <String, dynamic>{
      'q': (country == null) ? city : '$city,$country'
    };
    try {
      var data = await (mapFromGet('/forecast/hourly', params)
          as FutureOr<Map<String, dynamic>>);
      return ForecastResponse.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Hourly forecast by cityID
  Future<ForecastResponse> getHourlyForecastByCityID(int cityID) async {
    var params = <String, dynamic>{'id': cityID};
    try {
      var data = await (mapFromGet('/forecast/hourly', params)
          as FutureOr<Map<String, dynamic>>);
      return ForecastResponse.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Hourly forecast by coordinates.
  Future<ForecastResponse> getHourlyForecastByCoordinates(
      {double? lat, double? lon}) async {
    var params = <String, dynamic>{
      'lat': lat,
      'lon': lon,
    };
    try {
      var data = await (mapFromGet('/forecast/hourly', params)
          as FutureOr<Map<String, dynamic>>);
      return ForecastResponse.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Hourly forecast by ZIP code, and optionally with country code.
  Future<ForecastResponse> getHourlyForecastByZipcode(int zip,
      [String? country]) async {
    var params = <String, dynamic>{
      'zip': (country == null) ? zip.toString() : '$zip,$country'
    };
    try {
      var data = await (mapFromGet('/forecast/hourly', params)
          as FutureOr<Map<String, dynamic>>);
      // print(data);
      return ForecastResponse.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 3 Hourly forecast by City Name.
  Future<ForecastResponse> getForecastByCityName(String city,
      [String? country]) async {
    var params = <String, dynamic>{
      'q': (country == null) ? city : '$city,$country'
    };
    try {
      var data = await (mapFromGet('/forecast', params)
          as FutureOr<Map<String, dynamic>>);
      // print(data['message'] is double);
      return ForecastResponse.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 3 Hourly forecast by cityID
  Future<ForecastResponse> getForecastByCityID(int cityID) async {
    var params = <String, dynamic>{'id': cityID};
    try {
      var data = await (mapFromGet('/forecast', params)
          as FutureOr<Map<String, dynamic>>);
      return ForecastResponse.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 3 Hourly forecast by coordinates.
  Future<ForecastResponse> getForecastByCoordinates(
      {double? lat, double? lon}) async {
    var params = <String, dynamic>{
      'lat': lat,
      'lon': lon,
    };
    try {
      var data = await (mapFromGet('/forecast', params)
          as FutureOr<Map<String, dynamic>>);
      return ForecastResponse.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 3 Hourly forecast by ZIP code, and optionally with country code.
  Future<ForecastResponse> getForecastByZipcode(int zip,
      [String? country]) async {
    var params = <String, dynamic>{
      'zip': (country == null) ? zip.toString() : '$zip,$country'
    };
    try {
      var data = await (mapFromGet('/forecast', params)
          as FutureOr<Map<String, dynamic>>);
      return ForecastResponse.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current UVIndex by coordinates.
  Future<UVIndex> getCurrentUVIndexByCoordinates(
      {double? lat, double? lon}) async {
    var params = <String, dynamic>{
      'lat': lat,
      'lon': lon,
    };
    try {
      var data =
          await (mapFromGet('/uvi', params) as FutureOr<Map<String, dynamic>>);
      return UVIndex.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get UVIndex Forecast by coordinates.
  Future<List<UVIndex>> getUVIndexForecastByCoordinates(
      {double? lat, double? lon, int? cnt}) async {
    var params = <String, dynamic>{
      'lat': lat,
      'lon': lon,
    };
    if (cnt != null) {
      if (cnt > 8) {
        throw MAXCNTException();
      }
      params['cnt'] = cnt;
    }
    try {
      var data = await (listFromGet('/uvi/forecast', params)
          as FutureOr<List<dynamic>>);
      return List<UVIndex>.from(data.map((f) => UVIndex.fromJSON(f)));
    } catch (e) {
      rethrow;
    }
  }

  /// Get UVIndex History by coordinates.
  Future<List<UVIndex>> getUVIndexHistoryByCoordinates(
      {double? lat,
      double? lon,
      required DateTime startDate,
      required DateTime endDate}) async {
    var params = <String, dynamic>{
      'lat': lat,
      'lon': lon,
      'start': generateMiddayTimestamp(startDate),
      'end': generateMiddayTimestamp(endDate)
    };
    try {
      var data = await (listFromGet('/uvi/history', params)
          as FutureOr<List<dynamic>>);
      return List<UVIndex>.from(data.map((f) => UVIndex.fromJSON(f)));
    } catch (e) {
      rethrow;
    }
  }

  /// Post data to create a trigger.
  Future<WeatherAlert> postTrigger(dynamic body) async {
    var params = <String, dynamic>{};
    try {
      var data = await (mapFromPost('/triggers/', body, params, triggerAPIURL)
          as FutureOr<Map<String, dynamic>>);
      // print(data);
      return WeatherAlert.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Post data to create a trigger from an [WeatherAlert] object.
  Future<WeatherAlert> postTriggerByWeatherAlert(
      WeatherAlert weatherAlert) async {
    var body = weatherAlert.serialized;
    return postTrigger(body);
  }

  /// Post data to create a trigger.
  Future<WeatherAlert> updateTrigger(String id, dynamic body) async {
    var params = <String, dynamic>{};
    try {
      var data =
          await (mapFromPut('/triggers/$id/', body, params, triggerAPIURL)
              as FutureOr<Map<String, dynamic>>);
      // print(data);
      return WeatherAlert.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Post data to create a trigger from an [WeatherAlert] object.
  Future<WeatherAlert> updateTriggerByWeatherAlert(WeatherAlert weatherAlert,
      [String? id]) async {
    var body = weatherAlert.serialized;
    id ??= weatherAlert.id;
    return updateTrigger(id!, body);
  }

  /// Get a trigger by ID.
  Future<WeatherAlert> getTriggerByID(String id) async {
    try {
      var params = <String, dynamic>{};
      var data = await (mapFromGet('/triggers/$id/', params, triggerAPIURL)
          as FutureOr<Map<String, dynamic>>);
      return WeatherAlert.fromJSON(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all triggers.
  Future<List<WeatherAlert>> getTriggers() async {
    try {
      var params = <String, dynamic>{};
      var data = await (listFromGet('/triggers/', params, triggerAPIURL)
          as FutureOr<List<dynamic>>);
      return List<WeatherAlert>.from(data.map((c) => WeatherAlert.fromJSON(c)));
    } catch (e) {
      rethrow;
    }
  }

  /// Get triggers history.
  Future<List<Alert>> getTriggersHistory(String? id) async {
    try {
      var params = <String, dynamic>{};
      var data =
          await (listFromGet('/triggers/$id/history', params, triggerAPIURL)
              as FutureOr<List<dynamic>>);
      return List<Alert>.from(data.map((c) => Alert.fromJSON(c['_id'], c)));
    } catch (e) {
      rethrow;
    }
  }

  /// Get triggers history by weatherAlert.
  Future<List<Alert>> getTriggersHistoryByWeatherAlert(WeatherAlert wa) async {
    try {
      return getTriggersHistory(wa.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Get historical trigger alert.
  Future<Alert> getHistoricalTriggerAlert(String? id, String alertID) async {
    try {
      var params = <String, dynamic>{};
      var data = await (mapFromGet(
              '/triggers/$id/history/$alertID', params, triggerAPIURL)
          as FutureOr<Map<String, dynamic>>);
      return Alert.fromJSON(data['_id'], data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get historical trigger alert with WeatherAlert
  Future<Alert> getHistoricalTriggerAlertByWeatherAlert(
      WeatherAlert wa, String alertID) async {
    try {
      return getHistoricalTriggerAlert(wa.id, alertID);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteTriggerHistory(String id) async {
    try {
      var params = <String, dynamic>{};
      return await statusFromDelete(
          '/triggers/$id/history', params, triggerAPIURL);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteHistoricalAlert(String id, String alertID) async {
    try {
      var params = <String, dynamic>{};
      return await statusFromDelete(
          '/triggers/$id/history/$alertID', params, triggerAPIURL);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a trigger by ID.
  Future<bool> deleteTrigger(String id) async {
    try {
      var params = <String, dynamic>{};
      return await statusFromDelete('/triggers/$id/', params, triggerAPIURL);
    } catch (e) {
      rethrow;
    }
  }
}
