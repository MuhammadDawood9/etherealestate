import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

void _showContactDialog(BuildContext context, String type) {
  final isMessage = type == 'message';
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        isMessage ? 'Message Curator' : 'Request a Call',
        style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
      ),
      content: Text(
        isMessage
            ? 'A Lahore property expert will respond within 2 hours.\nContact: curator@ethereal.estate'
            : 'Our team will call you within 24 hours.\nPhone: +92 42 111 ESTATE',
        style: GoogleFonts.inter(color: Colors.black54, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Close', style: GoogleFonts.inter(color: Colors.black45, fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(isMessage ? 'Message sent to your curator.' : 'Call request submitted.', style: GoogleFonts.inter()),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF4C54B6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(isMessage ? 'Send' : 'Request', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}

const _agentIllustrationUrl =
    'https://api.dicebear.com/8.x/avataaars/png?seed=Ashfaq&size=400&backgroundColor=transparent';

const _userAvatarUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCIoQuTjb9Y9_jkaQOOKFmAp1KEqnHeyNmGqTEu47CQ6-3T5Gv9xU7xyRXS2ivomC9DyB0zbZoJLuIGi1N9F4xJSDHCgSDyEIj8UdZgbrm7yi3l3UPpbS-xbeW0FufY5xPUw8feo6dbiPUZ-IFe5Q0g5R11xIm6sdgyIt7wSX_XuVbxXwQaa071lP_vPnh_TyTso_1Ah3zvg0_qc-Gqvc9oIuHGVhsCG5hvpW1zOjk3FFYICYoJb8J_2cgX0qDHC4InamsFKCA-Pd4';

const _testimonials = [
  {
    'initials': 'AR',
    'name': 'Ahmed R.',
    'property': 'DHA Phase 6 Villa',
    'quote': 'Ashfaq found us exactly what we envisioned. A true luxury experience from start to finish.',
    'rating': 5,
  },
  {
    'initials': 'SF',
    'name': 'Sara F.',
    'property': 'Gulberg Penthouse',
    'quote': 'Impeccable taste and zero pressure. The deal closed in under three weeks.',
    'rating': 5,
  },
  {
    'initials': 'MK',
    'name': 'Mansoor K.',
    'property': 'Bahria Town Estate',
    'quote': 'An agent who genuinely understands what "premium" means. Worth every rupee.',
    'rating': 5,
  },
  {
    'initials': 'LS',
    'name': 'Layla S.',
    'property': 'Model Town Mansion',
    'quote': 'The portfolio he curated was exactly our aesthetic. We felt heard throughout.',
    'rating': 5,
  },
];

const _accentColors = [
  Color(0xFF4C54B6),
  Color(0xFF2D9CDB),
  Color(0xFF6B4C9A),
  Color(0xFF0F9D8B),
];

class AgentProfileScreen extends ConsumerStatefulWidget {
  const AgentProfileScreen({super.key});

  @override
  ConsumerState<AgentProfileScreen> createState() => _AgentProfileScreenState();
}

class _AgentProfileScreenState extends ConsumerState<AgentProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _statsController;
  late AnimationController _pulseController;
  late Animation<double> _statsAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _statsAnim = CurvedAnimation(parent: _statsController, curve: Curves.easeOutCubic);
    _statsController.forward();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.75, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _statsController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredAsync = ref.watch(featuredPropertiesProvider);
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          _buildMeshGradient(),
          CustomScrollView(
            slivers: [
              _buildParallaxHero(context),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFloatingStatsCard(context),
                    const SizedBox(height: 40),
                    _buildTestimonialsSection(),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildCurrentCurationHeader(context),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: featuredAsync.when(
                        data: (props) => _buildPropertyGrid(props),
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, s) => _buildPropertyGrid([]),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildPhilosophySection(),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildExpertiseCard(),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }

  // ─── A: Cinematic Parallax Hero ───────────────────────────────────────────

  Widget _buildParallaxHero(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 440,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.black,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
              ),
              child: const CircleAvatar(
                backgroundImage: NetworkImage(_userAvatarUrl),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Rich gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Color(0xFF0D1138),
                    Color(0xFF3D44A8),
                    Color(0xFF6B4FC8),
                  ],
                ),
              ),
            ),
            // Decorative glow circles
            Positioned(
              top: -60, right: -60,
              child: _buildGlowCircle(220, const Color(0xFF6B4FC8), 0.25),
            ),
            Positioned(
              top: 80, left: -80,
              child: _buildGlowCircle(180, const Color(0xFF4C54B6), 0.2),
            ),
            Positioned(
              bottom: 60, right: 40,
              child: _buildGlowCircle(100, const Color(0xFF9B8FE8), 0.15),
            ),
            // Illustration portrait — centered in top 60% of hero
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: 196,
                      height: 196,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4C54B6).withValues(alpha: 0.6),
                            blurRadius: 48,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    // Illustration circle
                    Container(
                      width: 172,
                      height: 172,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4C54B6).withValues(alpha: 0.3),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          _agentIllustrationUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom fade to dark
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 160,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xFF0D1138)],
                  ),
                ),
              ),
            ),
            // Name block at bottom
            Positioned(
              bottom: 36,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLiveStatusChip(),
                  const SizedBox(height: 14),
                  Text(
                    'Ashfaq',
                    style: GoogleFonts.manrope(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1.2,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Principal Curator & Luxury Portfolio Strategist',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── C: Live Status Chip with pulsing dot ────────────────────────────────

  Widget _buildGlowCircle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildLiveStatusChip() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              'Available Now',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 1, height: 12, color: Colors.white24),
            const SizedBox(width: 10),
            const Icon(Icons.verified, color: Color(0xFF4C54B6), size: 14),
            const SizedBox(width: 5),
            Text(
              'VERIFIED',
              style: GoogleFonts.inter(
                color: const Color(0xFFB9C7E4),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── C: Floating stats card with counting animation ───────────────────────

  Widget _buildFloatingStatsCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _statsAnim,
                builder: (context, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAnimatedStat((_statsAnim.value * 124).round().toString(), 'SOLD'),
                    _buildStatDivider(),
                    _buildAnimatedStat('${(_statsAnim.value * 9).round()}+', 'YEARS'),
                    _buildStatDivider(),
                    _buildAnimatedStat((_statsAnim.value * 4.9).toStringAsFixed(1), 'RATING'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showContactDialog(context, 'message'),
                      child: _buildActionBtn(Icons.mail_outline, 'MESSAGE', true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showContactDialog(context, 'call'),
                      child: _buildActionBtn(Icons.call_outlined, 'REQUEST CALL', false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Colors.black26,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: Colors.black.withValues(alpha: 0.08));
  }

  Widget _buildActionBtn(IconData icon, String label, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isPrimary ? null : Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: isPrimary ? Colors.white : Colors.black),
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

  // ─── D: Testimonials ribbon ───────────────────────────────────────────────

  Widget _buildTestimonialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CLIENT STORIES',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: const Color(0xFF4C54B6),
                ),
              ),
              Text(
                'What They Say',
                style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 196,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24, right: 8),
            itemCount: _testimonials.length,
            itemBuilder: (context, i) => _buildTestimonialCard(_testimonials[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> t, int i) {
    final accent = _accentColors[i % _accentColors.length];
    return Container(
      width: 248,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    t['initials'] as String,
                    style: GoogleFonts.manrope(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['name'] as String,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Text(
                      t['property'] as String,
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.black45),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(
              t['rating'] as int,
              (_) => const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 13),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '"${t['quote']}"',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black.withValues(alpha: 0.75),
              height: 1.55,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Existing sections ────────────────────────────────────────────────────

  Widget _buildCurrentCurationHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CURRENT CURATION',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: const Color(0xFF4C54B6),
              ),
            ),
            Text('Exclusive Listings', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/feed'),
          child: const Text('View All', style: TextStyle(color: Color(0xFF4C54B6))),
        ),
      ],
    );
  }

  Widget _buildPropertyGrid(List<PropertyModel> properties) {
    final displayProps = properties.take(5).toList();
    if (displayProps.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Text('Loading exclusive listings...', style: GoogleFonts.inter(color: Colors.black45)),
        ),
      );
    }
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayProps.length,
        itemBuilder: (context, index) {
          final p = displayProps[index];
          return Padding(
            padding: EdgeInsets.only(right: index < displayProps.length - 1 ? 16 : 24),
            child: _buildMiniCard(p.title, p.location, p.price, p.imageUrl),
          );
        },
      ),
    );
  }

  Widget _buildMiniCard(String title, String loc, String price, String img) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosophySection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE CURATOR\'S PHILOSOPHY',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4C54B6),
              letterSpacing: 1.5,
            ),
          ),
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
          Text(
            'EXPERTISE',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFB9C7E4),
              letterSpacing: 1.5,
            ),
          ),
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
        Positioned(top: 0, left: 0, child: _GradientSphere(color: const Color(0xFFE0E0FF).withValues(alpha: 0.5))),
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
          colors: [color, color.withValues(alpha: 0)],
          radius: 0.8,
        ),
      ),
    );
  }
}
