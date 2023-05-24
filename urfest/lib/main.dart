import 'package:flutter/material.dart';
import 'package:urfest/screens/home_screen.dart';

void main() {
  runApp(FestivalApp());
}

class FestivalApp extends StatelessWidget {
  const FestivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Festival App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeScreen(),
    );
  }
}
