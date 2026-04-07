import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});

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
                  const SizedBox(height: 40),
                  _buildAgentHero(),
                  const SizedBox(height: 48),
                  _buildCurrentCurationHeader(),
                  const SizedBox(height: 24),
                  _buildPropertyGrid(),
                  const SizedBox(height: 48),
                  _buildPhilosophySection(),
                  const SizedBox(height: 24),
                  _buildExpertiseCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
        ),
        Text(
          'Ethereal Estate',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
        ),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCIoQuTjb9Y9_jkaQOOKFmAp1KEqnHeyNmGqTEu47CQ6-3T5Gv9xU7xyRXS2ivomC9DyB0zbZoJLuIGi1N9F4xJSDHCgSDyEIj8UdZgbrm7yi3l3UPpbS-xbeW0FufY5xPUw8feo6dbiPUZ-IFe5Q0g5R11xIm6sdgyIt7wSX_XuVbxXwQaa071lP_vPnh_TyTso_1Ah3zvg0_qc-Gqvc9oIuHGVhsCG5hvpW1zOjk3FFYICYoJb8J_2cgX0qDHC4InamsFKCA-Pd4'),
        ),
      ],
    );
  }

  Widget _buildAgentHero() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBODg7XwyS3wTCqlF0i4zT4eoWaLRUI0YO_pD3HbbtgCv_fdo8wVBbtB-2JELzJD0C3l_tUqYhbip7y7pH_7NBv-sTiu21_4RnWeE9s_U5OZ2V1X4LyJcrThbmaNTkaxK95RWUomm08bFkqMmrEIKV6--RbRv9PCdo_PS9P8gcAZPVmz4E5Z-0N5Q_dtpkJOkOJkBS_x0QN4_oFltWsqCguNtR2MBF4MjDSd0smFn1OeskpsXpKckVq2-qONmsZwLmE2k-kZPTgVRA'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C54B6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0xFF4C54B6).withOpacity(0.3), blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 14),
                      const SizedBox(width: 8),
                      Text('VERIFIED CURATOR', style: GoogleFonts.manrope(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text('Julian Sterling', style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(
            'Principal Curator & Luxury Portfolio Strategist',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('124', 'SOLD'),
              _buildStat('9+', 'YEARS'),
              _buildStat('4.9', 'RATING'),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(child: _buildActionBtn(Icons.mail_outline, 'MESSAGE', true)),
              const SizedBox(width: 12),
              Expanded(child: _buildActionBtn(Icons.call_outlined, 'REQUEST CALL', false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800)),
        Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black26, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, String label, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? null : Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: isPrimary ? Colors.white : Colors.black),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isPrimary ? Colors.white : Colors.black,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentCurationHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENT CURATION', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: const Color(0xFF4C54B6))),
            Text('Exclusive Listings', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: Color(0xFF4C54B6)))),
      ],
    );
  }

  Widget _buildPropertyGrid() {
    return SizedBox(
      height: 280,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildMiniCard('The Obsidian Pavilion', 'Beverly Hills, CA', '\$12.4M', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAqYklztmabyJxSKAH0a_Lrlfy9XF7WXHHIVTkesqG-Nhi1raAiGJAd11v_PaFAAt9Qt9iEbSryoP2mZBWeBZNh3sSXCTg0Sy_uApaFZEh58ADx_h_w0lYNIly-cYze3OsxLxzI2SV-qMxDoRHzq1hnTp2qB57vNuAT_q5hAIDVvr4bgyikCO461HIogbrik48STOIPz8Llmgwi1LdCTdRJGZ3ttK2N3UyQLGFQ3YuBZUM1GxKVm4Cn3RmFP-dztPGtAM9VoQkHae8'),
          const SizedBox(width: 16),
          _buildMiniCard('Lustre Point Manor', 'Aspen, CO', '\$8.9M', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDasAGCnfR028rm99421dmyS7HtuF-wWOfHW3azDIDLf1xmbScAUawEfuIJcagsAr7_DEtMeAxlN9nQgt8Y0wNb9B5WHn52m0SMsPBkUgxJK0DfaS2yjVpdXNASrSpPjhvQxaaqWoCppqhDsEEYKxrhYuAYU1yaeIRjvfxEyKgGubky7w1ymFZiBRdh_fRkZoRKM4TTXNFjAEZHh1DeuqlJ2TBj6TTjT5KwUgnNjZTJrsrMyPbxrF3URV9-QNty-5pifbpj9iyt5Ao'),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String title, String loc, String price, String img) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(loc, style: GoogleFonts.inter(fontSize: 10, color: Colors.black45)),
                const SizedBox(height: 8),
                Text(price, style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: const Color(0xFF4C54B6))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPhilosophySection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THE CURATOR\'S PHILOSOPHY', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF4C54B6), letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Text(
            '"I don\'t just sell property; I curate legacies. Every estate in my portfolio is selected for its architectural integrity and soul."',
            style: GoogleFonts.inter(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertiseCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EXPERTISE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFFB9C7E4), letterSpacing: 1.5)),
          const SizedBox(height: 24),
          _buildExpertiseItem('Penthouse Acquisitions'),
          _buildExpertiseItem('Private Island Sales'),
          _buildExpertiseItem('Heritage Restoration'),
        ],
      ),
    );
  }

  Widget _buildExpertiseItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.star, color: Color(0xFF4C54B6), size: 14),
          const SizedBox(width: 12),
          Text(text, style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _GradientSphere(color: const Color(0xFFE0E0FF).withOpacity(0.5))),
        Positioned(top: 0, right: 0, child: _GradientSphere(color: const Color(0xFFF3F4F5))),
        Positioned(bottom: 0, left: 0, right: 0, child: _GradientSphere(color: const Color(0xFFF8F9FA))),
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
