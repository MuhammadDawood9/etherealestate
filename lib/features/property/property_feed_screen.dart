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
      title: 'The Obsidian Villa',
      location: 'Zurich, Switzerland',
      price: '\$4,250,000',
      beds: '4',
      baths: '3',
      sqft: '3,400',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCV0r0KIZCrfNysTErmc60hRhY2WOox_vj2F0e6D0baIFV8cEWIGiygFMAHX12yzxcIWKMDPl0ZAmF8z0ScAKKBbd57NcBAxTogsVpKRvazmV6vA2ciCY9q8xFNe75r1C_PJI9bvelns7Yt7cWQ2JziyhzzM4qQLEVu6l7Y-HtQuGrRuBpXrcDIueXMYN1ryUUiv50M2pcQjh3FQBiSSFoBcf5lx0nkTsxOUCVS8JHq27zk9o-CY0aZyFTSgBDb45LKZXf6SRezRe4',
    ),
    PropertyItem(
      title: 'Cloud Sanctuary',
      location: 'Malibu, California',
      price: '\$2,800,000',
      beds: '3',
      baths: '2',
      sqft: '2,150',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCKsPaAFOwQORgzvCyHV9Xe90SdT93uKDc3TUNd3sD7z4tBJxIuIXCKNuOYxRD100NLv5xW1dxsLe5CGjz9GvVxdM7LOPqNWVQ3kOTwWPEOnAd3xat3cH5b2-5hG7sWECmRA013Mc89WPPghxYVSKwHBGC34nEs3Dd_k3XHy1DBawedAZu0xgmB0gc9cmP3b0fwliWzp2cMmA3lpAbWUC39I0oKAxlafypgZBwfEnJN0AqPyTUuQG_I5j1e2DUQqsPdpn2c5CyJVFY',
    ),
    PropertyItem(
      title: 'Pearl Residence',
      location: 'Santorini, Greece',
      price: '\$6,100,000',
      beds: '5',
      baths: '5',
      sqft: '5,800',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDPFaAz9XK-mg-tXvkfJJdcUU0ioHwx6v_F2tAHNiFEtNE6M3VmSKZpswxQcx92YcXLsa40GHh504Bvb0vUZHWFWOfxWMWpx2K_QFXnJ0qyjgGUFANwaNNKuSeWIgYl1pgjpr05HiHmxCZbLHAZdffdtEyXh6AH6FEckbdBXZqE2UM2zKroVg4Ex94Jdw033GuFU52YJP3HAyAKGyQT_oiFSuukA0XF28g8cyQOowlK5oru80reLpZLXyfQQKLhhF1WHYcZ759GbBo',
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
