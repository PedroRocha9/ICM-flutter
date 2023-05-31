// python3 manage.py runserver 192.168.154.228:8000 ---> API RUN
// TODO: marker for festival location
// TODO: buddy location fetch and marker
// TODO: Place correctly the buttons

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FindBuddyPage extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<FindBuddyPage> {
  GoogleMapController? _googleMapController;
  LocationData? _locationData;
  
  Marker _home = const Marker(markerId: MarkerId('home'));
  Marker _festival = const Marker(markerId: MarkerId('festival'));
  Marker _buddy = const Marker(markerId: MarkerId('buddy'));

  LatLng _festivalLocation = const LatLng(0, 0);
  LatLng _buddyLocation = const LatLng(0, 0);

  CameraPosition _initialCameraPosition =
    const CameraPosition(target: LatLng(0, 0));

  @override
  void initState() {
    super.initState();
    _retrieveLocation().then((location) {
      _home = Marker(
        markerId: const MarkerId('home'),
        position: LatLng(location!.latitude!, location.longitude!),
        infoWindow: const InfoWindow(title: 'Home'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      _initialCameraPosition = CameraPosition(
        target: LatLng(location.latitude!, location.longitude!),
        zoom: 11.5,
      );
    });

    _retrieveLocationAPI("festival/1")
        .then((location) {
          _festivalLocation = location;
          _festival = Marker(
            markerId: const MarkerId('festival'),
            position: location,
            infoWindow: const InfoWindow(title: 'Festival'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          );
        });

    _retrieveLocationAPI("user/2/buddies/3")
      .then((location) {
        _buddyLocation = location;
        _buddy = Marker(
          markerId: const MarkerId('buddy'),
          position: location,
          infoWindow: const InfoWindow(title: 'Buddy'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue),
        );
      });
  }

  Future<LocationData?> _retrieveLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();

    setState(() {}); // Call setState to trigger a rebuild of the widget.

    return _locationData;
  }

  Future<LatLng> _retrieveLocationAPI(String endpoint) async {
    final response =
        await http.get(Uri.parse('http://192.168.43.168:8000/$endpoint'));
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, then parse the JSON.
      Map<String, dynamic> json = jsonDecode(response.body);
      double lat = json['lat'];
      double lng = json['lon'];
      return LatLng(lat, lng);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load festival location');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              _home,
              _festival,
              _buddy,
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded( // Add Expanded widget here
                  child: Container(
                    color: Colors.white, // Set the background color to white
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      onPressed: () {
                        // animate to festival's location
                        if (_festivalLocation != null) {
                          _googleMapController?.animateCamera(
                            CameraUpdate.newCameraPosition(CameraPosition(
                              target: _festivalLocation,
                              zoom: 11.5,
                            )),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Expanded( // Add Expanded widget here
                  child: Container(
                    color: Colors.white, // Set the background color to white
                    child: IconButton(
                      icon: Icon(Icons.group),
                      onPressed: () {
                        // fetch buddy location from database
                        if (_buddyLocation != null) {
                          _googleMapController?.animateCamera(
                            CameraUpdate.newCameraPosition(CameraPosition(
                              target: _buddyLocation,
                              zoom: 11.5,
                            )),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Expanded( // Add Expanded widget here
                  child: Container(
                    color: Colors.white, // Set the background color to white
                    child: IconButton(
                      icon: Icon(Icons.person_pin_circle),
                      onPressed: () {
                        // animate to user's location
                        if (_locationData != null) {
                          _googleMapController?.animateCamera(
                            CameraUpdate.newCameraPosition(CameraPosition(
                              target: LatLng(_locationData!.latitude!,
                                  _locationData!.longitude!),
                              zoom: 11.5,
                            )),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
