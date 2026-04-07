import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_screen.dart';
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
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mesh Gradient Background
          Container(
            color: Colors.white,
          ),
          _buildMeshGradient(),
          
          // Background Texture (Subtle Grain)
          Opacity(
            opacity: 0.05,
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBba0vQN25HlVtABULRm_pqfdo4q-74WYh4yS7BgPMk4OvhBQwW1IxL66zXia5ye_CYNXbQkLx_cbbcxL2KTJroFQduL99eSN6uXP_pYrDw7BktldC_E58RYckTNpWOsaQvqZKX-eT0Gp0zIj5guSxYK7nA9ooT-L_bsZLTkG3X4QvHBuUfKgcHsl64NYpAXrzlXD-XdR4xivcEiXMsLc3rIHOkWGrB2RbM60hLOwlnMRv82Ory66JsCyOsDmwHfj_zxkW98WVVoQc',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Center Identity
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minimalist Logo with Glassmorphism
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Icon(
                      Icons.home_max_outlined,
                      size: 80,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Brand Typography
                Text(
                  'Ethereal Estate',
                  style: GoogleFonts.manrope(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Tagline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'Curating celestial living spaces for the modern visionary.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      color: Colors.black.withOpacity(0.6),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Footer App Version
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4C54B6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'V1.0.2',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Decorative Blur Elements
          Positioned(
            top: -100,
            left: -100,
            child: _BlurCircle(color: const Color(0xFF4C54B6).withOpacity(0.05)),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _BlurCircle(color: const Color(0xFF515F78).withOpacity(0.08)),
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
          colors: [color, color.withOpacity(0)],
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
