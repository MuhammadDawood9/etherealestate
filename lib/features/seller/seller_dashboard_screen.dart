import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/local_database_service.dart';
import '../../core/services/auth_service.dart';
import 'add_property_screen.dart';
import 'seller_listing_preview_screen.dart';
import 'seller_profile_sheet.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _db = LocalDatabaseService();
  final _auth = AuthService();
  late final TabController _tabController;

  List<Map<String, dynamic>> _listings = [];
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final uid = _auth.currentUser?.uid ?? '';
    final listings = await _db.getSellerListings(uid);
    final bookings = await _db.getSellerBookings(uid);
    if (mounted) setState(() { _listings = listings; _bookings = bookings; _loading = false; });
  }

  Future<void> _navigateToAdd() async {
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
    if (result == true) _loadData();
  }

  Future<void> _navigateToEdit(Map<String, dynamic> listing) async {
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => AddPropertyScreen(existingListing: listing)));
    if (result == true) _loadData();
  }

  Future<void> _toggleStatus(String id, String current) async {
    final next = current == 'sold' ? 'available' : 'sold';
    await _db.setListingStatus(id, next);
    _loadData();
  }

  Future<void> _deleteListing(String id) async {
    await _db.deleteSellerListing(id);
    _loadData();
  }

  Future<void> _logout() async {
    await _db.setPreference('user_role', 'buyer');
    await _auth.signOut();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _openProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SellerProfileSheet(),
    );
  }

  int get _activeCount => _listings.where((l) => (l['status'] ?? 'available') == 'available').length;
  int get _soldCount   => _listings.where((l) => l['status'] == 'sold').length;

  @override
  Widget build(BuildContext context) {
    final userName = _auth.currentUser?.displayName ?? 'Seller';
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(userName),
                const SizedBox(height: 20),
                _buildStats(),
                const SizedBox(height: 16),
                _buildTabBar(),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF4C54B6)))
                      : TabBarView(
                          controller: _tabController,
                          children: [_buildListingsTab(), _buildBookingsTab()],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _tabController.index == 0
              ? FloatingActionButton.extended(
                  key: const ValueKey('fab'),
                  onPressed: _navigateToAdd,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: Text('Add Property', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Seller Portal', style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -1)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF4C54B6).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text('SELLER', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF4C54B6), letterSpacing: 1.5)),
              ),
            ]),
            Text('Welcome back, $name', style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
          ]),
        ),
        GestureDetector(
          onTap: _openProfile,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF4C54B6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person_outline, color: Color(0xFF4C54B6), size: 20),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          onSelected: (v) { if (v == 'logout') _logout(); },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'logout',
              child: Row(children: [
                const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                const SizedBox(width: 10),
                Text('Sign Out', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.more_vert, size: 20, color: Colors.black54),
          ),
        ),
      ]),
    );
  }

  // ─── Stats ───────────────────────────────────────────────────────────────────

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Row(children: [
              _StatChip(icon: Icons.home_outlined,       label: 'Total',     value: '${_listings.length}', color: const Color(0xFF4C54B6)),
              _Divider(),
              _StatChip(icon: Icons.check_circle_outline, label: 'Active',    value: '$_activeCount',       color: const Color(0xFF2E7D5E)),
              _Divider(),
              _StatChip(icon: Icons.sell_outlined,        label: 'Sold',      value: '$_soldCount',         color: Colors.orange),
              _Divider(),
              _StatChip(icon: Icons.calendar_today_outlined, label: 'Bookings', value: '${_bookings.length}', color: Colors.purple),
            ]),
          ),
        ),
      ),
    );
  }

  // ─── Tab Bar ─────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14)),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)]),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black38,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: [
            Tab(text: 'My Listings  (${_listings.length})'),
            Tab(text: 'Bookings  (${_bookings.length})'),
          ],
        ),
      ),
    );
  }

  // ─── Listings Tab ─────────────────────────────────────────────────────────────

  Widget _buildListingsTab() {
    if (_listings.isEmpty) return _buildEmptyState(Icons.home_work_outlined, 'No listings yet', 'Tap the button below to\nadd your first property');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      itemCount: _listings.length,
      itemBuilder: (_, i) {
        final l = _listings[i];
        return _ListingCard(
          listing: l,
          onEdit:         () => _navigateToEdit(l),
          onPreview:      () => Navigator.push(context, MaterialPageRoute(builder: (_) => SellerListingPreviewScreen(listing: l))),
          onToggleStatus: () => _toggleStatus(l['id'] as String, l['status'] as String? ?? 'available'),
          onDelete:       () => _confirmDelete(l['id'] as String),
        );
      },
    );
  }

  // ─── Bookings Tab ─────────────────────────────────────────────────────────────

  Widget _buildBookingsTab() {
    if (_bookings.isEmpty) return _buildEmptyState(Icons.calendar_today_outlined, 'No booking requests', 'Booking requests from buyers\nwill appear here');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      itemCount: _bookings.length,
      itemBuilder: (_, i) => _BookingCard(booking: _bookings[i]),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: const Color(0xFF4C54B6).withValues(alpha: 0.08), shape: BoxShape.circle),
          child: Icon(icon, size: 52, color: const Color(0xFF4C54B6)),
        ),
        const SizedBox(height: 24),
        Text(title, style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: Colors.black45, height: 1.6)),
      ]),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Listing?', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        content: Text('This listing will be permanently removed.', style: GoogleFonts.inter(color: Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.black45, fontWeight: FontWeight.w600))),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _deleteListing(id); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: Text('Delete', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(children: [
      Positioned(top: 0, left: 0,      child: _Sphere(color: const Color(0xFFE0E0FF).withValues(alpha: 0.45))),
      Positioned(top: 0, right: 0,     child: _Sphere(color: const Color(0xFF8F98FE).withValues(alpha: 0.2))),
      Positioned(bottom: 0, left: 0, right: 0, child: _Sphere(color: const Color(0xFFF3F4F5))),
    ]);
  }
}

// ─── Listing Card ─────────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onEdit, onPreview, onToggleStatus, onDelete;
  const _ListingCard({required this.listing, required this.onEdit, required this.onPreview, required this.onToggleStatus, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final category   = listing['category']   as String? ?? 'Property';
    final title      = listing['title']      as String? ?? 'Untitled';
    final location   = listing['location']   as String? ?? '';
    final price      = listing['price']      as String? ?? '';
    final beds       = listing['beds']       as String? ?? '--';
    final baths      = listing['baths']      as String? ?? '--';
    final sqft       = listing['sqft']       as String? ?? '--';
    final status     = listing['status']     as String? ?? 'available';
    final isSold     = status == 'sold';
    final photoCount = (listing['image_paths'] as String? ?? '').split(',').where((s) => s.isNotEmpty).length;

    return Opacity(
      opacity: isSold ? 0.72 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isSold ? Colors.orange.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Top row: thumbnail + info + actions
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildThumbnail(listing['imageUrl'] as String? ?? '', category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.black38),
                    const SizedBox(width: 2),
                    Expanded(child: Text(location, style: GoogleFonts.inter(fontSize: 12, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 4),
                  Text(price, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF4C54B6))),
                ]),
              ),
              // Action buttons
              Column(children: [
                _iconBtn(Icons.edit_outlined, Colors.black54, onEdit),
                const SizedBox(height: 6),
                _iconBtn(Icons.visibility_outlined, const Color(0xFF4C54B6), onPreview),
                const SizedBox(height: 6),
                _iconBtn(Icons.delete_outline, Colors.redAccent, onDelete),
              ]),
            ]),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 12),

            // Bottom row: specs + photo count + status badge
            Row(children: [
              _Spec(icon: Icons.bed_outlined,        value: '$beds Bed'),
              const SizedBox(width: 12),
              _Spec(icon: Icons.bathtub_outlined,    value: '$baths Bath'),
              const SizedBox(width: 12),
              _Spec(icon: Icons.square_foot_outlined, value: sqft),
              const Spacer(),
              if (photoCount > 0) ...[
                Row(children: [
                  const Icon(Icons.photo_library_outlined, size: 13, color: Colors.black38),
                  const SizedBox(width: 3),
                  Text('$photoCount', style: GoogleFonts.inter(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: onToggleStatus,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSold ? Colors.orange.withValues(alpha: 0.12) : const Color(0xFF2E7D5E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSold ? Colors.orange.withValues(alpha: 0.3) : const Color(0xFF2E7D5E).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    isSold ? 'SOLD' : 'AVAILABLE',
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: isSold ? Colors.orange : const Color(0xFF2E7D5E), letterSpacing: 0.8),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

Widget _buildThumbnail(String imageUrl, String category) {
  final hasLocal   = imageUrl.isNotEmpty && !imageUrl.startsWith('http') && File(imageUrl).existsSync();
  final hasNetwork = imageUrl.startsWith('http');
  if (hasLocal || hasNetwork) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 56, height: 56,
        child: hasLocal
            ? Image.file(File(imageUrl), fit: BoxFit.cover)
            : Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (context, e, s) => _categoryBox(category)),
      ),
    );
  }
  return _categoryBox(category);
}

Widget _categoryBox(String category) {
  return Container(
    width: 56, height: 56,
    decoration: BoxDecoration(color: const Color(0xFF4C54B6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
    child: Center(child: Text(category.isNotEmpty ? category[0] : 'P', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF4C54B6)))),
  );
}

// ─── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final title    = booking['propertyTitle'] as String? ?? 'Unknown Property';
    final date     = booking['date']          as String? ?? '';
    final timeSlot = booking['timeSlot']      as String? ?? '';
    final status   = booking['status']        as String? ?? 'pending';

    final statusColor = switch (status) {
      'confirmed'  => const Color(0xFF2E7D5E),
      'cancelled'  => Colors.redAccent,
      _            => const Color(0xFF4C54B6),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.calendar_today_outlined, color: statusColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text('$date  •  $timeSlot', style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.8)),
        ),
      ]),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 10, color: Colors.black38),
          const SizedBox(width: 3),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.black45)),
        ]),
      ]),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: Colors.black.withValues(alpha: 0.07), margin: const EdgeInsets.symmetric(horizontal: 4));
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String value;
  const _Spec({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 13, color: Colors.black38),
    const SizedBox(width: 3),
    Text(value, style: GoogleFonts.inter(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500)),
  ]);
}

class _Sphere extends StatelessWidget {
  final Color color;
  const _Sphere({required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: 600, height: 600,
    decoration: BoxDecoration(gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)], radius: 0.8)),
  );
}
