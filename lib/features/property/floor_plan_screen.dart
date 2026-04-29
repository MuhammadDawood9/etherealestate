import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_routes.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/app_menu_sheet.dart';

class FloorPlanScreen extends StatefulWidget {
  const FloorPlanScreen({super.key});

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends State<FloorPlanScreen> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final s = _transformController.value.getMaxScaleOnAxis();
    if (s < 2.8) {
      _transformController.value =
          _transformController.value.clone()..scaleByDouble(1.4, 1.4, 1.0, 1.0);
    }
  }

  void _zoomOut() {
    final s = _transformController.value.getMaxScaleOnAxis();
    if (s > 0.6) {
      _transformController.value =
          _transformController.value.clone()..scaleByDouble(0.7, 0.7, 1.0, 1.0);
    }
  }

  void _resetView() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildMeshGradient(),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 48),
                  _buildTitleSection(),
                  const SizedBox(height: 40),
                  _buildFloorPlanViewer(),
                  const SizedBox(height: 48),
                  _buildDetailsGrid(),
                  const SizedBox(height: 32),
                  _buildAITip(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => showAppMenu(context),
          child: const Icon(Icons.menu, color: Colors.black),
        ),
        Row(
          children: [
            Text('Floor Plans',
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4C54B6))),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.profile),
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDFo1WFnbZD4K1MF4ehor6msI31tXASBVGhSlOCxxdLxKGhY2BEbFh4x4gqr5FE81si57tyj4xLuEYihVQHxfZa5kEau3jYYPlSNRuEOJ0UktxZ9K5Kr0wtIM1_rfceBLws2LlfohyAZhGAZPZN3-zxdSPTAzcVgDgUHtTxwElhKh_-YWA-Tw73tjoWA9iE4KpdM7J7YoV80zoYFxZcOpGKVRicdNtRREyGWT4foztVavz1WIHbhOKgs8KqYLcon8oJbdSb7n6RIzE'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LEVEL 42 EXCLUSIVE',
            style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: const Color(0xFF4C54B6))),
        const SizedBox(height: 12),
        Text('The Penthouse\nFloor Plan',
            style: GoogleFonts.manrope(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                height: 1.1)),
        const SizedBox(height: 32),
        Row(
          children: [
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('3D view coming soon.', style: GoogleFonts.inter()),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )),
              child: _buildActionBtn(Icons.view_in_ar, '3D VIEW', true),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('PDF export coming soon.', style: GoogleFonts.inter()),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )),
              child: _buildActionBtn(Icons.download_outlined, 'PDF EXPORT', false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn(
      IconData icon, String label, bool isPrimary) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isPrimary
            ? Colors.black
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? null
            : Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 18, color: isPrimary ? Colors.white : Colors.black),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isPrimary ? Colors.white : Colors.black,
                  letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildFloorPlanViewer() {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 40)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Stack(
            children: [
              // Interactive floor plan
              InteractiveViewer(
                transformationController: _transformController,
                minScale: 0.5,
                maxScale: 3.0,
                boundaryMargin: const EdgeInsets.all(80),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildFloorPlanContent(),
                  ),
                ),
              ),
              // Zoom controls
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildControlIcon(Icons.zoom_in, _zoomIn),
                        _buildDivider(),
                        _buildControlIcon(Icons.zoom_out, _zoomOut),
                        _buildDivider(),
                        GestureDetector(
                          onTap: _resetView,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text('RESET',
                                style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloorPlanContent() {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withValues(alpha: 0.15), width: 2),
        color: Colors.white.withValues(alpha: 0.6),
      ),
      child: Stack(
        children: [
          // Room dividers
          Positioned(
            left: 0, right: 0, top: 140,
            child: Container(height: 1,
                color: Colors.black.withValues(alpha: 0.12)),
          ),
          Positioned(
            top: 0, bottom: 140, left: 190,
            child: Container(width: 1,
                color: Colors.black.withValues(alpha: 0.12)),
          ),
          // Room labels
          Positioned(
            top: 16, left: 16,
            child: _buildRoomLabel('PRIMARY SUITE', '742 sq ft'),
          ),
          Positioned(
            top: 16, right: 16,
            child: _buildRoomLabel('STUDY', '280 sq ft', align: CrossAxisAlignment.end),
          ),
          Positioned(
            bottom: 16, left: 16,
            child: _buildRoomLabel('GRAND SALON', '1,120 sq ft'),
          ),
          Positioned(
            bottom: 16, right: 16,
            child: _buildRoomLabel('KITCHEN', '380 sq ft', align: CrossAxisAlignment.end),
          ),
          // Furniture icons
          Positioned(
            top: 50, left: 60,
            child: Icon(Icons.king_bed_outlined,
                size: 80, color: Colors.black.withValues(alpha: 0.1)),
          ),
          Positioned(
            bottom: 50, left: 80,
            child: Icon(Icons.weekend_outlined,
                size: 60, color: Colors.black.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomLabel(String name, String size,
      {CrossAxisAlignment align = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(name,
            style: GoogleFonts.manrope(
                fontSize: 7,
                fontWeight: FontWeight.w800,
                color: Colors.black38,
                letterSpacing: 1)),
        Text(size,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
      ],
    );
  }

  Widget _buildControlIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: Colors.white60, size: 20),
      ),
    );
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 16, color: Colors.white10);

  Widget _buildDetailsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Architectural Summary',
            style: GoogleFonts.manrope(
                fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(
          'Designed with an uncompromising vision of verticality, the Penthouse layout prioritizes unobstructed 270-degree views of the coastline.',
          style:
              GoogleFonts.inter(fontSize: 16, color: Colors.black54, height: 1.6),
        ),
        const SizedBox(height: 32),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2,
          children: [
            _buildStatCard('TOTAL AREA', '4,850 ft²'),
            _buildStatCard('BEDROOMS', '04'),
            _buildStatCard('BATHROOMS', '5.5'),
            _buildStatCard('TERRACE', '1,200 ft²'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4C54B6),
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildAITip() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration:
          BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome,
              color: Color(0xFFB39DDB), size: 28),
          const SizedBox(height: 16),
          Text('The Curator AI Tip',
              style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '"The primary suite placement optimizes for morning light. '
            'Consider the optional \'Sunrise Glass\' upgrade for full-spectrum dawn immersion."',
            style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(
            top: 0,
            left: 0,
            child: RepaintBoundary(child: _GradientSphere(color: const Color(0xFFF8F9FA)))),
        Positioned(
            top: 0,
            right: 0,
            child: RepaintBoundary(child: _GradientSphere(
                color: const Color(0xFFE0E0FF).withValues(alpha: 0.5)))),
        Positioned(
            bottom: 0,
            right: 0,
            child: RepaintBoundary(child: _GradientSphere(color: const Color(0xFFF3F4F5)))),
        Positioned(
            bottom: 0,
            left: 0,
            child: RepaintBoundary(child: _GradientSphere(color: const Color(0xFFDEE2ED)))),
      ],
    );
  }
}

class _GradientSphere extends StatelessWidget {
  final Color color;
  const _GradientSphere({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 600,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          radius: 0.8,
        ),
      ),
    );
  }
}
