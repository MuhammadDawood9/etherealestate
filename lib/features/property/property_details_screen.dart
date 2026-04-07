import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildHeroSection(context),
                _buildContentSection(),
              ],
            ),
          ),
          _buildTopNavigation(context),
          _buildStickyFooter(),
        ],
      ),
    );
  }

  Widget _buildTopNavigation(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
            color: Colors.white.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                Row(
                  children: [
                    _buildNavButton(Icons.favorite_border, () {}),
                    const SizedBox(width: 12),
                    _buildNavButton(Icons.share_outlined, () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              )
            ],
            image: const DecorationImage(
              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBnbAt0XvbcVtTFfcqfHWDB32-3MAvYRzW8K3dpL1InvBVMy4Lg8oqaNLSJVeEG0sBQJmKjGoOboihI5_BYpX-ilTduwqqfQvFK_ZdDw3UkH72lAnZtVY6koTPLI-Xx36EISLgH73ERByE2tP1kggq6dfM49BAZAUjKHyfau1i_sldqdy1818kgG392uNQGZi8w677lG5VU7NDNVCCNMvJeClQEWwKcszn8vk-duAbBrP7OnIpG6lGstRBIhv35g6b6XA7Zuh7R4c8'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
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
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        '\$4,250,000',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
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

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'The Obsidian Glass House',
            style: GoogleFonts.manrope(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Color(0xFF4C54B6)),
              const SizedBox(width: 8),
              Text(
                'Bel Air, Los Angeles',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeatureIcon(Icons.king_bed, '4', 'Bedrooms'),
              _buildFeatureIcon(Icons.bathtub, '3', 'Baths'),
              _buildFeatureIcon(Icons.straighten, '3,200', 'Sqft'),
            ],
          ),
          const SizedBox(height: 48),
          Text(
            'Architectural Narrative',
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'A masterpiece of light and shadow, The Obsidian Glass House redefines California modernism. Situated on a private promontory, this residence leverages a 1:1 connection between interior sanctuaries and the surrounding landscape.',
            style: GoogleFonts.inter(
              fontSize: 17,
              color: Colors.black54,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 40),
          _buildAmenityGrid(),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4C54B6), size: 28),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildAmenityGrid() {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            image: const DecorationImage(
              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAAUCkD_OW2Y367qK3xsAPX2bVxPWvibjp3xNw4DQyQ0CedbkpXt1GTo1yfvRAwU3wQWyJhIugUYUTHDwAa3SfpL9yrFN9skk-vRi1tsJ9YsPVwEvTvKyOBSGIj-qezcG1rMais1WJEOUlpapVSpj577CXpJNyaIRNblFQitl6rm5WOf1AIY-G4gTKG6nbqqXLy-ym5EQWIVaPlNIjzSTGh_Q6xFK9R32xwu46e2Jej1eZZRJu1W9-EQOkmAiEDLnqu1NbBBrckxec'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
            child: Text(
              'Infinity Vista Pool',
              style: GoogleFonts.manrope(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSmallAmenity(Icons.wine_bar, 'Sommelier Cellar')),
            const SizedBox(width: 16),
            Expanded(child: _buildSmallAmenity(Icons.home_max, 'Neural Automation')),
          ],
        )
      ],
    );
  }

  Widget _buildSmallAmenity(IconData icon, String label) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF4C54B6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF4C54B6).withOpacity(0.1)),
      ),
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

  Widget _buildStickyFooter() {
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
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ESTIMATED MONTHLY', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.black45)),
                      Text('\$21,450', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Center(
                      child: Text(
                        'BOOK SITE VISIT',
                        style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1),
                      ),
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

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _GradientSphere(color: const Color(0xFFF8F9FA))),
        Positioned(top: 0, right: 0, child: _GradientSphere(color: const Color(0xFFE0E0FF).withOpacity(0.5))),
        Positioned(bottom: 0, right: 0, child: _GradientSphere(color: const Color(0xFFF3F4F5))),
        Positioned(bottom: 0, left: 0, child: _GradientSphere(color: const Color(0xFFDEE2ED))),
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
          colors: [color, color.withOpacity(0)],
          radius: 0.8,
        ),
      ),
    );
  }
}
