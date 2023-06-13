import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:urfest/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

void main() {
  runApp(FestivalApp());

  Location location = Location();

  Timer.periodic(Duration(seconds: 1), (Timer timer) async {
    LocationData currentLocation;
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      print('Error: $e');
      return;
    }

    // Make PATCH request to your API
    sendLocationToAPI(currentLocation);
  });
}

void sendLocationToAPI(LocationData locationData) {
  http.patch(Uri.parse('http://192.168.43.168:8000/user/2'),
      body: json.encode({
        'lat': locationData.latitude,
        'lon': locationData.longitude,
      }));
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
      debugShowCheckedModeBanner: false,
    );
  }
}
