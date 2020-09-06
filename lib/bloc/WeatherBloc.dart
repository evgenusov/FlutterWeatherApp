import 'dart:async';

import 'package:WeatherApp/events/WeatherEvent.dart';
import 'package:WeatherApp/models/Weather.dart';
import 'package:WeatherApp/services/WeatherService.dart';
import 'package:WeatherApp/states/WeatherState.dart';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(null) {
    add(WeatherCurrentPositionRequested());
  }

  @override
  Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
    if (event is WeatherRequested) {
      yield* _newWeatherRequested(event);
    }
    if (event is WeatherCurrentPositionRequested) {
      yield* _newWeatherCurrentPositionRequested();
    }
  }

  Stream<WeatherState> _newWeatherRequested(WeatherRequested event) async* {
    yield WeatherLoadInProgress();
    try {
      final Weather weather = await WeatherService.fetchCurrentWeather(
          query: event.city, lon: event.lon, lat: event.lat);
      final List<Weather> hourlyWeather =
          await WeatherService.fetchHourlyWeather(
              query: event.city, lon: event.lon, lat: event.lat);
      yield WeatherLoadSuccess(weather: weather, hourlyWeather: hourlyWeather);
    } catch (e) {
      yield WeatherLoadFailure();
    }
  }

  Stream<WeatherState> _newWeatherCurrentPositionRequested() async* {
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position lastKnownPosition = await getLastKnownPosition();
      if(lastKnownPosition != null) {
        add(WeatherRequested(
            lat: lastKnownPosition.latitude.toString(),
            lon: lastKnownPosition.longitude.toString()));

      } else {
        Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        add(WeatherRequested(
            lat: position.latitude.toString(),
            lon: position.longitude.toString()));
      }
    } else {
      await requestPermission();
      add(WeatherCurrentPositionRequested());
    }
  }
}
