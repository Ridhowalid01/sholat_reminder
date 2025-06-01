import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  LocationCubit() : super(LocationInitial());

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
        emit(LocationError('Izin lokasi ditolak secara permanen, buka pengaturan aplikasi.'));
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
        distanceFilter: 100, // Jarak minimum (dalam meter) sebelum update lokasi (opsional)
      );

      // Jika Anda ingin pengaturan yang lebih spesifik per platform:
      /*
      if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          forceLocationManager: true, // Contoh pengaturan spesifik Android
          // intervalDuration: const Duration(seconds: 10), // Opsional
          // foregroundNotificationConfig: const ForegroundNotificationConfig( // Opsional
          //    notificationText: "Example app will continue to receive your location even when you aren't using it",
          //    notificationTitle: "Running in Background",
          //    enableWakeLock: true,
          // )
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          activityType: ActivityType.fitness, // Contoh pengaturan spesifik Apple
          distanceFilter: 100,
          pauseAutomatically: true, // Opsional
          // showBackgroundLocationIndicator: true, // Opsional
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        );
      }
      */

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings); // Gunakan locationSettings
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
        // Kamu bisa sesuaikan output-nya sesuai kebutuhan
        // return '${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}';
        return '${place.subAdministrativeArea}, ${place.administrativeArea}';
      } else {
        return 'Alamat tidak ditemukan';
      }
    } catch (e) {
      return 'Gagal mendapatkan alamat: ${e.toString()}';
    }
  }
}