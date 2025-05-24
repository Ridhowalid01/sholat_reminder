import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 250, // atur lebar agar cukup luas
        leading: Container(
          color: Colors.red.withOpacity(0.3),
          // warna transparan agar tetap bisa melihat isi
          padding: const EdgeInsets.only(left: 16),
          child: const Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.blueAccent,
                size: 24,
              ),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  "Pamekasan, Jawa Timur",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.dark_mode_outlined,
              color: Colors.blueAccent,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
