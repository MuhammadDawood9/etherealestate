import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/widgets/glass_card.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Global Mesh Gradient Background
          _buildMeshGradient(),

          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildOnboardingPage1(),
              _buildOnboardingPage2(),
            ],
          ),

          // Global Branding Anchor at Bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: Colors.black26),
                const SizedBox(width: 8),
                Text(
                  'ETHEREAL ESTATE',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Colors.black26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Feature Image Card
          _buildFeatureCard(
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDB1VmnS5mFjzbZhQDYofSR3JLjlkoNmEhGWDfjU6HNAsp7GBuij5CYuPN5h7utPA6TzGRRdJHDqiaoSNcigQ7JvRl4mXD0SBcGi1hlwD4ZJkZu2ZfNGTQ-TXfmZ6kmPDdi2LSFjxbgnsbx_fz-08bcxPsRnkffYhhKJRH4aWKbalmktMKVoV1Ut-qN9eltW6d5zhuG2crxiNBiyQs03ZyQcNsQO5xNqhTpxppjdRa20kId26TSRWj2mEhcE-jRT9jB6Tzr34brXvI',
            pageIndex: 0,
          ),
          const SizedBox(height: 48),
          // Text Content
          Text(
            'Discover',
            style: GoogleFonts.manrope(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Experience the future of luxury real estate through our celestial gallery of exclusive estates.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          // Actions
          _buildPrimaryButton('Get Started', () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Text(
              'SKIP FOR NOW',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            'Step 02 — Personalization',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.black38,
            ),
          ),
          const SizedBox(height: 40),
          // Stacked Cards Visual with Hover Effect
          const _CurationVisual(),
          const SizedBox(height: 48),
          // Text Content
          Text(
            'Curation',
            style: GoogleFonts.manrope(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Experience a property search that understands you. Our AI Curator analyzes your lifestyle preferences.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          // Custom Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(false),
              const SizedBox(width: 8),
              _buildDot(true),
              const SizedBox(width: 8),
              _buildDot(false),
            ],
          ),
          const SizedBox(height: 48),
          // Bottom Actions
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text('Skip', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.black54)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildPrimaryButton('Next', () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }, icon: Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({required String imageUrl, required int pageIndex}) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
        ),
        // Glass Indicator Overlay
        Positioned(
          bottom: 24,
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(width: 32, height: 6, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 8),
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4C54B6) : Colors.black12,
        borderRadius: BorderRadius.circular(4),
        boxShadow: active ? [BoxShadow(color: const Color(0xFF4C54B6).withOpacity(0.3), blurRadius: 8)] : null,
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed, {IconData? icon}) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text.toUpperCase(),
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 14),
            ),
            if (icon != null) ...[
              const SizedBox(width: 12),
              Icon(icon, size: 18),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _GradientSphere(color: const Color(0xFFF0F4FF).withOpacity(0.5))),
        Positioned(top: 0, right: 0, child: _GradientSphere(color: const Color(0xFFFFF9E6).withOpacity(0.4))),
        Positioned(bottom: 0, right: 0, child: _GradientSphere(color: const Color(0xFFFFF5F7).withOpacity(0.3))),
        Positioned(bottom: 0, left: 0, child: _GradientSphere(color: const Color(0xFFF8F9FA).withOpacity(0.5))),
      ],
    );
  }
}

class _CurationVisual extends StatelessWidget {
  const _CurationVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Cards
          const _HoverableCard(
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAHkrASmDghch68qVOCCju6z64QusC8lbeKwtllIfAqqqCj1V8l4CxcYVCkWVxirTeUbTSLbo8-GLK37tZ0MgJ9uOiIZqX9Icsokd7WTLxbZPIs96LVH_UcvL5j8tCHJowz4phynbsHnCWwpdR38X4-ntGoWglzra7k7r8S7-WBLdC2EwKfhXHud8d1IiVmOWIJOjQ66iPfGOezE3N4vLRuwPWU9kvGW0t91DmhpElb2hLSMG_Gr214eCVFeULq1DR5KsXz6_UOXlg',
            title: 'Tribeca Glasshouse',
            angle: -0.1,
            offset: Offset(-80, 0),
            isSmall: true,
          ),
          const _HoverableCard(
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAhft-ML0oq7IqNCkqSafcB_jrxpcs6gvlKuO4M9Qwi-BRgFy1o_Zfs6P6SGVTBsW1KCWH-hxYLPhvtHKltJgON9Wb0uGK6nzjTDg2EQHf5tLEdECW0v2fwlPU6rQMO64j_teZC26PNhJDGBu9SkuoqDrOYSPkNWPnCgfV49HY3HdGAggXK1CRlwt0EcqPJaIAy-xDPsC8bTBRBQytiYRGfTSua7Q22C_GoiOOoRpTYSscyCvnPui8IVv1rHoafV1ljGhuw5TISaRE',
            title: 'Nordic Retreat',
            angle: 0.1,
            offset: Offset(80, 0),
            isSmall: true,
          ),
          // Center Main Card
          const _HoverableCard(
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDuuiOlG2omqLD7xCiXOZ9etDCnZn9g2LmU0825QXlfcfzGhl0Y20M9tQMkD7unVPj-GyLgYbD2xIFOyOXrWoqnU-LmBkuOQ2u0wuH3JBZhSB6inDTzaOULMWU5u1Zo8SPwEBkl1oWymaKUThh-GNoUqAt8Y53-auZoYF62fpC5-zzhdDM02VFFiL_yGxZU4tMkuY9nGjJtNTe4rEK6Hk37lQzD7mqReWILQtUuhH061WVg1r9_iHsZCzXyspUxaN6IV97GRIOM4vc',
            title: 'Azure Horizon',
            subtitle: 'Malibu, CA',
            isSmall: false,
          ),
          // AI Badge
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 12, color: Color(0xFF4C54B6)),
                  const SizedBox(width: 8),
                  Text('Curator AI is learning...', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverableCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final double angle;
  final Offset offset;
  final bool isSmall;

  const _HoverableCard({
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.angle = 0,
    this.offset = Offset.zero,
    required this.isSmall,
  });

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(widget.offset.dx, widget.offset.dy)
          ..rotateZ(widget.angle)
          ..scale(_isHovered ? 1.15 : (widget.isSmall ? 1.0 : 1.1))
          ..translate(0.0, _isHovered ? -20.0 : 0.0),
        child: Container(
          width: widget.isSmall ? 160 : 220,
          height: widget.isSmall ? 220 : 300,
          decoration: BoxDecoration(
            color: widget.isSmall ? Colors.white.withAlpha(50) : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(widget.isSmall ? 24 : 32),
            border: Border.all(color: Colors.white.withOpacity(widget.isSmall ? 0.3 : 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.05),
                blurRadius: _isHovered ? 60 : 40,
                offset: Offset(0, _isHovered ? 20 : 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.isSmall ? 24 : 32),
            child: widget.isSmall
                ? Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    color: Colors.white.withOpacity(_isHovered ? 0.0 : 0.3),
                    colorBlendMode: BlendMode.screen,
                  )
                : Column(
                    children: [
                      Expanded(child: Image.network(widget.imageUrl, fit: BoxFit.cover)),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (widget.subtitle != null)
                              Text(widget.subtitle!, style: GoogleFonts.inter(fontSize: 10, color: Colors.black45)),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GradientSphere extends StatelessWidget {
  final Color color;
  const _GradientSphere({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
          radius: 0.8,
        ),
      ),
    );
  }
}
