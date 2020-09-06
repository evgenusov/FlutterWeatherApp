import 'package:WeatherApp/models/Weather.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoadInProgress extends WeatherState {}

class WeatherLoadSuccess extends WeatherState {
  final Weather weather;
  final List<Weather> hourlyWeather;

  const WeatherLoadSuccess(
      {@required this.weather, @required this.hourlyWeather})
      : assert(weather != null);

  @override
  List<Object> get props => [weather, hourlyWeather];
}

class WeatherLoadFailure extends WeatherState {}
