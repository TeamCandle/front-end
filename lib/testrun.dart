import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

String googleApiKey = 'AIzaSyBTk9blgdCa4T8fARQha7o-AuF8WkK3byI';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Position? _currentPosition;
  String? _currentAddress;
  final Set<Marker> _markers = {};

  Future<dynamic> getPlaceAddress(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey&language=ko';
    http.Response response = await http.get(Uri.parse(url));

    return jsonDecode(response.body)['results'][0]['address_components'][1]
        ['long_name'];
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled == false) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('location permission denied')));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    //권한을 얻고, 없다면 바로 종료시킴
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> getCurrentAddress() async {
    String address = await getPlaceAddress(
        _currentPosition!.latitude, _currentPosition!.longitude);
    setState(() {
      _currentAddress = address;
    });
  }

  void addMarker() {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('marker_1'),
        position: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps in Flutter')),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(37.7749, -122.4194),
            zoom: 12,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          markers: _markers,
        ),
        Container(
          width: double.infinity,
          color: Colors.white,
          child: Text(_currentAddress ?? '-'),
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'my location'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'track'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'marking'),
        ],
        onTap: (index) async {
          switch (index) {
            case 0:
              await getCurrentPosition();
              await getCurrentAddress();
              _mapController.animateCamera(CameraUpdate.newLatLng(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              ));
              break;
            case 1:
              break;
            case 2:
              addMarker();
              break;
          }
        },
      ),
    );
  }
}
