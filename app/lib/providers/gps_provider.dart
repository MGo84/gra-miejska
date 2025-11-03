import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GpsProvider extends ChangeNotifier {
  LatLng? _position;
  bool _locationError = false;
  StreamSubscription<Position>? _sub;

  LatLng? get position => _position;
  bool get locationError => _locationError;

  GpsProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _locationError = true;
        notifyListeners();
        return;
      }
      _sub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          ).listen((pos) {
            _position = LatLng(pos.latitude, pos.longitude);
            notifyListeners();
          });
    } catch (e) {
      _locationError = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
