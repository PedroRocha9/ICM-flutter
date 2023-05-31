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
  CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(0, 0));

  LatLng _festivalLocation = const LatLng(0, 0);

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

    _retrieveFestivalLocation()
        .then((location) => _festivalLocation = location);
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

  Future<LatLng> _retrieveFestivalLocation() async {
    print("SIUUUUU11111111");
    final response =
        await http.get(Uri.parse('http://192.168.154.228:8000/festival/1'));
    print("SIUUUUUUU1.51.51.51.5");
    if (response.statusCode == 200) {
      print("SIUUUUU2222222");
      // If the server returns a 200 OK response, then parse the JSON.
      Map<String, dynamic> json = jsonDecode(response.body);
      double lat = json['lat'];
      double lng = json['lon'];
      print("SIUUUUU");
      print(lat);
      print(lng);
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
            },
          ),
          Positioned(
            bottom: 50.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
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
                IconButton(
                  icon: Icon(Icons.group),
                  onPressed: () {
                    // fetch buddy location from database
                  },
                ),
                IconButton(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
