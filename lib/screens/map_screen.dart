import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};

  final List<LatLng> markerCoordinats = [
    LatLng(44.9747, -93.2354), // random places
    LatLng(44.9828, -93.2390),
    LatLng(44.9670, -93.2370),
  ];
  // now we don't have a database, therefore, we define some of the markers coordinates over here into the set _markers which will be the storage for them

  //now we need to create a function to add pin's locations onto the map
  @override
  void initState() {
    // initState - special Flutter method for inserting new object
    super.initState(); // call the Flutter function <- show that we overrride it
    _addMarkers(); // add all pins automatically after loading the map on display
  }
  // let's creat this function _addMarkers();

  void _addMarkers() {
    // the loop - for or while - similar to c++
    for (var i = 0; i < markerCoordinats.length; i++) {
      // Immutability - неизменность final (cannot be changed after assigning it in a runtime)vs const (exact value that cannot be changed)
      final marker = Marker(
        markerId: MarkerId('marker_$i'),
        position: markerCoordinats[i],
        infoWindow: InfoWindow(
          title: 'Marker $i',
          snippet: 'This is marker number $i',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      setState(() {
        _markers.add(marker);
      });
    }
  }

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
        markers: _markers, // adding the set of markers
      ),
    );
  }
}
