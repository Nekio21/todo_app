class Weather {
  final String icon;
  final double temp;
  final double feelTemp;
  final double rain;
  final double clouds;

  Weather({
    required this.icon,
    required this.temp,
    required this.feelTemp,
    required this.rain,
    required this.clouds,
  });

  factory Weather.fromJson(Map<String, Object?> json) {
    final weather = (json['weather'] as List<Object?>).first as Map<String, Object?>;
    final main = json['main'] as Map<String, Object?>;
    final rain = json['rain'] as Map<String, Object?>?;
    final clouds = json['clouds'] as Map<String, Object?>?;

    return Weather(
      icon: weather['icon'] as String,
      temp: (main['temp'] as num).toDouble(),
      feelTemp: (main['feels_like'] as num).toDouble(),
      rain: rain!= null ? (rain['1h'] as num).toDouble() : 0,
      clouds: clouds != null ? (clouds['all'] as num).toDouble() : 0,
    );
  }
}
