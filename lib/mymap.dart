import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_doguber_frontend/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationInfo extends ChangeNotifier {
  LatLng? targetLocation;
  LatLng? myLocation;
  Set<Marker> markers = {};

  //service available and permission check
  Future<bool> _checkLocationServiceCanUse() async {
    //기기에서 위치 서비스가 활성화되어있는지 검사
    bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (locationServiceEnabled == false) {
      debugPrint('[log] location service on the device is disabled.');
      return false;
    }

    //사용 권한 검사
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      debugPrint('[log] location permission on this app permanently denied');
      return false;
    } else if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('[log] location permission denied');
        return false;
      }
      return true;
    }
  }

  // location function
  Future<void> setMyLocation() async {
    //geolocator의 실행 조건을 모두 검사
    bool locationService = await _checkLocationServiceCanUse();
    if (locationService == false) return;

    Position location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    myLocation = LatLng(location.latitude, location.longitude);
    notifyListeners();
  }

  void setTargetLocation(LatLng location) {
    targetLocation = location;
    notifyListeners();
  }

  //marker function
  void clearMarkers() {
    markers.clear();
    notifyListeners();
  }

  void _setMarker(LatLng location) {
    Marker marker = Marker(
      markerId: MarkerId(DateTime.now().toString()),
      position: location,
      icon: BitmapDescriptor.defaultMarker,
    );
    markers.add(marker);
    debugPrint('[log] marked at $location');
    notifyListeners();
  }

  Future<void> setMarkersAtMyLocation() async {
    await setMyLocation();
    _setMarker(myLocation!);
    notifyListeners();
  }

  void setOnlySingleMarker(LatLng location) {
    markers.clear();
    Marker marker = Marker(
      markerId: MarkerId(DateTime.now().toString()),
      position: location,
      icon: BitmapDescriptor.defaultMarker,
    );
    markers.add(marker);
    debugPrint('[log] marked only one at $location');
    notifyListeners();
  }

  //address function
  Future<String?> getPlaceAddress(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${ApiKeys.googleApiKey}&language=ko';
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      debugPrint('!!! get place address err');
      return null;
    }

    return jsonDecode(response.body)['results'][0]['formatted_address'];

    // return jsonDecode(response.body)['results'][0]['address_components'][1]
    //     ['long_name'];
  }
}

// class MyMap {
//   //marker id : 등록된 시간

//   //singleton
//   MyMap._privateConstructor();
//   static final MyMap _instance = MyMap._privateConstructor();
//   factory MyMap() => _instance;

//   final String _googleMapApiKey = 'AIzaSyBTk9blgdCa4T8fARQha7o-AuF8WkK3byI';
//   GoogleMapController? _mapController;
//   final Set<Marker> _markers = {};
//   LatLng? _myLocation;
//   LatLng? _targetLocation;

//   //getter
//   GoogleMapController? get mapController => _mapController;
//   LatLng? get myLocation => _myLocation;
//   LatLng? get targetLocation => _targetLocation;
//   Set<Marker> get markers => _markers;

//   ///////////////////////////////setup function/////////////////////////////////
//   void setMapController({required GoogleMapController ctrl}) {
//     _mapController = ctrl;
//   }

//   Future<bool> initialize() async {
//     _markers.clear();
//     await markingMyLocation();
//     return true;
//   }

//   Future<bool> checkLocationCanBeUsed() async {
//     //기기에서 위치 서비스가 활성화되어있는지 검사
//     bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (locationServiceEnabled == false) {
//       debugPrint('[log] location service on the device is disabled.');
//       return false;
//     }

//     //사용 권한 검사
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.deniedForever) {
//       debugPrint('[log] location permission on this app permanently denied');
//       return false;
//     } else if (permission == LocationPermission.always ||
//         permission == LocationPermission.whileInUse) {
//       return true;
//     } else {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         debugPrint('[log] location permission denied');
//         return false;
//       }
//       return true;
//     }
//   }

//   /////////////////////////my location function/////////////////////////////////
//   Future<void> getMyLocation() async {
//     //geolocator의 실행 조건을 모두 검사
//     bool locationService = await checkLocationCanBeUsed();
//     if (locationService == false) return;

//     Position location = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     _myLocation = LatLng(location.latitude, location.longitude);
//   }

//   Future<void> markingMyLocation() async {
//     await getMyLocation();
//     if (_myLocation == null) return;

//     Marker marker = Marker(
//       markerId: MarkerId(DateTime.now().toString()),
//       position: _myLocation!,
//       icon: BitmapDescriptor.defaultMarker,
//     );
//     _markers.add(marker);
//     debugPrint('[log] marking my location $_myLocation');
//   }

//   //////////////////////////////map function////////////////////////////////////
//   void marking(double lat, double lng, {String? image}) {
//     Marker marker = Marker(
//       markerId: MarkerId(DateTime.now().toString()),
//       position: LatLng(lat, lng),
//       icon: BitmapDescriptor.defaultMarker,
//     );
//     _markers.add(marker);
//     debugPrint('[log] marked at $lat, $lng');
//   }

//   // Future<dynamic> _getPlaceAddress(double lat, double lng) async {
//   //   final url =
//   //       'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_googleMapApiKey&language=ko';
//   //   http.Response response = await http.get(Uri.parse(url));

//   //   return jsonDecode(response.body)['results'][0]['address_components'][1]
//   //       ['long_name'];
//   // }

//   // Future<void> getMyAddress() async {
//   //   _myAddress = await _getPlaceAddress(
//   //     _myLocation!.latitude,
//   //     _myLocation!.longitude,
//   //   );
//   // }
// }
