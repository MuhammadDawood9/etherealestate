import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_routes.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/fade_scale_route.dart';
import '../../shared/user_avatar.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/app_menu_sheet.dart';
import '../../shared/widgets/gradient_sphere.dart';
import '../../shared/widgets/shimmer_box.dart';
import '../property/property_details_screen.dart';

// 1. Changed to ConsumerWidget
class MyCollectionScreen extends ConsumerWidget {
  const MyCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Watch the global saved properties state
    final savedAsync = ref.watch(savedPropertiesProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildMeshGradient(),
          SafeArea(
            bottom: false,
            // 3. Handle loading, error, and data states reactively
            child: savedAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4C54B6))),
              error: (error, _) => Center(child: Text('Could not load collection: $error')),
              data: (saved) => RefreshIndicator(
                onRefresh: () async {
                  // Refreshes the Riverpod state directly from the DB
                  ref.invalidate(savedPropertiesProvider);
                },
                color: const Color(0xFF4C54B6),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 48),
                      _buildTitleSection(saved.length),
                      const SizedBox(height: 40),
                      if (saved.isEmpty)
                        _buildEmptyState()
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 24,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: saved.length,
                          itemBuilder: (context, index) => _buildCollectionCard(context, ref, saved[index]),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Tooltip(
          message: 'Menu',
          child: GestureDetector(
            onTap: () => showAppMenu(context),
            child: const Icon(Icons.menu, color: Colors.black),
          ),
        ),
        Text(
          'Ethereal Estate',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.profile),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: userAvatarImage(),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(int savedCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEMBER COLLECTION',
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            color: const Color(0xFF4C54B6),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Collection',
              style: GoogleFonts.manrope(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1.5),
            ),
            Text(
              '$savedCount saved',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black45),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4C54B6).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border, color: Color(0xFF4C54B6), size: 40),
            ),
            const SizedBox(height: 24),
            Text('No saved properties yet',
                style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tap the heart icon on any listing to save it here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black45)),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, WidgetRef ref, PropertyModel item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        FadeScaleRoute(page: PropertyDetailsScreen(propertyId: item.id)),
      ), // No longer need .then() to reload, Riverpod handles it automatically!
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 20))],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: 800,
                        placeholder: (context, url) => const ShimmerBox(),
                        errorWidget: (context, url, err) => Container(
                          color: const Color(0xFFF3F4F5),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.black12,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          // 4. Update the DB through Riverpod instead of direct DB calls
                          onTap: () => ref.read(savedPropertiesProvider.notifier).toggleSave(item),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                            child: const Icon(Icons.favorite, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(100)),
                              child: Text(item.price, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(item.location, style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFeature(Icons.king_bed_outlined, item.beds),
                      _buildFeature(Icons.bathtub_outlined, item.baths),
                      _buildFeature(Icons.straighten, '${item.sqft} sqft'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4C54B6)),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: RepaintBoundary(child: GradientSphere(color: const Color(0xFFF3F4F5)))),
        Positioned(top: 0, right: 0, child: RepaintBoundary(child: GradientSphere(color: const Color(0xFFE0E0FF).withValues(alpha: 0.5)))),
        Positioned(bottom: 0, right: 0, child: RepaintBoundary(child: GradientSphere(color: const Color(0xFFF8F9FA)))),
        Positioned(bottom: 0, left: 0, child: RepaintBoundary(child: GradientSphere(color: const Color(0xFFDEE2ED)))),
      ],
    );
  }
}