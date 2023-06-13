// python3 manage.py runserver 192.168.154.228:8000 ---> API RUN
// TODO: null location buddy
// TODO: bloc // offline or cache with Hive
// TODO: Lineup
// TODO: Login and Register

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  bool _showBuddyMaker = false;

  LatLng _homeLocation = const LatLng(0, 0);
  LatLng _festivalLocation = const LatLng(0, 0);
  LatLng _buddyLocation = const LatLng(0, 0);
  Box<LatLng>? _homeLocationBox;
  Box<LatLng>? _festivalLocationBox;

  CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(0, 0));

  List<String> _buddies = [];
  List<String> _filteredBuddies = [];
  bool _isListViewOpen = true;

  @override
  void initState() {
    super.initState();

    initializeHiveAndOpenBoxes();
  }

  Future<void> initializeHiveAndOpenBoxes() async {
    await openHiveBoxes(); // Open the Hive boxes

    fetchHomeLocationFromCache();
    fetchFestivalLocationFromCache();

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

      setState(() {
        _homeLocation = LatLng(location.latitude!, location.longitude!);
        _homeLocationBox?.put('home', _homeLocation);
        print("HOME LOCATION SAVED");

        LatLng? h = _homeLocationBox!.get('home');
        print(h?.latitude);
        print(h?.longitude);
      });
    });

    _retrieveLocationAPI("festival/1").then((location) {
      _festivalLocation = location;
      _festival = Marker(
        markerId: const MarkerId('festival'),
        position: location,
        infoWindow: const InfoWindow(title: 'Festival'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      setState(() {
        _festivalLocationBox?.put('festival', _festivalLocation);
      });
    });

    _retrieveBuddies().then((buddies) => _buddies = buddies);
  }

    Future<void> openHiveBoxes() async {
    await Hive.initFlutter();
    await Hive.openBox<LatLng>('home').then((box) => {
        _homeLocationBox = box,
    });
    await Hive.openBox<LatLng>('festival').then((box) => {
        _festivalLocationBox = box,
    });
  }

  Future<void> fetchHomeLocationFromCache() async {
    print("INSIDE FETCH HOME LOCATION");
    if (_homeLocationBox != null && _homeLocationBox!.isOpen) {
      final LatLng? homeLocation = _homeLocationBox!.get('home');
      print("HOME LOCATION");
      print(homeLocation);
      if (homeLocation != null) {
        print("INSIDE IF");
        setState(() {
          _homeLocation = homeLocation;
          _home = Marker(
            markerId: const MarkerId('home'),
            position: _homeLocation,
            infoWindow: const InfoWindow(title: 'Home'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
        });
      }
    }
  }

  Future<void> fetchFestivalLocationFromCache() async {
    if (_festivalLocationBox != null && _festivalLocationBox!.isOpen) {
      final festivalLocation = _festivalLocationBox!.get('festival');
      if (festivalLocation != null) {
        setState(() {
          _festivalLocation = festivalLocation;
          _festival = Marker(
            markerId: const MarkerId('festival'),
            position: _festivalLocation,
            infoWindow: const InfoWindow(title: 'Festival'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          );
        });
      }
    }
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
    _homeLocation = LatLng(_locationData!.latitude!, _locationData!.longitude!);
    
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

  Future<List<String>> _retrieveBuddies() async {
    final response = await http.get(
        Uri.parse('http://192.168.43.168:8000/user/2/buddies?content=username'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print("Data: ");
      print(jsonDecode(response.body));
      return data.map((dynamic buddy) => buddy.toString()).toList();
    } else {
      throw Exception('Failed to load buddies');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              zoomControlsEnabled: false,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (controller) => _googleMapController = controller,
              markers: {
                _home,
                _festival,
                if (_showBuddyMaker) _buddy,
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for a buddy',
                border: InputBorder.none,
                suffixIcon: _isListViewOpen
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _isListViewOpen = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _isListViewOpen = true;
                  _filteredBuddies =
                      _buddies.where((item) => item.contains(value)).toList();
                });
              },
              onTap: () => setState(() {
                _isListViewOpen = true;
              }),
            ),
          ),
          if (_isListViewOpen)
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: _filteredBuddies.map((buddy) {
                return ListTile(
                  title: Text(buddy),
                  onTap: () {
                    setState(() {
                      _isListViewOpen = false;
                    });
                    _retrieveLocationAPI("user/$buddy").then((value) {
                      setState(() {
                        _buddy = Marker(
                          markerId: const MarkerId('buddy'),
                          position: value,
                          infoWindow: const InfoWindow(title: 'Buddy'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue),
                        );
                        _googleMapController?.animateCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                            target: value,
                            zoom: 10,
                          )),
                        );
                        _buddyLocation = value;
                        _showBuddyMaker = true;
                      });
                    });
                  },
                );
              }).toList(),
            ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
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
                          zoom: 10,
                        )),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.group),
                  onPressed: () {
                    // fetch buddy location from database
                    if (_buddyLocation != null) {
                      _googleMapController?.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                          target: _buddyLocation,
                          zoom: 10,
                        )),
                      );
                    }
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
                          zoom: 10,
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
