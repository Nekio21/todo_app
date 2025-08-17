import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService{
  WeatherService._();

  static Future<void> fetchWeather() async {
    final Position? position= await _getUserLocation();
    if(position == null){
      return;
    }

    final apiKey = 'TWOJ KLUCZ';
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$apiKey');

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Temperatura: ${data['main']['temp']}°C');
      print('Miasto: ${data['name']}');
    } else {
      print('Błąd pobierania danych: ${response.statusCode}');
    }
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
      accuracy: LocationAccuracy.high, // replaces desiredAccuracy
      distanceFilter: 10, // optional, meters
    );

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings);
  }
}