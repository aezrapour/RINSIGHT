import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rinsight_companion_app/Navigation/directions_repository.dart';
import 'directions_model.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});
  @override
  State<NavScreen> createState() =>_NavScreenState();
}

class _NavScreenState extends State<NavScreen> {

  //Getting Current Location/Permissions from Phone
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled(); //Check to see if location is enabled on device or not
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Access to Location is denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Access to Location is permanently denied; R-INSIGHT cannot request for permission');
    }
    return await Geolocator.getCurrentPosition();
  }

  //Constant User Location
  void _liveLocation() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
    _lat = double.parse(lat);
    _long = double.parse(long);
    pos = LatLng(_lat,_long);
    _cameraPosition = CameraPosition(
      target: LatLng(_lat,_long),
      zoom: 13,
    );
    setState(() {
    _origin = Marker(
      markerId: const MarkerId('origin'),
      infoWindow: const InfoWindow(title: 'Origin'),
      icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: pos,
    );
    });
    _googleMapController.animateCamera(
    CameraUpdate.newCameraPosition(_cameraPosition),
    );
    // Get directions for change in user's location
    final directions = await DirectionsRepository()
        .getDirections(origin: _origin.position, destination: _destination.position);
    setState(() => _info = directions);
  }

  //Initializing to avoid late Null Errors
  late String lat = '40.0583'; //Starting Camera in NJ
  late String long = '-74.4057';
  late var _lat = double.parse(lat);
  late var _long = double.parse(long);
  late CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(_lat,_long),
    zoom: 13,
  );
  late GoogleMapController _googleMapController;
  late LatLng pos = LatLng(_lat,_long);
  late Marker _origin = Marker(
      markerId: const MarkerId('originplaceholder'),
      infoWindow: const InfoWindow(title: 'Origin'),
      icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: pos,
      );
  late Marker _destination = Marker(
      markerId: const MarkerId('destinationplaceholder'),
      infoWindow: const InfoWindow(title: 'Destination'),
      icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: pos,
      );
  late LatLngBounds bounds = LatLngBounds(southwest: LatLng(_lat,_long), northeast: LatLng(_lat,_long));
  late List<PointLatLng> polylinePoints = [PointLatLng(_lat,_long), PointLatLng(_lat,_long)];
  late String totalDistance = '0';
  late String totalDuration = '0';
  late Directions _info = Directions(
      bounds: bounds,
      polylinePoints: polylinePoints,
      totalDistance: totalDistance,
      totalDuration: totalDuration,
  );

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Google Maps'),
          actions: <Widget>[
            // Button to hover over position of the origin marker
            if (_origin != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origin.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('Origin'),
            ),
            // Button to hover over position of the destination marker
            if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _destination.position,
                        zoom: 14.5,
                        tilt: 50.0,
                      ),
                  ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('Dest.'),
            ),
          // Button to update user's current location on map via marker/camera
          IconButton(
            icon: const Icon(Icons.navigation),
            tooltip: 'Get Current Location',
            onPressed: () {
              _getCurrentLocation();
              _liveLocation();
            },
          ),
        ]
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _cameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              if (_origin != null) _origin,
              if (_destination != null) _destination,
            },
            // Generate line between origin and destination marker
            polylines: {
              Polyline(
                polylineId: const PolylineId('overview_polyline'),
                color: Colors.red,
                width: 5,
                points: _info.polylinePoints
                  .map((e) => LatLng(e.latitude, e.longitude))
                  .toList(),
              )
            },
            onLongPress: _addMarker,
          ),
          // Indicator of distance and estimated time left to destination
          Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0,2),
                          blurRadius: 6.0
                      )
                    ]
                ),
                child: Text(
                  '${_info.totalDistance}, ${_info.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      // Button displays route between origin and destination point
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
              CameraUpdate.newLatLngBounds(_info.bounds, 100),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),

    );
  }
  // Allow user to place destination marker on the map
  void _addMarker(LatLng pos) async {
    setState(() {
      _destination = Marker(
        markerId: const MarkerId('destinationplaceholder'),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: pos,
      );
    });

    // Get directions for change in user's destination
    final directions = await DirectionsRepository()
      .getDirections(origin: _origin.position, destination: pos);
    setState(() => _info = directions);
  }
}




