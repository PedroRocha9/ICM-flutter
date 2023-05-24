import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindBuddyPage extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<FindBuddyPage> {
  static const _cameraPosition = CameraPosition(
    target: LatLng(40.6244776, -8.6490592),
    zoom: 11.5,
  );

  GoogleMapController? _googleMapController;

  final Marker _home = Marker(
    markerId: const MarkerId('home'),
    position: const LatLng(40.6244776, -8.6490592),
    infoWindow: const InfoWindow(title: 'Home'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        zoomControlsEnabled: false,
        initialCameraPosition: _cameraPosition,
        onMapCreated: (controller) => _googleMapController = controller,
        markers: {
          _home,
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController?.animateCamera(
          CameraUpdate.newCameraPosition(_cameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
