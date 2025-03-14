import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gopher_eye/services/photo_handler.dart';
import 'package:gopher_eye/services/location_controller.dart';
import 'package:get/get.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};
  final PhotoHandler _photoHandler = PhotoHandler();
  final LocationController locationController = Get.find<LocationController>();
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();

    _markers.add(
      Marker(
        markerId: const MarkerId("start_location"),
        position: const LatLng(44.9747, -93.2354),
        infoWindow: const InfoWindow(
          title: "Start Location",
          snippet: "Lat: 44.9747, Lng: -93.2354",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    // ever(locationController.latestCoords, (LatLng? newCoords) {
    //   if (newCoords != null && locationController.latestPhoto.value != null) {
    //     print("New coordinates received: $newCoords");
    //     _addMarker(newCoords.latitude, newCoords.longitude,
    //         locationController.latestPhoto.value!);
    //   }
    // });

    _addMarker(
        locationController.latestCoords.value!.latitude,
        locationController.latestCoords.value!.longitude,
        locationController.latestPhoto.value!);

    setState(() {});
  }

  void _addMarker(double latitude, double longitude, XFile photo) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(photo.path),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            snippet: "Lat: $latitude, Lng: $longitude",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const CameraPosition start_Position = CameraPosition(
      target: LatLng(44.9747, -93.2354),
      zoom: 12.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: GoogleMap(
        initialCameraPosition: start_Position,
        mapType: MapType.satellite,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {},
        markers: _markers,
      ),
    );
  }

  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }
}
