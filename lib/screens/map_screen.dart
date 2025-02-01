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
    LatLng(44.9747, -93.2354),
    LatLng(44.9828, -93.2390),
    LatLng(44.9670, -93.2370),
  ];

  @override
  void initState() {
    super.initState();
    var a = _getMarkerList();
    _addMarkers(a);
  }

  List<LatLng> _getMarkerList() {
    return markerCoordinats;
  }

  void _addMarkers(List<LatLng> marker_lis) {
    for (var i = 0; i < marker_lis.length; i++) {
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
      target: LatLng(44.9747, -93.2354),
      zoom: 12.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: GoogleMap(
        initialCameraPosition: start_Position,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {},
        markers: _markers,
      ),
    );
  }
}
