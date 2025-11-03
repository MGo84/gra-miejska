import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/gps_provider.dart';
import '../widgets/game_menu_bar.dart';
import '../../core/widgets/game_status_bar_placeholder.dart';
import '../providers/game_progress_provider.dart';
import '../models/game_progress.dart';

class GameMapScreen extends StatefulWidget {
  final String? returnRoute;
  final String? faction; // 'ludzie' or 'ciemnosc'
  const GameMapScreen({super.key, this.returnRoute, this.faction});

  @override
  State<GameMapScreen> createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen> {
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> gamePoints = [
    {
      'name': 'Zamek Książąt Pomorskich',
      'position': LatLng(53.4281, 14.5556),
      'description': 'Tutaj czeka pierwszy trop. Misja A1 startuje tutaj.',
    },
  ];

  bool _mapMoved = false;
  // bool _movedToGps = false; // unused, reserved for future behavior

  @override
  void initState() {
    super.initState();
    // Save that we're now on the map screen so "powrót do przygody" can
    // return here with the same arguments (for example the selected faction).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final provider = context.read<GameProgressProvider>();
        final existing = provider.progress;
        final progress = GameProgress(
          currentScreen: '/map',
          currentArgs: widget.faction != null
              ? {'faction': widget.faction}
              : null,
          solvedPoints: existing?.solvedPoints ?? [],
          inventory: existing?.inventory ?? [],
          username: existing?.username,
        );
        provider.save(progress);
      } catch (_) {
        // If provider isn't available for some reason, don't crash.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gps = context.watch<GpsProvider>();
    final LatLng? gpsPosition = gps.position;
    final bool locationError = gps.locationError;
    // Center the map on the castle marker so the single mission marker is
    // visible by default.
    final LatLng initialCenter = LatLng(53.4281, 14.5556);

    final faction = widget.faction;

    Widget bodyContent;
    if (locationError) {
      bodyContent = Column(
        children: [
          if (faction != null)
            Container(
              width: double.infinity,
              color: Colors.deepPurple,
              padding: const EdgeInsets.all(8),
              child: Text(
                'Wybrano: ${faction == 'ludzie' ? 'Ludzie' : 'Siły ciemności'}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          const Expanded(
            child: Center(
              child: Text(
                'Brak dostępu do lokalizacji',
                style: TextStyle(color: Colors.red, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    } else {
      bodyContent = Column(
        children: [
          if (faction != null)
            Container(
              width: double.infinity,
              color: Colors.deepPurple,
              padding: const EdgeInsets.all(8),
              child: Text(
                'Wybrano: ${faction == 'ludzie' ? 'Ludzie' : 'Siły ciemności'}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

          // Missions are started from markers on the map. The mission card was
          // intentionally removed so players must tap a relevant marker (e.g.
          // the castle) to view mission details and start the mission.
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 14.5,
                onPositionChanged: (pos, hasGesture) {
                  if (hasGesture && !_mapMoved) {
                    setState(() {
                      _mapMoved = true;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.gra_miejska',
                ),
                MarkerLayer(
                  markers: [
                    ...gamePoints.map(
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
                    ),
                    if (gpsPosition != null)
                      Marker(
                        point: gpsPosition,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 36,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: GameStatusBarPlaceholder(),
      ),
      body: bodyContent,
      bottomNavigationBar: GameMenuBar(
        onMenuTap: (id) {
          if (id == 'map') return;
          if (id == 'home') Navigator.pushReplacementNamed(context, '/home');
          if (id == 'ekwipunek') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ekwipunek - wkrótce!')),
            );
          }
          if (id == 'powrot') {
            final provider = context.read<GameProgressProvider>();
            final route = provider.progress?.currentScreen ?? '/intro';
            final args = provider.progress?.currentArgs;
            Navigator.pushNamed(context, route, arguments: args);
          }
        },
        active: 'map',
      ),
    );
  }

  void _showMarkerDialog(BuildContext context, Map<String, dynamic> point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(point['name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(point['description']),
              const SizedBox(height: 12),
              // If this marker is the castle, show the mission A1 preview
              if (point['name'] == 'Zamek Książąt Pomorskich') ...[
                Text(
                  'missions.a1.title'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('a1_tekst1'.tr()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('map.close'.tr()),
          ),
          if (point['name'] == 'Zamek Książąt Pomorskich')
            ElevatedButton.icon(
              onPressed: () {
                // Start mission A1 directly from this marker
                Navigator.pop(context);
                Navigator.pushReplacementNamed(
                  context,
                  '/mission',
                  arguments: {'id': 'a1'},
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: Text('missions_ui.start'.tr().toUpperCase()),
            )
          else
            ElevatedButton(
              onPressed: () {
                // Default behavior: start generic game flow (intro)
                Navigator.pop(context);
                final provider = context.read<GameProgressProvider>();
                final progress = GameProgress(
                  currentScreen: '/intro',
                  solvedPoints: provider.progress?.solvedPoints ?? [],
                  inventory: provider.progress?.inventory ?? [],
                  username: provider.progress?.username,
                );
                provider.save(progress).then((_) {
                  Navigator.pushReplacementNamed(context, '/intro');
                }); // lub inna trasa gry
              },
              child: Text('games.start'.tr().toUpperCase()),
            ),
        ],
      ),
    );
  }
}
