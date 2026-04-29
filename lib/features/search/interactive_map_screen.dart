import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../property/property_details_screen.dart';

class InteractiveMapScreen extends ConsumerStatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  ConsumerState<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends ConsumerState<InteractiveMapScreen> {
  final MapController _mapController = MapController();
  int _selectedPin = 0;
  
  static const String _geoapifyKey = 'a608c97c6f0b41418ae0a7dcfb964c78';
  static const String _tileUrl = 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png';

  static final LatLng _lahoreCenter = const LatLng(31.5497, 74.3436);

  final List<_MapPinData> _pins = [
    _MapPinData(position: const LatLng(33.5651, 73.0169), title: 'DHA Defence', subtitle: 'Lahore'),
    _MapPinData(position: const LatLng(33.5090, 73.3310), title: 'Bahria Town', subtitle: 'Lahore'),
    _MapPinData(position: const LatLng(31.4697, 74.2725), title: 'Gulberg', subtitle: 'Lahore'),
    _MapPinData(position: const LatLng(31.4320, 74.3910), title: 'Johar Town', subtitle: 'Lahore'),
    _MapPinData(position: const LatLng(31.4504, 74.3100), title: 'Cantt', subtitle: 'Lahore'),
  ];

  void _onMarkerTapped(int index) {
    setState(() => _selectedPin = index);
    _mapController.move(_pins[index].position, 13);
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(featuredPropertiesProvider);
    
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _lahoreCenter,
              initialZoom: 10.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: '$_tileUrl?apiKey=$_geoapifyKey',
                userAgentPackageName: 'com.etherealestate.app',
              ),
              MarkerLayer(
                markers: _pins.asMap().entries.map((entry) {
                  final index = entry.key;
                  final pin = entry.value;
                  return Marker(
                    point: pin.position,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _onMarkerTapped(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: index == _selectedPin ? const Color(0xFF4C54B6) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF4C54B6), width: 2),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Icon(
                          Icons.home,
                          size: 18,
                          color: index == _selectedPin ? Colors.white : const Color(0xFF4C54B6),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildTopBar(context),
          ),
          Positioned(
            right: 24, bottom: 100,
            child: Column(
              children: [
                _buildFAB(Icons.my_location, () {
                  _mapController.move(_lahoreCenter, 10.5);
                }),
                const SizedBox(height: 16),
                _buildFAB(Icons.search, () {}),
              ],
            ),
          ),
          propertiesAsync.when(
            data: (properties) => _buildPropertyPreview(context, properties),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 24, right: 24, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, Colors.white.withValues(alpha: 0)]),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)]),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)]),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Color(0xFF4C54B6)),
                const SizedBox(width: 4),
                Text('Lahore, Pakistan', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)]),
        child: Icon(icon, size: 20, color: const Color(0xFF4C54B6)),
      ),
    );
  }

  Widget _buildPropertyPreview(BuildContext context, List<PropertyModel> properties) {
    if (properties.isEmpty) return const SizedBox.shrink();
    final p = properties[_selectedPin % properties.length];
    return Positioned(
      right: 24,
      bottom: 100,
      left: 24,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(propertyId: p.id))),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: p.imageUrl,
                  width: 80, height: 80, fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.title, style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(p.location, style: GoogleFonts.inter(fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(p.price, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 16, color: const Color(0xFF4C54B6))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPinData {
  final LatLng position;
  final String title;
  final String subtitle;
  const _MapPinData({required this.position, required this.title, required this.subtitle});
}