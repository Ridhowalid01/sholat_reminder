import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../models/prayer_time_cubit.dart';

// Definisikan State (tetap sama)
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

// Definisikan Cubit
class LocationCubit extends Cubit<LocationState> {
  final PrayerTimeCubit prayerTimeCubit;

  LocationCubit(this.prayerTimeCubit) : super(LocationInitial());

  Future<void> getCurrentLocation() async {
    try {
      emit(LocationLoading());


      // 1. Periksa Izin (tetap sama)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(LocationError('Izin lokasi ditolak.'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(LocationError(
            'Izin lokasi ditolak secara permanen, buka pengaturan aplikasi.'));
        return;
      }

      // 2. Periksa Layanan Lokasi (tetap sama)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationError('Layanan lokasi tidak aktif.'));
        return;
      }

      // 3. Dapatkan Lokasi (INI BAGIAN YANG BERUBAH)
      // Tentukan pengaturan lokasi
      LocationSettings locationSettings;

      // Anda bisa menyesuaikan pengaturan per platform jika perlu
      // Contoh sederhana menggunakan LocationAccuracy.high untuk semua
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, // Akurasi yang diinginkan
        distanceFilter:
            100, // Jarak minimum (dalam meter) sebelum update lokasi (opsional)
      );

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings); // Gunakan locationSettings

      prayerTimeCubit.loadPrayerTimes(position.latitude, position.longitude);

      emit(LocationLoaded(position));
    } catch (e) {
      emit(LocationError('Gagal mendapatkan lokasi: ${e.toString()}'));
    }
  }

  Future<String?> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        return '${place.subAdministrativeArea}, ${place.administrativeArea}';
      } else {
        return 'Alamat tidak ditemukan';
      }
    } catch (e) {
      return 'Gagal mendapatkan alamat: ${e.toString()}';
    }
  }
}
