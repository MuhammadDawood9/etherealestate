import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class Property {
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final String category;

  Property({
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}

class SearchHomeScreen extends StatefulWidget {
  const SearchHomeScreen({super.key});

  @override
  State<SearchHomeScreen> createState() => _SearchHomeScreenState();
}

class _SearchHomeScreenState extends State<SearchHomeScreen> {
  final List<Property> _allProperties = [
    Property(
      title: 'The Glass Obsidian',
      location: 'Beverly Hills, CA',
      price: '\$12,500,000',
      category: 'Penthouse',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAM-4wF3AdS430cLzThNWK4V9ZTaCHddu8UzuBY9_bBthT4kfXLOTWxUF4NPAV6M0c9qI-ENDJJRr3M7W6HWhqq8MK86EYuGrY5q1mIxfkUwuI04LprqHG0WndlIFEOpjCmj0zo9mHnxfkEkG1dDqSuSXo0bTbBK7iJnJPz1jWJYWuCqeJopHF8N8Krxp3i5xS1_Q9EBZREK2QdhMLAbc4jxZwESilEWc84AppYkGmp9T8IOi6kSvDG2NMfsHI0_pcgF1v2ysqbxhk',
    ),
    Property(
      title: 'Azure Cove',
      location: 'Malibu, CA',
      price: '\$8,200,000',
      category: 'Coastal',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjUSjEKdi-U2h5q1TR0oYSt4H51v3uF1nONog5aJm4m5gf5amM5KayopGFLFPXfbFwtibQfcsoCstw3oqtfm5G1AXozpIfhCTt8uiHssaHC079ryDeYbnhAAYOGDCpnGf0xmU5glzpS2Kd7RjgGC-2ZfN7NFCAIfJCbE1RqaotXpbHTef_6UtoUhFE4nFSp-aeLwdXqDlHmB54ThbUGfb2Y2b86Buydhz7KoOl2ou4WT3d3PTgF4pREckV_5zRRktk7d090914Gdo',
    ),
    Property(
      title: 'Lunar Sanctuary',
      location: 'Joshua Tree, AZ',
      price: '\$4,500,000',
      category: 'Off-Grid',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCOMpgXxdVoUgZd07zA8xpN34sI-AdHlbnMA-Uy1wvX-KcNLYZh-ezal57jKZyM2qAkAViKWu6HO2cDfARSE7N7QUJiCd_EWiaWpEq7Z2sP-k8I5SG0CZeI9_52CFpIdQwvsENp3zIbAE0jqDYGDIKaPg0t_QwTmB_i4otkh16kAv6hq-o6hJmbq0MvG7Vhj8Wti5PjjVAXBujqEdrQm02tOXfJaojAxDDyyohTZ4JqR1_CZUuwYQ-YWymuLgb_eej7ggAaCYICaW8',
    ),
  ];

  List<Property> _filteredProperties = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredProperties = _allProperties;
  }

  void _filterProperties(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProperties = _allProperties;
        _isSearching = false;
      } else {
        _isSearching = true;
        _filteredProperties = _allProperties
            .where((p) =>
                p.title.toLowerCase().contains(query.toLowerCase()) ||
                p.location.toLowerCase().contains(query.toLowerCase()) ||
                p.category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

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
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildHeroSection(),
                  if (_isSearching) _buildSearchResults() else ...[
                    _buildFeaturedCurations(),
                    const SizedBox(height: 48),
                    _buildCollections(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results (${_filteredProperties.length})',
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredProperties.length,
            itemBuilder: (context, index) {
              final property = _filteredProperties[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(property.imageUrl),
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
                            property.title,
                            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            property.location,
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            property.price,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4C54B6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Text(
                'Ethereal Estate',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5)),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCdpRCk005ydvTYNhxqXV_Al-_DO2Jl0tTooALBZPKxYFHzqY6V6PYSOUwCOTd3qYiaKqbSjQSSZqf7Y_WQmZO1KJyOXDmfj-2F5PvyKMkfxdFiRYhxIPhkW9dCF0jtVea2GtMIM8zzagZhLOKjdnM4tLiCU-ml3A3a1lUitIz0FpaH8nPXTcyNLvdBAly3dEWbBQUv1GCzTNMAXv8HZw2ZLgL2XuvQfE6x4yxiZWw6PplA7A6Av0Li0ac-xP5LpGbYFO6Nh-S0pbw'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Julian',
            style: GoogleFonts.manrope(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProperties,
              decoration: InputDecoration(
                hintText: 'Find your sanctuary...',
                hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 18),
                prefixIcon: const Icon(Icons.search, color: Colors.black38, size: 28),
                suffixIcon: _isSearching ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    _filterProperties('');
                  },
                ) : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCurations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE SELECTION',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4C54B6),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Featured Curations',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Explore All',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4C54B6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 500,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildLargeCard(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAM-4wF3AdS430cLzThNWK4V9ZTaCHddu8UzuBY9_bBthT4kfXLOTWxUF4NPAV6M0c9qI-ENDJJRr3M7W6HWhqq8MK86EYuGrY5q1mIxfkUwuI04LprqHG0WndlIFEOpjCmj0zo9mHnxfkEkG1dDqSuSXo0bTbBK7iJnJPz1jWJYWuCqeJopHF8N8Krxp3i5xS1_Q9EBZREK2QdhMLAbc4jxZwESilEWc84AppYkGmp9T8IOi6kSvDG2NMfsHI0_pcgF1v2ysqbxhk',
                'The Glass Obsidian',
                'Beverly Hills, CA • \$12,500,000',
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  _buildSmallCard(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDjUSjEKdi-U2h5q1TR0oYSt4H51v3uF1nONog5aJm4m5gf5amM5KayopGFLFPXfbFwtibQfcsoCstw3oqtfm5G1AXozpIfhCTt8uiHssaHC079ryDeYbnhAAYOGDCpnGf0xmU5glzpS2Kd7RjgGC-2ZfN7NFCAIfJCbE1RqaotXpbHTef_6UtoUhFE4nFSp-aeLwdXqDlHmB54ThbUGfb2Y2b86Buydhz7KoOl2ou4WT3d3PTgF4pREckV_5zRRktk7d090914Gdo',
                    'Azure Cove',
                    'Malibu, CA',
                  ),
                  const SizedBox(height: 20),
                  _buildSmallCard(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCOMpgXxdVoUgZd07zA8xpN34sI-AdHlbnMA-Uy1wvX-KcNLYZh-ezal57jKZyM2qAkAViKWu6HO2cDfARSE7N7QUJiCd_EWiaWpEq7Z2sP-k8I5SG0CZeI9_52CFpIdQwvsENp3zIbAE0jqDYGDIKaPg0t_QwTmB_i4otkh16kAv6hq-o6hJmbq0MvG7Vhj8Wti5PjjVAXBujqEdrQm02tOXfJaojAxDDyyohTZ4JqR1_CZUuwYQ-YWymuLgb_eej7ggAaCYICaW8',
                    'Lunar Sanctuary',
                    'Joshua Tree, AZ',
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Collections',
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildCollectionItem('Penthouse', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBa5Yc7aR-hYidl4HiUQCy34uEy1ezgRYF-7vwpDu9xpFbJMYH9rIzQbTu4BlegEFyT7uKn2rjJ7X5ENIKwsEpI57y5E05ZUj8xfzXQkvEmmvqzUaYp-S6iscqKp8JWyKx5pUafkoNrU-_Y2WN7iF-GdneZyE1TxiYoFwI5S9EtTBNcq_hG_WtwRNNlcsegK_faRJF0ch29RHSc8sF3674yJKhWmxd7JKY4W1AW1HwE6XF6P1I_XlnK1q_5gfe0VQPbTpvttdA_1xY'),
              _buildCollectionItem('Lofts', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBubJmwvT2RLA3e9RrJ8aSRwJyrLfsFB0ol20stTeGLnYf6H9U6GhPwQaf-6WOBgqq2ZPJSQ2l9r4emZQ6dsiE29o6a3gf7hB45TwHckiA2QguXDQrSNjFqnIQV053Cp2RgQkro20yMWrShRPZYW73NtAU_91OTvR5uJfHBJzsjHFk8UWUr0RgOol2fSVbSclcVOIgJARGhDQWBjDjxm3a_UtrDqRcSOtUBH-ZFvY1-zLFpO5ElkBGDllcV3_lc4s_YrHcChVPB6Bs'),
              _buildCollectionItem('Off-Grid', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAO-D3eUqulQKrJM2KeaELhiit31ELOWV8N_RNNW-VraCJTOppoIvIHrrNCsiPm7g70U8bPW8j48KbC35BikiqFTV6RZPe1PY0c9R0fd8Zw6P3vEr-bNrrGuVPgYsWOB_INR1xonheIUMRsHaiP5SFrs6dHGo-MvcwugXeCIYgtTClz3ScapYz3a31GdCNfTNdxIQWXwm8uls1HokdE21pZ_f4vSlT9RCYzKe187Mm4xHuLTPPzM5BNo4aCVNuWEVEEdkx4zJsADfg'),
              _buildCollectionItem('Modern', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCcSf-0uZVQwFou2pODTKXM_jyDtAvJ3WpWASARY3699r8IVxfn-0QQg2F-wHwTRs956k_5ESoCOFlcDH2Vw_2wh3qObvXJUvfk2kfQymvoDjqGfAKe8AyJxMmkxdxX4Lg_TH2uUproIHxqGRxlj1oA_rIQdBJsogk4_q6mSnp71rL4WzMVXQaptT4fCObPiyhneX1lHWOz4tLzY6Vuhmvh5ezt8PURwlpHflnEGZRDhHI_aNvV3Ov2fRGzL81yHvRn90wnicaQpVQ'),
              _buildCollectionItem('Castles', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAYKHWpnUHSl9OfQ2TFLFtbNeNazdZqZb4oVBdS8R6IUrXZcFczjqHBob8zK_S3vWJER1F3QmXaE5sCap-gyXAQb5Kfr6hgOAQSHzWtRw03fLN0-iecX2lSPa_hTLGkbZIKGzpOSBmV_vFAFIQ4nQdSyptmvSctaIQwT1fTva4M5elcW9a9KYnJHDvXA9wZwqZVLcViftHazQX7lYlq0n6BywjsVcPQOA_61zzLYmKudg6sOnadCBUtNMBpglZjNm2HRblDPqZjQlE'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeCard(String imageUrl, String title, String subtitle) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.manrope(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(subtitle, style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard(String imageUrl, String title, String subtitle) {
    return Container(
      width: 200,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.manrope(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionItem(String title, String imageUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.black.withOpacity(0.3),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _GradientSphere(color: const Color(0xFFF8F9FA))),
        Positioned(top: 0, right: 0, child: _GradientSphere(color: const Color(0xFFE0E0FF))),
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
