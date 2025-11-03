import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gps_provider.dart';
// ...existing code...

class GpsProviderWrapper extends StatelessWidget {
  final Widget child;
  const GpsProviderWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => GpsProvider(), child: child);
  }
}
