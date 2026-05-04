import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../search/search_filter_screen.dart';

class PropertyItem {
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final String beds;
  final String baths;
  final String sqft;

  PropertyItem({
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.beds,
    required this.baths,
    required this.sqft,
  });
}

class PropertyFeedScreen extends StatelessWidget {
  PropertyFeedScreen({super.key});

  final List<PropertyItem> properties = [
    PropertyItem(
      title: 'DHA Phase 5 Villa',
      location: 'DHA Phase 5, Lahore',
      price: 'PKR 9.5 Cr',
      beds: '5',
      baths: '5',
      sqft: '5,500',
      imageUrl: 'https://picsum.photos/seed/lhr001/600/450',
    ),
    PropertyItem(
      title: 'Gulberg Heights Penthouse',
      location: 'Gulberg III, Lahore',
      price: 'PKR 4.8 Cr',
      beds: '3',
      baths: '3',
      sqft: '2,800',
      imageUrl: 'https://picsum.photos/seed/lhr002/600/450',
    ),
    PropertyItem(
      title: 'Bahria Town Grand Mansion',
      location: 'Bahria Town, Lahore',
      price: 'PKR 14.2 Cr',
      beds: '6',
      baths: '6',
      sqft: '8,000',
      imageUrl: 'https://picsum.photos/seed/lhr003/600/450',
    ),
  ];

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
                  Text(
                    'Available Properties',
                    style: GoogleFonts.manrope(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Curated sanctuaries designed for the celestial living experience.',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ...properties.map((p) => _buildPropertyCard(context, p)).toList(),
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
        IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SearchFilterScreen(),
                );
              },
              icon: const Icon(Icons.tune, size: 18, color: Color(0xFF4C54B6)),
              label: Text('FILTER', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.5),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(width: 16),
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDhHpWUrY3HEujzN-U82isaZWJeK5o1DUmLQI4s81TjLPPjwdfJuoVwnyRQR_W9_DCgKhsEBVLW-7T4bXMoGYQF5ohCLN6WAQ3crIh0tUI7J7eUuxM1rJQVEwhK4sS5ZnbAHRdjw74-ISz-FzmSjvqf98uZyILdlulW0DqSKDrFb6KU38vLzm52V4yy0f_tPStjvjrD9c4EDBsfRbYFcx-9orGEQ4UUIwplYYryKfPhCHgoB9OE5zNIbGmcYa81EhCUctcUXjxkAYE'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, PropertyItem property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(property.imageUrl, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(property.title, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(property.price, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF4C54B6))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text(property.location, style: GoogleFonts.inter(fontSize: 14, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  color: Colors.black.withOpacity(0.05),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeature(Icons.king_bed_outlined, '${property.beds} BEDS'),
                    _buildFeature(Icons.bathtub_outlined, '${property.baths} BATHS'),
                    _buildFeature(Icons.straighten, '${property.sqft} SQFT'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4C54B6)),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
      ],
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
