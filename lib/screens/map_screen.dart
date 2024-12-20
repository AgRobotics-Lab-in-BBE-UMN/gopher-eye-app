import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const CameraPosition start_Position = CameraPosition(
      target: LatLng(44.9747, -93.2354), // any start coordinate
      zoom: 12.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: GoogleMap(
        initialCameraPosition: start_Position,
        mapType: MapType.normal, // Specify the map type, e.g. MapType.hybrid
        myLocationEnabled: true, // Enables user's current location on the map
        myLocationButtonEnabled: true, // Adds the location button on the map
        onMapCreated: (GoogleMapController controller) {
          // Optional: Configure controller for custom map features
        },
      ),
    );
  }
}
