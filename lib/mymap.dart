import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MyMap {
  //marker id : 등록된 시간

  //singleton
  MyMap._privateConstructor();
  static final MyMap _instance = MyMap._privateConstructor();
  factory MyMap() => _instance;

  final String _googleMapApiKey = 'AIzaSyBTk9blgdCa4T8fARQha7o-AuF8WkK3byI';
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _myLocation;

  //getter
  GoogleMapController? get mapController => _mapController;
  LatLng? get myLocation => _myLocation;
  Set<Marker> get markers => _markers;

  //setup
  void setMapController({required GoogleMapController ctrl}) {
    _mapController = ctrl;
  }

  Future<bool> initMapOnRequestDetail() async {
    _markers.clear();
    await markingMyLocation();
    return true;
  }

  Future<void> markingMyLocation() async {
    await getMyLocation();
    if (_myLocation == null) return;

    Marker marker = Marker(
      markerId: MarkerId(DateTime.now().toString()),
      position: _myLocation!,
      icon: BitmapDescriptor.defaultMarker,
    );
    _markers.add(marker);
    debugPrint('[log] marking my location $_myLocation');
  }

  Future<void> getMyLocation() async {
    //geolocator의 실행 조건을 모두 검사
    bool locationService = await checkLocationCanBeUsed();
    if (locationService == false) return;

    Position location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _myLocation = LatLng(location.latitude, location.longitude);
  }

  Future<bool> checkLocationCanBeUsed() async {
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

  //function
  //TODO: String? image -> image의 bytedata로 변경
  //이미지가 있을 때 상대 처리하는것도 ㅇㅇ
  void marking(double lat, double lng, {String? image}) {
    Marker marker = Marker(
      markerId: MarkerId(DateTime.now().toString()),
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarker,
    );
    _markers.add(marker);
    debugPrint('[log] marked at $lat, $lng');
  }

  // Future<dynamic> _getPlaceAddress(double lat, double lng) async {
  //   final url =
  //       'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_googleMapApiKey&language=ko';
  //   http.Response response = await http.get(Uri.parse(url));

  //   return jsonDecode(response.body)['results'][0]['address_components'][1]
  //       ['long_name'];
  // }

  // Future<void> getMyAddress() async {
  //   _myAddress = await _getPlaceAddress(
  //     _myLocation!.latitude,
  //     _myLocation!.longitude,
  //   );
  // }
}
