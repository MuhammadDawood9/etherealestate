import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class InteractiveMapScreen extends StatelessWidget {
  const InteractiveMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Simulated Map Background
          _buildMapBackground(),
          
          // Glass Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(context),
          ),

          // Custom Map Pins
          _buildPins(),

          // Search Bar Overlay
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),

          // Floating Action Buttons
          Positioned(
            right: 24,
            bottom: 240,
            child: Column(
              children: [
                _buildFAB(Icons.my_location),
                const SizedBox(height: 16),
                _buildFAB(Icons.layers_outlined),
              ],
            ),
          ),

          // Property Preview Card
          Positioned(
            bottom: 110,
            left: 16,
            right: 16,
            child: _buildPropertyPreview(),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        image: DecorationImage(
          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCsqD7ZETJOzdWzvyHB2kOOa6Tu9giZe6GOHwOgUHfcVgTb6iaIT5LJtBNZa79mCaUXyHJ5CD0BPM3EdbKioONZg8iK8LX7bjC-Zzfd9n6t7R0on9QMBASGB5LrfkHL1Hiq49qT1YqYxZJnHDFQuSPgEcmAwuZg-ljM9W5nkdz5f-7yI6tHpMGoAMYI1PagF694od6uiJCVf7WTj-UWqBzZO_8aGY3d4ADLimxn5KZM62RwXhMkYVExM5CNIFObRj-cIboUw-7AbFs'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.2))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu, color: Color(0xFF0A192F)),
                  const SizedBox(width: 16),
                  Text(
                    'Ethereal Estate',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0A192F),
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 18,
                backgroundImage: const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCkxpIpR4eW6aRaUlJpDvzt51LutIl73O3p4LIPmIC-p5C_MdU1V6XercYFC2Jf6dGTMw8evEUDxyAcLEs3-Up7FgvKsJz2fBQ0Tdy8ZW7TWWZ8fam36WJMj_x2P8MAGn7LwlINwadIOmg3PMWXTwgxgs1tuEHImsZdKomzCzFIWcfzg-hi44HoIU31OVwo7eupcjKYxpd0qSf6ZlddlrB5PaxqlDzm4W8NCf2Lq3dYuvxhoA9SIohDHFNrgDQLouDN2xNiVNYmeHg'),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextField(
            decoration: InputDecoration(
              icon: const Icon(Icons.search, color: Color(0xFF0A192F)),
              hintText: 'Search curated properties...',
              hintStyle: GoogleFonts.inter(color: const Color(0xFF0A192F).withOpacity(0.4), fontWeight: FontWeight.w500),
              border: InputBorder.none,
              suffixIcon: const Icon(Icons.tune, color: Color(0xFF0A192F)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPins() {
    return Stack(
      children: [
        Positioned(
          top: 300,
          left: 100,
          child: _MapPin(isActive: false),
        ),
        Positioned(
          top: 450,
          right: 120,
          child: _MapPin(isActive: true),
        ),
        Positioned(
          top: 550,
          left: 150,
          child: _MapPin(isActive: false),
        ),
      ],
    );
  }

  Widget _buildFAB(IconData icon) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Icon(icon, color: const Color(0xFF0A192F)),
    );
  }

  Widget _buildPropertyPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDHYNpVV4WWHEK_L-0Cwvs5sSKktQ-n1uyN9AiQjZ6CluHV1Z4m103-yPUqEohqAdh4TgC_l_S_ImOXNB-E54nqKe0rCNlugPKTZOnXcC5xh7jSg0LS8dCHjPaNTqWlPdG7bOqYXd6WoaHN_b1DYBU26FhuT2qeJ6-hJsd9czOQrKN2cpMKeGjvyM3LZ8ZeV8j4farr6n_9Fb9eiYQrHI90ScDg70nzJXj-tWFnopw4mb-dbQ-V1eVt1jA8rTX9CmnulsErkpupGsg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Obsidian Suite',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: const Color(0xFF0A192F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.near_me, size: 12, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text('Presidio Heights, SF', style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$4,250,000', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 18)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A192F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'DETAILS',
                            style: GoogleFonts.manrope(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final bool isActive;
  const _MapPin({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: isActive ? 44 : 36,
          height: isActive ? 44 : 36,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0A192F) : const Color(0xFFB39DDB).withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? const Color(0xFFB39DDB) : Colors.white, width: 2),
            boxShadow: isActive ? [BoxShadow(color: const Color(0xFFB39DDB).withOpacity(0.5), blurRadius: 15)] : null,
          ),
          child: Icon(
            Icons.location_on,
            color: isActive ? const Color(0xFFB39DDB) : const Color(0xFF0A192F),
            size: isActive ? 20 : 16,
          ),
        ),
        if (isActive)
          Transform.rotate(
            angle: 0.78, // 45 degrees
            child: Container(
              width: 12,
              height: 12,
              color: const Color(0xFF0A192F),
              margin: const EdgeInsets.only(top: -6),
            ),
          ),
      ],
    );
  }
}
