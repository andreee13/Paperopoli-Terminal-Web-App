import 'exeptions.dart';

class CityWeather {
  Coordinate? coord;
  List<Weather>? weather;
  String? base;
  MainWeatherData? main;
  int? visibility;
  Wind? wind;
  Clouds? clouds;
  Rain? rain;
  Snow? snow;
  int? dt;
  Sys? sys;
  int? timezone;
  int? id;
  String? name;
  int? cod;
  String? dtTxt;

  DateTime get timeStamp =>
      DateTime.fromMillisecondsSinceEpoch(dt! * 1000).toUtc();

  CityWeather({
    this.coord,
    this.weather,
    this.base,
    this.main,
    this.visibility,
    this.wind,
    this.clouds,
    this.dt,
    this.sys,
    this.timezone,
    this.id,
    this.name,
    this.cod,
    this.rain,
    this.snow,
    this.dtTxt,
  });

  CityWeather.fromJSON(Map<String, dynamic> data)
      : coord = (data['coord'] != null)
            ? Coordinate.fromJSON(data['coord'])
            : null,
        weather = List<Weather>.from(
            data['weather'].map((w) => Weather.fromJSON(w))),
        base = data['base'],
        main = MainWeatherData.fromJSON(data['main']),
        visibility = data['visibility'],
        snow = (data['snow'] != null) ? Snow.fromJSON(data['snow']) : null,
        rain = (data['rain'] != null) ? Rain.fromJSON(data['rain']) : null,
        wind = (data['wind'] != null) ? Wind.fromJSON(data['wind']) : null,
        clouds = (data['clouds'] != null)
            ? Clouds.fromJSON(data['clouds'])
            : null,
        dt = data['dt'],
        sys = (data['sys'] != null) ? Sys.fromJSON(data['sys']) : null,
        timezone = data['timezone'],
        id = data['id'],
        name = data['name'],
        cod = (data['cod'] is String) ? int.parse(data['cod']) : data['cod'],
        dtTxt = data['dtTxt'];
}

///Rain Data
class Rain {
  double? threeH;
  double? oneH;

  Rain({this.threeH, this.oneH});

  Rain.fromJSON(Map<String, dynamic> data)
      : threeH = data['3h']?.toDouble(),
        oneH = data['1h']?.toDouble();
}

/// Snow Data
class Snow {
  double? threeH;
  double? oneH;
  Snow({this.threeH, this.oneH});

  Snow.fromJSON(Map<String, dynamic> data)
      : threeH = data['3h']?.toDouble(),
        oneH = data['1h']?.toDouble();
}

/// Class representing clould data found in current weather forecast.
class Clouds {
  int? all;
  int? today;

  Clouds({this.all, this.today});
  Clouds.fromJSON(Map<String, dynamic> data)
      : all = data['all'],
        today = data['today'];
}

/// Simple coordinate data.
class Coordinate {
  double? longitude;
  double? latitude;

  double? get lat => latitude;
  double? get lon => longitude;

  Coordinate({
    this.longitude,
    this.latitude,
  });

  Coordinate.fromJSON(Map<String, dynamic> data)
      : longitude = data['lon']?.toDouble(),
        latitude = data['lat']?.toDouble();
}

/// Main weather data in numbers instead of pretty human readable form.
class MainWeatherData {
  double? temperature;
  double? pressure;
  int? humidity;
  double? temperatureMin;
  double? temperatureMax;
  double? seaLevel;
  double? groundLevel;
  double? tempKF;

  double? get temp => temperature;
  double? get tempMax => temperatureMax;
  double? get tempMin => temperatureMin;

  MainWeatherData(
      {this.temperature,
      this.pressure,
      this.humidity,
      this.temperatureMin,
      this.temperatureMax,
      this.seaLevel,
      this.groundLevel,
      this.tempKF});

  MainWeatherData.fromJSON(Map<String, dynamic> data)
      : temperature = data['temp'].toDouble(),
        pressure = data['pressure'].toDouble(),
        humidity = data['humidity'],
        temperatureMax = data['temp_max'].toDouble(),
        temperatureMin = data['temp_min'].toDouble(),
        seaLevel = data['sea_level']?.toDouble(),
        groundLevel = data['grnd_level']?.toDouble(),
        tempKF = data['temp_kf']?.toDouble();
}

/// 'Sys' data, don't know the full form.
class Sys {
  int? type;
  int? id;
  double? message;
  String? country;
  int? sunrise;
  int? sunset;
  String? pod;

  Sys(
      {this.type,
      this.id,
      this.message,
      this.country,
      this.sunrise,
      this.sunset,
      this.pod});

  Sys.fromJSON(Map<String, dynamic> data)
      : type = data['type'],
        id = data['id'],
        message = data['message']?.toDouble(),
        country = data['country'],
        sunrise = data['sunrise'],
        sunset = data['sunset'],
        pod = data['pod'];
}

/// Human readable weather data.
class Weather {
  int? id;
  String? main;
  String? description;
  String? icon;

  Weather({
    this.id,
    this.main,
    this.description,
    this.icon,
  });

  Weather.fromJSON(Map<String, dynamic> data)
      : id = data['id'],
        main = data['main'],
        description = data['description'],
        icon = data['icon'];
}

/// Wind data details.
class Wind {
  double? speed;
  double? degree;

  double? get deg => degree;

  Wind({
    this.speed,
    this.degree,
  });

  Wind.fromJSON(Map<String, dynamic> data)
      : speed = data['speed']?.toDouble(),
        degree = data['deg']?.toDouble();
}

/// A class representing response returned for the query to get all weather
/// data from a rectangular geolocation.
class RectLocResponse {
  int? cod;
  double? calculationTime;
  int? cnt;
  List<CityWeather>? list;

  double? get calctime => calculationTime;

  RectLocResponse({this.cod, this.calculationTime, this.cnt, this.list});

  RectLocResponse.fromJSON(Map<String, dynamic> data)
      : cod = (data['cod'] is String) ? int.parse(data['cod']) : data['cod'],
        calculationTime = data['calctime'],
        cnt = data['cnt'],
        list = List<CityWeather>.from(
            data['list'].map((w) => CityWeather.fromJSON(w)));
}

///A class representing response returned from the query to get all weather
/// data from a circle of area
class CitiesInCycleResponse {
  String? message;
  int? cod;
  int? count;
  List<CityWeather>? list;

  CitiesInCycleResponse({this.cod, this.message, this.count, this.list});

  CitiesInCycleResponse.fromJSON(Map<String, dynamic> data)
      : cod = (data['cod'] is String) ? int.parse(data['cod']) : data['cod'],
        count = data['count'],
        message = data['message'],
        list = List<CityWeather>.from(
            data['list'].map((w) => CityWeather.fromJSON(w)));
}

/// Class representing response for bulk data request for cities by id
class CitiesByIDResponse {
  int? cnt;
  List<CityWeather>? list;

  CitiesByIDResponse({this.cnt, this.list});

  CitiesByIDResponse.fromJSON(Map<String, dynamic> data)
      : cnt = data['cnt'],
        list = List<CityWeather>.from(
            data['list'].map((w) => CityWeather.fromJSON(w)));
}

/// Hourly Forecast
class ForecastResponse {
  double? message;
  int? cod;
  int? cnt;
  List<CityWeather>? list;

  ForecastResponse({this.cod, this.message, this.cnt, this.list});

  ForecastResponse.fromJSON(Map<String, dynamic> data)
      : cod = (data['cod'] is String) ? int.parse(data['cod']) : data['cod'],
        cnt = data['cnt'],
        message = (data['message'] is String)
            ? double.parse(data['message'])
            : data['message'],
        list = List<CityWeather>.from(
            data['list'].map((w) => CityWeather.fromJSON(w)));
}

/// UV index data class
class UVIndex {
  double? longitude;
  double? latitude;
  int? date;
  String? dateISO;
  double? value;

  double? get lat => latitude;
  double? get lon => longitude;
  DateTime get timeStamp =>
      DateTime.fromMillisecondsSinceEpoch(date! * 1000).toUtc();

  UVIndex({this.longitude, this.latitude, this.date, this.dateISO, this.value});

  UVIndex.fromJSON(Map<String, dynamic> data)
      : longitude = data['lon'],
        latitude = data['lat'],
        date = data['date'],
        dateISO = data['date_iso'],
        value = (data['value'] is String)
            ? double.parse(data['value'])
            : data['value'];
}

// Trigger API Classes

/// Time Period condition class.
class TimePeriodCondition {
  static const AFTER = 'after';
  static const BEFORE = 'before';
  static const EXACT = 'exact';
  static const _availableValues = [AFTER, BEFORE, EXACT];

  String? _expression;
  int? amount;

  /// Get expression value.
  String? get expression => _expression;

  /// Set expression value from the permitted values.
  set expression(String? value) {
    if (TimePeriodCondition._availableValues.contains(value)) {
      _expression = value;
    } else {
      throw ValueNotPermittedException();
    }
  }

  TimePeriodCondition({expression, this.amount}) {
    this.expression = expression;
  }

  TimePeriodCondition.fromJSON(Map<String, dynamic> data) {
    amount = data['amount'];
    expression = data['expression'];
  }

  /// Get serialized data for easy JSON endcode.
  Map<String, dynamic> get serialized =>
      {'amount': amount, 'expression': expression};
}

/// Time period condition class.
class TimePeriod {
  TimePeriodCondition? start;
  TimePeriodCondition? end;

  TimePeriod({this.start, this.end});

  TimePeriod.fromJSON(Map<String, dynamic> data)
      : start = (data['start'] != null)
            ? TimePeriodCondition.fromJSON(data['start'])
            : data['start'],
        end = (data['end'] != null)
            ? TimePeriodCondition.fromJSON(data['end'])
            : data['end'];

  /// Get serialized data for easy JSON endcode.
  Map<String, dynamic> get serialized =>
      {'start': start!.serialized, 'end': end!.serialized};
}

/// Trigger condition class.
class Condition {
  static const TEMP = 'temp';
  static const PRESSURE = 'pressure';
  static const HUMIDITY = 'humidity';
  static const WIND_SPEED = 'wind_speed';
  static const WIND_DIRECTION = 'wind_direction';
  static const CLOUDS = 'clouds';

  static const _availableNames = [
    TEMP,
    PRESSURE,
    HUMIDITY,
    WIND_DIRECTION,
    WIND_SPEED,
    CLOUDS
  ];

  static const EXP_GT = '\$gt';
  static const EXP_GTE = '\$gte';
  static const EXP_LT = '\$lt';
  static const EXP_LTE = '\$lte';
  static const EXP_EQ = '\$eq';
  static const EXP_NE = '\$ne';

  static const _avaliableExpressions = [
    EXP_EQ,
    EXP_GT,
    EXP_GTE,
    EXP_LT,
    EXP_LTE,
    EXP_NE
  ];

  String? _name;
  String? _expression;
  dynamic _amount;

  /// Get name value.
  String? get name => _name;

  /// Set name value if the value is amongst the permitted values.
  set name(String? val) {
    if (Condition._availableNames.contains(val)) {
      _name = val;
    } else {
      throw ValueNotPermittedException();
    }
  }

  /// Get expression value.
  String? get expression => _expression;

  /// Set expression value if the value is amongst the permitted values.
  set expression(String? val) {
    if (Condition._avaliableExpressions.contains(val)) {
      _expression = val;
    } else {
      throw ValueNotPermittedException();
    }
  }

  /// Get amount value.
  dynamic get amount => _amount;

  /// Check and set amount if the value is either int or double.
  set amount(dynamic val) {
    if (val is int || val is double) {
      _amount = val;
    } else {
      throw ValueNotPermittedException();
    }
  }

  Condition({name, expression, amount}) {
    this.name = name;
    this.expression = expression;
    this.amount = amount;
  }

  Condition.fromJSON(Map<String, dynamic> data) {
    name = data['name'];
    expression = data['expression'];
    amount = data['amount'];
  }

  /// Get serialized data for easy JSON endcode.
  Map<String, dynamic> get serialized =>
      {'name': name, 'expression': expression, 'amount': amount};
}

/// Area class
class Area {
  String? id;
  String? type;
  Coordinates? coordinates;

  Area({this.id, this.type, this.coordinates});

  Area.fromJSON(Map<String, dynamic> data)
      : type = data['type'],
        id = data['_id'],
        coordinates = Coordinates.fromJSON(data);

  Map<String, dynamic> get serialized =>
      {'type': type, 'coordinates': coordinates!.serialized};
}

/// Base Coordinates class with factory.
class Coordinates {
  static List<int?> serializeCoordinates(Coordinate c) {
    return [c.latitude?.toInt(), c.longitude?.toInt()];
  }

  Coordinates();

  factory Coordinates.fromJSON(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'Point':
        return Point.fromJSON(data['coordinates']);
      case 'MultiPoint':
        return MultiPoint.fromJSON(data['coordinates']);
      case 'Polygon':
        return Polygon.fromJSON(data['coordinates']);
      case 'MultiPolygon':
        return MultiPolygon.fromJSON(data['coordinates']);
      default:
        return Coordinates();
    }
  }

  List<dynamic> get serialized => [];
}

/// Point data structure for Coordinates definition.
class Point extends Coordinates {
  Coordinate? coordinate;

  Point({this.coordinate});
  Point.fromJSON(List<dynamic> data) {
    coordinate = Coordinate(
        latitude: data[0]?.toDouble(), longitude: data[1]?.toDouble());
  }

  /// Get serialized data for easy JSON endcode.
  @override
  List<dynamic> get serialized => Coordinates.serializeCoordinates(coordinate!);
}

/// MultiPoint data structure (composed of a list of [Point]s) for Coordinates definition.
class MultiPoint extends Coordinates {
  List<Point>? coordinates;

  MultiPoint({this.coordinates});
  MultiPoint.fromJSON(List<dynamic> data) {
    coordinates = List<Point>.from(data.map((c) => Point.fromJSON(c)));
  }

  /// Get serialized data for easy JSON endcode.
  @override
  List<dynamic> get serialized =>
      coordinates!.map((c) => c.serialized).toList();
}

/// Polygon data structure (composed of two [MulitPoint]s) for Coordinates definition.
class Polygon extends Coordinates {
  MultiPoint? area;
  MultiPoint? hole;
  Polygon({this.area, this.hole});
  Polygon.fromJSON(List<dynamic> data) {
    area = MultiPoint.fromJSON(data[0]);
    if (data.isNotEmpty) {
      hole = MultiPoint.fromJSON(data[1]);
    }
  }

  /// Get serialized data for easy JSON endcode.
  @override
  List<dynamic> get serialized {
    var data = <dynamic>[area!.serialized];
    if (hole != null) {
      data.add(hole!.serialized);
    }
    return data;
  }
}

/// Point data structure (composed of a list of [Polygon]s) for Coordinates definition.
class MultiPolygon extends Coordinates {
  List<Polygon>? polygons;

  MultiPolygon({this.polygons});
  MultiPolygon.fromJSON(List<dynamic> data) {
    polygons = List<Polygon>.from(data.map((c) => Polygon.fromJSON(c)));
  }

  @override
  List<dynamic> get serialized => polygons!.map((c) => c.serialized).toList();
}

/// Current Value for [Alert].
class CurrentValue {
  dynamic _min;
  dynamic _max;

  /// Get min value.
  dynamic get min => _min;

  /// Check and set min if the value is either int or double.
  set min(dynamic val) {
    if (val is int || val is double) {
      _min = val;
    } else {
      throw ValueNotPermittedException();
    }
  }

  /// Get max value.
  dynamic get max => _max;

  /// Check and set max if the value is either int or double.
  set max(dynamic val) {
    if (val is int || val is double) {
      _max = val;
    } else {
      throw ValueNotPermittedException();
    }
  }

  CurrentValue({dynamic min, dynamic max}) {
    this.min = min;
    this.max = max;
  }

  CurrentValue.fromJSON(Map<String, dynamic> data) {
    min = data['min'];
    max = data['max'];
  }
}

/// Alart Condition data.
class AlertCondition {
  CurrentValue? currentValue;
  Condition? condition;

  AlertCondition({this.currentValue, this.condition});

  AlertCondition.fromJSON(Map<String, dynamic> data)
      : currentValue = CurrentValue.fromJSON(data['current_value']),
        condition = Condition.fromJSON(data['condition']);
}

/// Alert class for triggers
class Alert {
  String? id;
  List<AlertCondition>? conditions;
  int? lastUpdated;
  int? date;
  Coordinate? coordinates;

  Alert(
      {this.id,
      this.conditions,
      this.lastUpdated,
      this.date,
      this.coordinates});

  Alert.fromJSON(this.id, Map<String, dynamic> data)
      : lastUpdated = data['last_updated'],
        date = data['date'],
        coordinates = Coordinate.fromJSON(data['coordinates']),
        conditions = List<AlertCondition>.from(
            data['conditions'].map((c) => AlertCondition.fromJSON(c)));
}

class WeatherAlert {
  int? v;
  String? id;
  Map<String, Alert>? alerts;
  List<Area>? area;
  List<Condition>? conditions;
  TimePeriod? timePeriod;

  WeatherAlert(
      {this.v,
      this.id,
      this.alerts,
      this.area,
      this.conditions,
      this.timePeriod});

  WeatherAlert.fromJSON(Map<String, dynamic> data) {
    v = data['__v'];
    id = data['_id'];
    if (data['alerts'] != null) {
      alerts = (data['alerts'] as Map<String, dynamic>).map((k, v) {
        var al = Alert.fromJSON(k, v);
        return MapEntry(k, al);
      });
    }
    area = List<Area>.from(data['area'].map((c) => Area.fromJSON(c)));
    conditions = List<Condition>.from(
        data['conditions'].map((c) => Condition.fromJSON(c)));
    timePeriod = TimePeriod.fromJSON(data['time_period']);
  }

  Map<String, dynamic> get serialized => {
        'area': area!.map((c) => c.serialized).toList(),
        'conditions': conditions!.map((c) => c.serialized).toList(),
        'time_period': timePeriod!.serialized
      };
}
