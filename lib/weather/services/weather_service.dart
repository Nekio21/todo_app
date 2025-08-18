import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/weather/models/weather.dart';

class WeatherService {
  WeatherService._();

  static Future<Weather?> fetchWeather() async {
    final Position? position = await _getUserLocation();
    if (position == null) {
      throw Exception();
    }

    final apiKey = dotenv.env['API_KEY'] ?? '';
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$apiKey',
    );

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final Weather weather = Weather.fromJson(jsonDecode(response.body));
      return weather;
    }

    throw Exception();
  }

  static Future<Position?> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }
}
