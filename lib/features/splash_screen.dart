import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_screen.dart';
import 'search/search_home_screen.dart';
import '../shared/widgets/glass_card.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Onboarding after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => user != null ? const SearchHomeScreen() : const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
    
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          _buildMeshGradient(),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  GlassCard(
                    child: Padding(
                      padding: EdgeInsets.all(width * 0.06),
                      child: Icon(
                        Icons.home_max_outlined,
                        size: width * 0.18,
                        color: Colors.black.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                  Text(
                    'Ethereal Estate',
                    style: GoogleFonts.manrope(
                      fontSize: width * 0.1,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: -2,
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                    child: Text(
                      'Curating celestial living spaces for the modern visionary.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: width * 0.04,
                        color: Colors.black.withValues(alpha: 0.6),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  Text(
                    'V1.0.2',
                    style: GoogleFonts.manrope(
                      fontSize: width * 0.03,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
          ),
          
          Positioned(
            top: -100,
            left: -100,
            child: _BlurCircle(color: const Color(0xFF4C54B6).withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _BlurCircle(color: const Color(0xFF515F78).withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _GradientSphere(color: const Color(0xFFF0F4FF))),
        Positioned(top: 0, right: 0, child: _GradientSphere(color: const Color(0xFFFFF9E6))),
        Positioned(bottom: 0, right: 0, child: _GradientSphere(color: const Color(0xFFFFF5F7))),
        Positioned(bottom: 0, left: 0, child: _GradientSphere(color: const Color(0xFFF8F9FA))),
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
      width: 500,
      height: 500,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          radius: 0.8,
        ),
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  const _BlurCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
