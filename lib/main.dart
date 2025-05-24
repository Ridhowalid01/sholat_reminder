import 'package:flutter/material.dart';
import 'package:sholat_reminder/pages/home_screen.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sholat Reminder App',
      debugShowCheckedModeBanner: false,
      home: HomeScreen()
    );
  }
}
