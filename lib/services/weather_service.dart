import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final String condition;
  final String description;
  final int chanceOfRain;
  final String icon;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.chanceOfRain,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final condition = current['condition'];

    return WeatherData(
      temperature: current['temp_c']?.toDouble() ?? 0.0,
      condition: condition['text'] ?? '',
      description: condition['text'] ?? '',
      chanceOfRain: current['humidity']?.toInt() ?? 0, // Using humidity as chance of rain approximation
      icon: condition['icon'] ?? '',
    );
  }
}

class WeatherService {
  static const String _apiKey = '5b10504cd7474a139ff155141250812';
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  static Future<WeatherData?> getCurrentWeather() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=Casablanca,Morocco&aqi=no'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        // Failed to load weather data
        return null;
      }
    } catch (e) {
      // Error fetching weather data
      return null;
    }
  }
}
