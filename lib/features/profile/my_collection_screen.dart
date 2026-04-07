import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class CollectionItem {
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final String beds;
  final String baths;
  final String sqft;

  CollectionItem({
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.beds,
    required this.baths,
    required this.sqft,
  });
}

class MyCollectionScreen extends StatelessWidget {
  MyCollectionScreen({super.key});

  final List<CollectionItem> collection = [
    CollectionItem(
      title: 'Celestial Heights Villa',
      location: 'Beverly Hills, Los Angeles',
      price: '\$4,250,000',
      beds: '5',
      baths: '6',
      sqft: '6,400',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDUXEK_aWeZOKcumrOl0L9NiS5ANxmnSXXVVJRPktQjhtXbdaifztEeyaci2MoaYQcTu7gJAOMJ3Rskuso2qC_hzaZoq4WANBT8p_xMjauF3puOW7rpd1lmbFUhu4kthE16BMfds_KeZpE8wpRQkIsGaen863DIMdotGS2q63i5i85CPHkW6ffGvXyR2Bru9iDavsg-NSpIz3YS6PtBSzFGaJxGi-8TxwMxotAG1DUzHUejFDRyWBHm4lsFIeRr4iJpvAo-3A0--VI',
    ),
    CollectionItem(
      title: 'Pearl Quartz Retreat',
      location: 'Scottsdale, Arizona',
      price: '\$2,800,000',
      beds: '4',
      baths: '4.5',
      sqft: '4,200',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuASlfnHIKEWIot3d6nU4RQ60pvJL_00qGw0kkcqfdZcAxbyNwIwrF0CDQQwoZfNROJNzDrIxrKzdoku57bym6patHabCPLMQSlZOVukLjs7DIJd-iqiRJtL0HFex68xOdmnrzcgBlDn7pP_sDV4YSNsM1CXZuQEM9SnzYxY6969JJ2MwAfu1W6b-vvfosqDGTzvIikFcRDTtelX26XQNCTGZyo_ZfHlX1CUNdxahZmnVsJ7EiWJD3TrOzudmzqjXd67arGb-b_oxxo',
    ),
    CollectionItem(
      title: 'Mist Echo Lodge',
      location: 'Lake Tahoe, California',
      price: '\$1,950,000',
      beds: '3',
      baths: '3',
      sqft: '3,100',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAWgUsiskrJ2d_xLDnuHCtKdl2r43g8lj2HMsdFLz9eCMFz0VYp-A8YGcGwuglHOxm_pc7agPUPDAw4XfyAOGs48jRGrjF-eae2aBsUpqfcG-3EuLJy5SPDsVsL4OxYd-DF-RJP0U68tBL_D8yyDV4LgPMuEEfKTmtGpMJVNhokgQG2--PXxdgB_SCjHK28-kpR8KPJhGMIkdcS1oyqzLnXPHN-NbWhRgNf_r-uyAdIlN93b3skJya79MLKV4VmKEeIY_yAdbckWZA',
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
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildTitleSection(),
                  const SizedBox(height: 40),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: collection.length + 1,
                    itemBuilder: (context, index) {
                      if (index == collection.length) {
                        return _buildCreateNewCollectionCard();
                      }
                      return _buildCollectionCard(collection[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.menu, color: Colors.black),
        Text(
          'Ethereal Estate',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
        ),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAhQK06rmownw5M31tV-8qMt710OBh3GReJCGT7j4VXICHgn2JXPIn-5hqJ3Pvw2LQDVkr-ozCeSjmTJsI_cLRqvJr2aa5W0_Hsg43ZnfYWLAIBBDPGxtyLikTqdCNex2hw3x9XpORF5zMmJsNmS_aVQ1ucNgVsZEmE9dy0rECbwAsRUNMv-bimH38P5OEBcZ_ywh5In1KKwcXwVP9ZFqsbbKRcXlQVaRukBO0iptBeYsdr3hqx6mqPzgtfvn67nTY-nBbtsyKG84k'),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEMBER COLLECTION',
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            color: const Color(0xFF4C54B6),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Collection',
              style: GoogleFonts.manrope(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1.5),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
              child: const Icon(Icons.filter_list, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectionCard(CollectionItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    Image.network(item.imageUrl, width: double.infinity, fit: BoxFit.cover),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite, color: Colors.white, size: 16),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(100)),
                            child: Text(item.price, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(item.location, style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeature(Icons.king_bed_outlined, item.beds),
                    _buildFeature(Icons.bathtub_outlined, item.baths),
                    _buildFeature(Icons.straighten, '${item.sqft} sqft'),
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
        Icon(icon, size: 16, color: const Color(0xFF4C54B6)),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }

  Widget _buildCreateNewCollectionCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4C54B6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF4C54B6).withOpacity(0.1), style: BorderStyle.none),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Color(0xFF4C54B6), size: 32),
          ),
          const SizedBox(height: 24),
          Text('Create New Collection', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Organize your dream homes into custom lists.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _GradientSphere(color: const Color(0xFFF3F4F5))),
        Positioned(top: 0, right: 0, child: _GradientSphere(color: const Color(0xFFE0E0FF).withOpacity(0.5))),
        Positioned(bottom: 0, right: 0, child: _GradientSphere(color: const Color(0xFFF8F9FA))),
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
