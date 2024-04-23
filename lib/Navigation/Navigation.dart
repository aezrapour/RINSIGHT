import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'directions_repository.dart';
import 'directions_model.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});
  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  //Initializing values to avoid late initializing Errors
  late double lat = 40.521995; //Starting Camera in Rutgers SOE
  late double long = -74.4629228;
  late CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(lat, long),
    zoom: 13,
  );

  late GoogleMapController _googleMapController;
  late LatLng pos = LatLng(lat, long);
  late Marker _origin = Marker(
    markerId: const MarkerId('originplaceholder'),
    infoWindow: const InfoWindow(title: 'Origin'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    position: pos,
  );

  late Marker _destination = Marker(
    markerId: const MarkerId('destinationplaceholder'),
    infoWindow: const InfoWindow(title: 'Destination'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    position: pos,
  );

  late LatLngBounds bounds =
      LatLngBounds(southwest: LatLng(lat, long), northeast: LatLng(lat, long));
  late List<PointLatLng> polylinePoints = [
    PointLatLng(lat, long),
    PointLatLng(lat, long)
  ];
  late String totalDistance = '0';
  late String totalDuration = '0';
  late String instructions = '';
  late Directions _info = Directions(
    bounds: bounds,
    polylinePoints: polylinePoints,
    totalDistance: totalDistance,
    totalDuration: totalDuration,
    instructions: instructions,
  ); // Directions

  //Getting Current Location/Permissions from Phone
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator
        .isLocationServiceEnabled(); //Check to see if location is enabled on device or not
    LocationPermission permission = await Geolocator.checkPermission();
    if (!serviceEnabled) {
      return Future.error('Location access disabled');
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return await showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Location Permission"),
            content: const Text(
                "This app needs location access to function. Please enable it in app settings."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  openAppSettings(); // Directs the user to the app settings.
                },
                child: const Text("Open Settings"),
              ),
            ],
          ),
        );
      }
    }
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }
    if (serviceEnabled) {
      _liveLocation();
    }
    return await Geolocator.getCurrentPosition();
  }

  //Constant User Location
  void _liveLocation() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      lat = position.latitude;
      long = position.longitude;
      pos = LatLng(lat, long);

      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
      });

      _cameraPosition = CameraPosition(
        target: LatLng(lat, long),
        zoom: 13,
      );

      // Get directions for change in user's location
      final directions = await DirectionsRepository().getDirections(
          origin: _origin.position, destination: _destination.position);
      setState(() => _info = directions);
      print(_info.instructions);
    });
  }

  // Allow user to place destination marker on the map
  void _addMarker(LatLng pos) async {
    setState(() {
      _destination = Marker(
        markerId: const MarkerId('destinationplaceholder'),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: pos,
      );
    });

    // Get directions for change in user's destination
    final directions = await DirectionsRepository()
        .getDirections(origin: _origin.position, destination: pos);
    setState(() => _info = directions);
    print(_info.instructions);
  }

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

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
          title: const Text('Navigate'),
          actions: <Widget>[
            // Button to hover over position of the origin marker
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
                _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(_cameraPosition),
                );
              },
            ),
          ]),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _cameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              _origin,
              _destination,
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
                        offset: Offset(0, 2),
                        blurRadius: 6.0)
                  ]),
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          CameraUpdate.newLatLngBounds(_info.bounds, 100),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
