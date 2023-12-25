import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({Key? key}) : super(key: key);

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  late GoogleMapController _googleMapController;
  late Location location = Location();
    LocationData? userLocation ; 
  late Marker _userMarker;
  late Polyline _polyline;
  List<LatLng> _polylineCoordinates = [];
  bool _isLocationEnabled = true;

 
  Future<void> userCurrentLocation() async {
    LocationData locationData = await location.getLocation();
     setState(() {
    userLocation = locationData;
  });
    
  }
  Future<void> _updateUserLocation() async {
    location.onLocationChanged.listen((LocationData currentLocation) {
      _updateMarker(currentLocation);
      _updatePolyline(currentLocation);
    });
  }

  void _updateMarker(LocationData locationData) {
    setState(() {
      _userMarker = _userMarker.copyWith(
        positionParam: LatLng(locationData.latitude!, locationData.longitude!),
        infoWindowParam: InfoWindow(
          title: 'My Current Window',
          snippet: '${locationData.latitude}  ${locationData.longitude} '
        ),
      );
    });
  }

  void _updatePolyline(LocationData locationData) {
    setState(() {
      _polylineCoordinates.add(
        LatLng(locationData.latitude!, locationData.longitude!),
      );
      _polyline = _polyline.copyWith(pointsParam: _polylineCoordinates);
    });
  }

  Future<void> _getCurrentUserLocation() async {
    LocationData locationData = await location.getLocation();
    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locationData.latitude!, locationData.longitude!),
          zoom: 17,
        ),
      ),
    );
    _updateMarker(locationData);
  }

  
     @override
  void initState() {
    super.initState();
    _userMarker = Marker(markerId: const MarkerId('userLocation'));
    _polyline = const Polyline(
      polylineId: PolylineId('trackingPath'),
      width: 5,
      color: Colors.blue,
    );
    _updateUserLocation();
    userCurrentLocation;
  
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Real Time Location Tracker'),
          backgroundColor: Colors.blue,
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
  target: LatLng(
    userLocation?.latitude ?? 24.89889936296536,
    userLocation?.longitude ?? 91.90223269164562,
  ),
  zoom: 15,
),
 

          onMapCreated: (GoogleMapController controller) {
            _googleMapController = controller;
            _getCurrentUserLocation();
            Timer.periodic(const Duration(seconds:  10), (Timer t) {
              if (_isLocationEnabled) {
                _getCurrentUserLocation();
              } else {
                t.cancel();
              }
            });
          },
          markers: { _userMarker },
          polylines: { _polyline },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onTap: (LatLng latLng) {
            setState(() {
              _isLocationEnabled = false;
            });
          },
          onLongPress: (LatLng position) {
            setState(() {
              _isLocationEnabled = true;
            });
          },
        ),
      ),
    );
  }
}
