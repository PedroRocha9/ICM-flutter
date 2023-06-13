import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:urfest/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

void main() async {
  await Hive.initFlutter();

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
      home: LoginPage(), // Set the LoginPage as the initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveUsername(context),
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }

  _saveUsername(BuildContext context) async {
    String username = _usernameController.text;

    http.get(Uri.parse("http://192.168.43.168:8000/user/user5")).then((body) async {
      // check code status
      if (body.statusCode == 200) {
        // get response body
        Map<String, dynamic> user = json.decode(body.body);
        // check if username is in response body
        if (user['username'] == username) {
          // save id to Hive
          var box = await Hive.openBox<int>('userBox');
          await box.put('userBox', user['id']);

          // Navigate to HomeScreen if username is in response body
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          // Show error message if username is not in response body
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Username not found")));
        }
      } else {
        // Show error message if code status is not 200
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error")));
      }
    });
  }
}