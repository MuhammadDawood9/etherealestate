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

// Real Lahore coordinates for each property in the fallback dataset.
// When live API properties load, ones not in this map simply won't have a pin.
const _propertyCoords = <String, LatLng>{
  'lhr-001': LatLng(31.4439, 74.4295), // DHA Phase 6
  'lhr-002': LatLng(31.5067, 74.3333), // Gulberg III
  'lhr-003': LatLng(31.3553, 74.1934), // Bahria Town (far SW)
  'lhr-004': LatLng(31.4858, 74.3266), // Model Town
  'lhr-005': LatLng(31.4697, 74.2725), // Johar Town
  'lhr-006': LatLng(31.5050, 74.3520), // Canal Road
  'lhr-007': LatLng(31.3620, 74.1950), // Askari 11
  'lhr-008': LatLng(31.5030, 74.3420), // Garden Town
  'lhr-009': LatLng(31.4588, 74.2810), // Wapda Town
  'lhr-010': LatLng(31.4000, 74.3900), // Valencia Town
};

class InteractiveMapScreen extends ConsumerStatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  ConsumerState<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends ConsumerState<InteractiveMapScreen> {
  final MapController _mapController = MapController();
  PropertyModel? _selectedProperty;

  static const String _geoapifyKey = 'a608c97c6f0b41418ae0a7dcfb964c78';
  static const String _tileUrl = 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png';
  static const LatLng _lahoreCenter = LatLng(31.4700, 74.3200);

  void _onMarkerTapped(PropertyModel property) {
    final pos = _propertyCoords[property.id];
    setState(() => _selectedProperty = property);
    if (pos != null) _mapController.move(pos, 13.5);
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(featuredPropertiesProvider);

    return Scaffold(
      extendBody: true,
      body: propertiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Text('Could not load map data', style: GoogleFonts.inter()),
        ),
        data: (properties) {
          // Auto-select first mappable property on first load
          if (_selectedProperty == null) {
            final first = properties.firstWhere(
              (p) => _propertyCoords.containsKey(p.id),
              orElse: () => properties.first,
            );
            _selectedProperty = first;
          }

          final mappableProps = properties
              .where((p) => _propertyCoords.containsKey(p.id))
              .toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _lahoreCenter,
                  initialZoom: 10.5,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: '$_tileUrl?apiKey=$_geoapifyKey',
                    userAgentPackageName: 'com.etherealestate.app',
                  ),
                  MarkerLayer(
                    markers: mappableProps.map((property) {
                      final pos = _propertyCoords[property.id]!;
                      final isSelected = _selectedProperty?.id == property.id;
                      return Marker(
                        point: pos,
                        width: isSelected ? 52 : 42,
                        height: isSelected ? 52 : 42,
                        child: GestureDetector(
                          onTap: () => _onMarkerTapped(property),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4C54B6)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF4C54B6),
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(0xFF4C54B6).withValues(alpha: 0.4)
                                      : Colors.black.withValues(alpha: 0.15),
                                  blurRadius: isSelected ? 12 : 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.home_rounded,
                              size: isSelected ? 24 : 18,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF4C54B6),
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
                child: _buildTopBar(context, mappableProps.length),
              ),
              Positioned(
                right: 24,
                bottom: _selectedProperty != null ? 220 : 100,
                child: Column(
                  children: [
                    _buildFAB(Icons.my_location, () {
                      _mapController.move(_lahoreCenter, 10.5);
                    }),
                    const SizedBox(height: 16),
                    _buildFAB(Icons.add, () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    }),
                    const SizedBox(height: 8),
                    _buildFAB(Icons.remove, () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    }),
                  ],
                ),
              ),
              if (_selectedProperty != null)
                _buildPropertyPreview(context, _selectedProperty!),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildTopBar(BuildContext context, int count) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 24,
        right: 24,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white.withValues(alpha: 0)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                ],
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Color(0xFF4C54B6)),
                const SizedBox(width: 4),
                Text('Lahore, Pakistan', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Container(width: 1, height: 12, color: Colors.black12),
                const SizedBox(width: 8),
                Text(
                  '$count pins',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4C54B6),
                  ),
                ),
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
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF4C54B6)),
      ),
    );
  }

  Widget _buildPropertyPreview(BuildContext context, PropertyModel p) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 100,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PropertyDetailsScreen(propertyId: p.id)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: p.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.title,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: Colors.black45),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                p.location,
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.black54),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.price,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: const Color(0xFF4C54B6),
                              ),
                            ),
                            Row(
                              children: [
                                _buildMiniStat(Icons.king_bed_outlined, p.beds),
                                const SizedBox(width: 10),
                                _buildMiniStat(Icons.bathtub_outlined, p.baths),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Color(0xFF4C54B6)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.black45),
        const SizedBox(width: 3),
        Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }
}
