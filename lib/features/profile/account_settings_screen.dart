import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

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
                children: [
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildProfileHero(),
                  const SizedBox(height: 48),
                  _buildSettingsSection(
                    'Account',
                    [
                      _SettingsItem(icon: Icons.person_outline, title: 'Personal Information'),
                      _SettingsItem(icon: Icons.search, title: 'Saved Searches'),
                      _SettingsItem(icon: Icons.account_balance_outlined, title: 'Mortgage Status', badge: 'ACTIVE'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    'Preferences',
                    [
                      _SettingsItem(icon: Icons.tune, title: 'App Preferences'),
                      _SettingsItem(icon: Icons.notifications_none, title: 'Notifications'),
                      _SettingsItem(icon: Icons.security_outlined, title: 'Privacy & Security'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    'Support',
                    [
                      _SettingsItem(icon: Icons.help_outline, title: 'Help Center'),
                    ],
                  ),
                  const SizedBox(height: 48),
                  _buildLogoutButton(),
                  const SizedBox(height: 24),
                  Text(
                    'VERSION 2.4.0 (GOLD)',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.menu, color: Colors.black),
        Text(
          'Ethereal Estate',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAAbquHgdsv76RprR7c_xPuNjJoTTSbdtBqQXQl6-_R4xU0pZGQlpjmQ8E4PGrcBM81BVvevEh4-XLi5pAc6IRev2vDqUHv9lHv9eBYaBMiNQJ0adSlw1TXGOYPKH8P5FuBdvsTAkRRQ4NBNB1Bt_SO7VTYD5oMj5p5synOedgjzfBHzgPjwatCRroAVAzQUqzkOg0c75jNxncaaB-1ZwrkBdZA_EB87n4Yb1Mm7YjEi2pahD3TWV4RZEpD0J4s6hOjUt0ELS7Ms2Y'),
        ),
      ],
    );
  }

  Widget _buildProfileHero() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF4C54B6), Color(0xFFB9C7E4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 56,
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD3_v7-Brsvfc8plbIrEu5LxQ9X7IdbOibbXz8t21Vq2aHGdGS7V5Ioohy37ADsUpglL7TL5Nvvip_ZTuiZuAtyaNcEYXhGtCxw5Cjjx4yX5z1iE2eCmb6RW1RuL-9QpxUl_Ldcel0mI_UVhyR-sG7tcxoRLLD6t0fxgTK6l3gVuGc5cR8BZTiX4CQK4FbFLsedqi8NCLyoGb9h3tP-ppSPWo_FBn1iPPf3rj3wrsHOS1JuhTTFH0sJtcLV-qk6nzvru6WoawIE25Q'),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Julian Thorne',
          style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
        ),
        const SizedBox(height: 4),
        Text(
          'Premium Member • London, UK',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<_SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            children: items.map((item) => _buildListTile(item)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(_SettingsItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF4C54B6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, color: const Color(0xFF4C54B6), size: 20),
      ),
      title: Text(
        item.title,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4C54B6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.badge!,
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF4C54B6), letterSpacing: 1),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.logout, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Text(
            'Logout',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: Colors.redAccent, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _GradientSphere(color: const Color(0xFFE0E0FF).withOpacity(0.4))),
        Positioned(top: 0, right: 0, child: _GradientSphere(color: const Color(0xFF8F98FE).withOpacity(0.2))),
        Positioned(bottom: 0, left: 0, right: 0, child: _GradientSphere(color: const Color(0xFFF3F4F5))),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? badge;
  _SettingsItem({required this.icon, required this.title, this.badge});
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
