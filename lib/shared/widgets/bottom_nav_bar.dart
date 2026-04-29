import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavBar({super.key, required this.currentIndex});

  static const List<String?> _routes = [
    AppRoutes.feed,
    AppRoutes.search,
    AppRoutes.map,
    AppRoutes.collection,
    AppRoutes.agent,
    AppRoutes.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home_max, 0),
                _buildNavItem(context, Icons.search, 1),
                _buildNavItem(context, Icons.map_outlined, 2),
                _buildNavItem(context, Icons.auto_awesome, 3),
                _buildNavItem(context, Icons.person_pin_outlined, 4),
                _buildNavItem(context, Icons.manage_accounts_outlined, 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    final bool isActive = currentIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            if (isActive) return;
            final route = _routes[index];
            if (route != null) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
          icon: Icon(
            icon,
            color: isActive ? const Color(0xFF4C54B6) : Colors.black26,
            size: isActive ? 28 : 24,
          ),
        ),
        if (isActive)
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF4C54B6),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
