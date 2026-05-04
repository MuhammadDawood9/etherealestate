import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_routes.dart';
import '../../core/models/filter_criteria.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/property_repository.dart';
import '../../core/services/local_database_service.dart';
import '../../core/utils/fade_scale_route.dart';
import '../../shared/user_avatar.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/app_menu_sheet.dart';
import '../../shared/widgets/gradient_sphere.dart';
import '../../shared/widgets/shimmer_box.dart';
import '../property/property_details_screen.dart';
import 'search_filter_screen.dart';

class SearchHomeScreen extends ConsumerStatefulWidget {
  const SearchHomeScreen({super.key});

  @override
  ConsumerState<SearchHomeScreen> createState() => _SearchHomeScreenState();
}

class _SearchHomeScreenState extends ConsumerState<SearchHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<String> _searchHistory = [];
  bool _showHistory = false;

  final _db = LocalDatabaseService();

@override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(currentUserProvider);
      ref.read(userProfileProvider.notifier).loadFromUser(user);
      final history = await _db.getSearchHistory();
      if (mounted) {
        setState(() {
          _searchHistory = history;
          _showHistory = history.isNotEmpty;
        });
      }
    });
  }

  void _onFocusChange() {
    setState(() {});
  }

  Future<void> _loadHistory() async {
    final history = await _db.getSearchHistory();
    if (mounted) {
      setState(() {
        _searchHistory = history;
        _showHistory = history.isNotEmpty;
      });
    }
  }

  String _greeting() {
    final profile = ref.watch(userProfileProvider);
    if (profile.displayName.isNotEmpty && profile.displayName != 'Guest') {
      return profile.displayName.split(' ').first;
    }
    final user = ref.watch(currentUserProvider);
    if (user?.email != null) {
      return user!.email!.split('@').first;
    }
    return 'Guest';
  }

  void _onQueryChanged(String query) {
    ref.read(activeFilterProvider.notifier).update((state) => state.copyWith(query: query));
    if (query.isNotEmpty) {
      setState(() => _showHistory = false);
    }
  }

  Future<FilterCriteria> _loadPreferenceDefaults() async {
    final type     = await _db.getPreference('pref_property_type');
    final bedsStr  = await _db.getPreference('pref_bedrooms');
    final minStr   = await _db.getPreference('pref_budget_min');
    final maxStr   = await _db.getPreference('pref_budget_max');

    int? beds;
    if (bedsStr != null && bedsStr != 'Any') {
      beds = int.tryParse(bedsStr.replaceAll('+', ''));
    }

    return FilterCriteria(
      propertyType: type,
      minBeds: beds,
      minPrice: double.tryParse(minStr ?? ''),
      maxPrice: double.tryParse(maxStr ?? ''),
    );
  }

  Future<void> _showFilterSheet() async {
    var currentFilter = ref.read(activeFilterProvider);

    // Pre-populate from saved preferences only when no explicit filter is active
    if (currentFilter.isDefault) {
      currentFilter = await _loadPreferenceDefaults();
    }

    if (!mounted) return;

    final result = await showModalBottomSheet<FilterCriteria>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchFilterScreen(initial: currentFilter),
    );

    if (result != null) {
      ref.read(activeFilterProvider.notifier).state = result;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(activeFilterProvider.notifier).state = FilterCriteria.defaults;
    setState(() => _showHistory = false);
  }

  void _applyHistoryQuery(String query) {
    _searchController.text = query;
    _onQueryChanged(query);
    _searchFocus.unfocus();
    setState(() => _showHistory = false);
  }

  void _openDetails(PropertyModel p) {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _db.saveSearchQuery(query);
    }
    _searchFocus.unfocus();
    setState(() => _showHistory = false);
    Navigator.push(context, FadeScaleRoute(page: PropertyDetailsScreen(propertyId: p.id)));
  }

  Future<void> _deleteHistoryItem(String query) async {
    await _db.deleteSearchQuery(query);
    await _loadHistory();
  }

  @override
  void dispose() {
    _searchFocus.removeListener(_onFocusChange);
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = ref.watch(activeFilterProvider);
    final filteredResults = ref.watch(filteredPropertiesProvider);
    final isSearching = activeFilter.query.isNotEmpty || !activeFilter.isDefault;

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
                  _buildHeroSection(activeFilter, isSearching),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: isSearching
                        ? _buildSearchResults(filteredResults, activeFilter)
                        : Column(
                      key: const ValueKey('featured'),
                      children: [
                        _buildFeaturedCurations(),
                        const SizedBox(height: 48),
                        _buildCollections(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
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
                onPressed: () => showAppMenu(context),
                icon: const Icon(Icons.menu, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Text(
                'Ethereal Estate',
                style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.profile),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                image: DecorationImage(
                  image: userAvatarImage(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(FilterCriteria activeFilter, bool isSearching) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${_greeting()}',
            style: GoogleFonts.manrope(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: -1),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: _onQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Find your sanctuary...',
                    hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 18),
                    prefixIcon: const Icon(Icons.search, color: Colors.black38, size: 28),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSearching)
                          IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: _clearSearch,
                          ),
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            IconButton(
                              tooltip: 'Filter',
                              icon: const Icon(Icons.tune, color: Colors.black38),
                              onPressed: _showFilterSheet,
                            ),
                            if (!activeFilter.isDefault)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF4C54B6), shape: BoxShape.circle),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  ),
                ),
              ),
              if (_showHistory) _buildHistoryDropdown(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            child: Text(
              'RECENT SEARCHES',
              style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.black38),
            ),
          ),
          ..._searchHistory.take(5).map((query) => InkWell(
            onTap: () => _applyHistoryQuery(query),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 16, color: Colors.black38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      query,
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _deleteHistoryItem(query),
                    child: const Icon(Icons.close, size: 14, color: Colors.black26),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<PropertyModel> results, FilterCriteria activeFilter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${results.length} result${results.length == 1 ? '' : 's'}',
                style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (!activeFilter.isDefault) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C54B6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Filtered',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4C54B6))),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.black.withValues(alpha: 0.15)),
                    const SizedBox(height: 16),
                    Text('No properties match your criteria',
                        style: GoogleFonts.inter(fontSize: 15, color: Colors.black45)),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              itemBuilder: (context, index) => _buildResultCard(results[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildResultCard(PropertyModel p) {
    return GestureDetector(
      onTap: () => _openDetails(p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: p.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                memCacheWidth: 160,
                errorWidget: (context, url, err) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.black.withValues(alpha: 0.05),
                  child: const Icon(Icons.image_not_supported_outlined,
                      size: 24, color: Colors.black26),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    p.location,
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.price,
                        style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700, color: const Color(0xFF4C54B6), fontSize: 14),
                      ),
                      Text(
                        '${p.beds}bd · ${p.baths}ba',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.black38),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final isSaved = ref.watch(isPropertySavedProvider(p.id));
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey<bool>(isSaved),
                      color: isSaved ? Colors.redAccent : Colors.black26,
                      size: 24,
                    ),
                  ),
                  onPressed: () {
                    ref.read(savedPropertiesProvider.notifier).toggleSave(p);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCurations() {
    final featuredAsync = ref.watch(featuredPropertiesProvider);
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
                  Text('THE SELECTION',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4C54B6),
                          letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text('Featured Curations',
                      style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.feed),
                child: Text('Explore All',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: const Color(0xFF4C54B6))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 500,
          child: featuredAsync.when(
            loading: _buildFeaturedShimmer,
            error: (error, _) => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: _buildFeaturedItems(PropertyRepository.featured),
            ),
            data: (items) => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: _buildFeaturedItems(items),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeaturedItems(List<PropertyModel> items) {
    if (items.isEmpty) return [];
    final result = <Widget>[_buildLargeCard(items[0])];
    for (var i = 1; i < items.length; i += 2) {
      result.add(const SizedBox(width: 20));
      result.add(Column(
        children: [
          _buildSmallCard(items[i]),
          if (i + 1 < items.length) ...[
            const SizedBox(height: 20),
            _buildSmallCard(items[i + 1]),
          ],
        ],
      ));
    }
    return result;
  }

  Widget _buildFeaturedShimmer() {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: const ShimmerBox(width: 300),
        ),
        const SizedBox(width: 20),
        Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: const ShimmerBox(width: 200, height: 240),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: const ShimmerBox(width: 200, height: 240),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeCard(PropertyModel p) {
    return GestureDetector(
      onTap: () => _openDetails(p),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: DecorationImage(
              image: CachedNetworkImageProvider(p.imageUrl, maxWidth: 600),
              fit: BoxFit.cover,
              onError: (exception, _) {}),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.title,
                  style: GoogleFonts.manrope(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('${p.location} • ${p.price}',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCard(PropertyModel p) {
    return GestureDetector(
      onTap: () => _openDetails(p),
      child: Container(
        width: 200,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: DecorationImage(
              image: CachedNetworkImageProvider(p.imageUrl, maxWidth: 400),
              fit: BoxFit.cover,
              onError: (exception, _) {}),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.title,
                  style: GoogleFonts.manrope(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(p.location, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollections() {
    final collections = [
      ('House', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBa5Yc7aR-hYidl4HiUQCy34uEy1ezgRYF-7vwpDu9xpFbJMYH9rIzQbTu4BlegEFyT7uKn2rjJ7X5ENIKwsEpI57y5E05ZUj8xfzXQkvEmmvqzUaYp-S6iscqKp8JWyKx5pUafkoNrU-_Y2WN7iF-GdneZyE1TxiYoFwI5S9EtTBNcq_hG_WtwRNNlcsegK_faRJF0ch29RHSc8sF3674yJKhWmxd7JKY4W1AW1HwE6XF6P1I_XlnK1q_5gfe0VQPbTpvttdA_1xY'),
      ('Flat', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBubJmwvT2RLA3e9RrJ8aSRwJyrLfsFB0ol20stTeGLnYf6H9U6GhPwQaf-6WOBgqq2ZPJSQ2l9r4emZQ6dsiE29o6a3gf7hB45TwHckiA2QguXDQrSNjFqnIQV053Cp2RgQkro20yMWrShRPZYW73NtAU_91OTvR5uJfHBJzsjHFk8UWUr0RgOol2fSVbSclcVOIgJARGhDQWBjDjxm3a_UtrDqRcSOtUBH-ZFvY1-zLFpO5ElkBGDllcV3_lc4s_YrHcChVPB6Bs'),
      ('Upper Portion', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAO-D3eUqulQKrJM2KeaELhiit31ELOWV8N_RNNW-VraCJTOppoIvIHrrNCsiPm7g70U8bPW8j48KbC35BikiqFTV6RZPe1PY0c9R0fd8Zw6P3vEr-bNrrGuVPgYsWOB_INR1xonheIUMRsHaiP5SFrs6dHGo-MvcwugXeCIYgtTClz3ScapYz3a31GdCNfTNdxIQWXwm8uls1HokdE21pZ_f4vSlT9RCYzKe187Mm4xHuLTPPzM5BNo4aCVNuWEVEEdkx4zJsADfg'),
      ('Lower Portion', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCcSf-0uZVQwFou2pODTKXM_jyDtAvJ3WpWASARY3699r8IVxfn-0QQg2F-wHwTRs956k_5ESoCOFlcDH2Vw_2wh3qObvXJUvfk2kfQymvoDjqGfAKe8AyJxMmkxdxX4Lg_TH2uUproIHxqGRxlj1oA_rIQdBJsogk4_q6mSnp71rL4WzMVXQaptT4fCObPiyhneX1lHWOz4tLzY6Vuhmvh5ezt8PURwlpHflnEGZRDhHI_aNvV3Ov2fRGzL81yHvRn90wnicaQpVQ'),
      ('Farm House', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAYKHWpnUHSl9OfQ2TFLFtbNeNazdZqZb4oVBdS8R6IUrXZcFczjqHBob8zK_S3vWJER1F3QmXaE5sCap-gyXAQb5Kfr6hgOAQSHzWtRw03fLN0-iecX2lSPa_hTLGkbZIKGzpOSBmV_vFAFIQ4nQdSyptmvSctaIQwT1fTva4M5elcW9a9KYnJHDvXA9wZwqZVLcViftHazQX7lYlq0n6BywjsVcPQOA_61zzLYmKudg6sOnadCBUtNMBpglZjNm2HRblDPqZjQlE'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child:
          Text('Collections', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: collections.map((c) => _buildCollectionItem(c.$1, c.$2)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionItem(String title, String imageUrl) {
    return GestureDetector(
      onTap: () {
        _searchController.text = title;
        ref.read(activeFilterProvider.notifier).update((state) => state.copyWith(propertyType: title, query: ''));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: DecorationImage(
              image: CachedNetworkImageProvider(imageUrl, maxWidth: 280),
              fit: BoxFit.cover,
              onError: (exception, _) {}),
        ),
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: Text(title,
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(
            top: 0,
            left: 0,
            child: RepaintBoundary(child: GradientSphere(color: const Color(0xFFF8F9FA)))),
        Positioned(
            top: 0,
            right: 0,
            child: RepaintBoundary(child: GradientSphere(color: const Color(0xFFE0E0FF)))),
        Positioned(
            bottom: 0,
            right: 0,
            child: RepaintBoundary(child: GradientSphere(color: const Color(0xFFF3F4F5)))),
        Positioned(
            bottom: 0,
            left: 0,
            child: RepaintBoundary(child: GradientSphere(color: const Color(0xFFDEE2ED)))),
      ],
    );
  }
}