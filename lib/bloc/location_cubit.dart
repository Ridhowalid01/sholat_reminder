import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_time_cubit.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final Position position;

  LocationLoaded(this.position);
}

class LocationError extends LocationState {
  final String message;

  LocationError(this.message);
}

class LocationCubit extends Cubit<LocationState> {
  final PrayerTimeCubit prayerTimeCubit;

  LocationCubit(this.prayerTimeCubit) : super(LocationInitial());

  /// Ambil lokasi dari cache atau GPS (dipanggil saat app pertama kali)
  Future<void> getCurrentLocation() async {
    emit(LocationLoading());
    final prefs = await SharedPreferences.getInstance();

    // Coba dari cache
    final lat = prefs.getDouble('latitude');
    final lng = prefs.getDouble('longitude');

    if (lat != null && lng != null) {
      _updatePosition(Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ));
    } else {
      await _fetchLocationFromGPS();
    }
  }

  Future<void> refreshLocation() async {
    emit(LocationLoading());
    await _fetchLocationFromGPS();
  }

  Future<void> updateLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', lat);
    await prefs.setDouble('longitude', lng);

    _updatePosition(Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    ));
  }

  Future<String?> getAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.subAdministrativeArea}, ${place.administrativeArea}';
      }
      return 'Alamat tidak ditemukan';
    } catch (e) {
      return 'Gagal mendapatkan alamat: ${e.toString()}';
    }
  }

  Future<void> _fetchLocationFromGPS() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        emit(LocationError('Layanan lokasi tidak aktif.'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(LocationError('Izin lokasi ditolak.'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(LocationError('Izin lokasi ditolak permanen.'));
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);

      _updatePosition(position);
    } catch (e) {
      emit(LocationError('Gagal mendapatkan lokasi: ${e.toString()}'));
    }
  }

  void _updatePosition(Position position) {
    emit(LocationLoaded(position));
    prayerTimeCubit.loadPrayerTimes(position.latitude, position.longitude);
  }
}
