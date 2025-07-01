import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/location_cubit.dart';

class LocationDisplay extends StatelessWidget {
  const LocationDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state is LocationLoaded) {
          final position = state.position;

          return FutureBuilder<String?>(
            future:
                context.read<LocationCubit>().getAddressFromPosition(position),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Mencari alamat..");
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                return Text(
                  '${snapshot.data}',
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w500),
                );
              }
            },
          );
        } else if (state is LocationError) {
          return Text("Error: ${state.message}");
        }
        return const Text("Memuat..");
      },
    );
  }
}
