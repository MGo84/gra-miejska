import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GameMapScreen extends StatefulWidget {
  const GameMapScreen({super.key});

  @override
  State<GameMapScreen> createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen> {
  final List<Map<String, dynamic>> gamePoints = [
    {
      'name': 'Plac Grunwaldzki',
      'position': LatLng(53.4295, 14.5528),
      'description': 'Tu zaczyna się Twoja przygoda!'
    },
    {
      'name': 'Zamek Książąt Pomorskich',
      'position': LatLng(53.4281, 14.5556),
      'description': 'Tutaj czeka pierwszy trop.'
    },
    {
      'name': 'Wały Chrobrego',
      'position': LatLng(53.4305, 14.5632),
      'description': 'Piękny widok i zagadka do rozwiązania.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final mapController = MapController();

    return Scaffold(
      appBar: AppBar(title: Text('map.title'.tr())),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(53.4295, 14.5528),
          initialZoom: 14.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.gra_miejska',
          ),
          MarkerLayer(
            markers: gamePoints
                .map(
                  (point) => Marker(
                    point: point['position'],
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showMarkerDialog(context, point),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _showMarkerDialog(BuildContext context, Map<String, dynamic> point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(point['name']),
        content: Text(point['description']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('map.close'.tr()),
          ),
        ],
      ),
    );
  }
}
