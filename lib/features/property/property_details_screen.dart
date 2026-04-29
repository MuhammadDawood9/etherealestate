import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Internal Project Imports
import '../../core/models/property_model.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/app_snack_bar.dart';
import '../../core/utils/fade_scale_route.dart';
import '../../shared/widgets/gradient_sphere.dart';
import '../../shared/widgets/shimmer_box.dart';
import '../booking/booking_calendar_screen.dart';
import 'floor_plan_screen.dart';

class PropertyDetailsScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends ConsumerState<PropertyDetailsScreen> {
  PropertyModel? _property;

  // --- Logic & Actions ---

  Future<void> _toggleFavorite() async {
    final prop = _property;
    if (prop == null) return;

    HapticFeedback.lightImpact();
    try {
      // Direct call to our global Riverpod controller
      await ref.read(savedPropertiesProvider.notifier).toggleSave(prop);
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context, 'Update failed. Please try again.', isError: true);
      }
    }
  }

  Future<void> _shareProperty() async {
    final prop = _property;
    final text = '${prop?.title}\n${prop?.location} · ${prop?.price}\nView on Ethereal Estate.';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) AppSnackBar.show(context, 'Details copied to clipboard.');
  }

  // --- Build & State Logic ---

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the global saved status for this specific ID
    final isSaved = ref.watch(isPropertySavedProvider(widget.propertyId));

    // 2. Performance: Try to find the property in the pre-loaded feed first
    final feedList = ref.watch(feedPropertiesProvider).valueOrNull ?? [];
    final featuredList = ref.watch(featuredPropertiesProvider).valueOrNull ?? [];

    for (final p in [...feedList, ...featuredList]) {
      if (p.id == widget.propertyId) {
        _property = p;
        return _buildScreen(context, p, isSaved);
      }
    }

    // 3. Fallback: If not found (Deep Link), fetch from the API via ID
    final asyncProperty = ref.watch(propertyByIdProvider(widget.propertyId));

    return asyncProperty.when(
      loading: () => _buildLoadingScreen(context),
      error: (error, _) => _buildNotFoundScreen(context),
      data: (p) {
        if (p != null) {
          _property = p;
          return _buildScreen(context, p, isSaved);
        }
        return _buildNotFoundScreen(context);
      },
    );
  }

  // --- Main UI Builders ---

  Widget _buildScreen(BuildContext context, PropertyModel property, bool isSaved) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildMeshGradient(),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(context, property),
                _buildContentSection(property),
              ],
            ),
          ),
          _buildFloatingBackButton(context),
          _buildFloatingActionRow(context, isSaved),
          _buildStickyFooter(context, property),
        ],
      ),
    );
  }

  // --- Component Sections ---

  Widget _buildHeroSection(BuildContext context, PropertyModel property) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth,
      height: screenWidth,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'property-image-${widget.propertyId}',
            child: CachedNetworkImage(
              imageUrl: property.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 800,
              placeholder: (context, url) => const ShimmerBox(),
              errorWidget: (context, url, err) => Container(
                color: Colors.black.withValues(alpha: 0.05),
                child: const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.black26),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    property.price,
                    style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(PropertyModel property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(property.title,
              style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w800, height: 1.1)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Color(0xFF4C54B6)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(property.location,
                    style: GoogleFonts.inter(fontSize: 18, color: Colors.black54)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeatureIcon(Icons.king_bed, property.beds, 'Bedrooms'),
              _buildFeatureIcon(Icons.bathtub, property.baths, 'Baths'),
              _buildFeatureIcon(Icons.straighten, property.sqft, 'Sqft'),
            ],
          ),
          const SizedBox(height: 48),
          Text('Architectural Narrative', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            'A masterpiece of light and shadow, this residence redefines luxury modernism. '
                'Designed with precision, it leverages a seamless connection between '
                'interior sanctuaries and the surrounding landscape.',
            style: GoogleFonts.inter(fontSize: 17, color: Colors.black54, height: 1.8),
          ),
          const SizedBox(height: 40),
          _buildAmenityGrid(),
          const SizedBox(height: 32),
          _buildFloorPlanAccess(),
        ],
      ),
    );
  }

  Widget _buildFloorPlanAccess() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FloorPlanScreen())),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF4C54B6).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF4C54B6).withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            const Icon(Icons.architecture, color: Color(0xFF4C54B6), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Floor Plan', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Interactive layout viewer', style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyFooter(BuildContext context, PropertyModel property) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ESTIMATED MONTHLY', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black45)),
                      Text(property.price.split(' ').last, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(context, FadeScaleRoute(page: BookingCalendarScreen(property: property))),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(32)),
                      child: Center(child: Text('BOOK SITE VISIT', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildFeatureIcon(IconData icon, String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4C54B6), size: 28),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFloatingActionRow(BuildContext context, bool isSaved) {
    final topPad = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPad + 16,
      right: 24,
      child: Row(
        children: [
          _buildFloatingButton(
            isSaved ? Icons.favorite : Icons.favorite_border,
            _toggleFavorite,
            iconColor: isSaved ? const Color(0xFFEF9A9A) : Colors.white,
          ),
          const SizedBox(width: 12),
          _buildFloatingButton(Icons.share_outlined, _shareProperty),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, VoidCallback onTap, {Color iconColor = Colors.white}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBackButton(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPad + 16,
      left: 24,
      child: _buildFloatingButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
    );
  }

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: GradientSphere(color: const Color(0xFFF8F9FA))),
        Positioned(top: 0, right: 0, child: GradientSphere(color: const Color(0xFFE0E0FF).withValues(alpha: 0.5))),
      ],
    );
  }

  Widget _buildAmenityGrid() {
    return Row(
      children: [
        Expanded(child: _buildSmallAmenity(Icons.wine_bar, 'Wine Cellar')),
        const SizedBox(width: 16),
        Expanded(child: _buildSmallAmenity(Icons.home_max, 'Neural Home')),
      ],
    );
  }

  Widget _buildSmallAmenity(IconData icon, String label) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF4C54B6).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF4C54B6).withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFF4C54B6)),
          Text(label, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // --- Loading & Error Screens ---

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(body: Center(child: ShimmerBox(width: MediaQuery.of(context).size.width, height: 400)));
  }

  Widget _buildNotFoundScreen(BuildContext context) {
    return Scaffold(body: Center(child: Text("Property not found", style: GoogleFonts.manrope(fontSize: 18))));
  }
}