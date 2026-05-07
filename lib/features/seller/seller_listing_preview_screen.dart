import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/local_database_service.dart';

// ─── Primary Screen ────────────────────────────────────────────────────────────

class SellerListingPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> listing;

  const SellerListingPreviewScreen({super.key, required this.listing});

  static const _brand = Color(0xFF4C54B6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildCoverImage(context),
                  _buildContent(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Background spheres ────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Stack(children: [
      Positioned(
        top: 0,
        left: 0,
        child: _Sphere(color: const Color(0xFFE0E0FF).withValues(alpha: 0.45)),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: _Sphere(color: const Color(0xFF8F98FE).withValues(alpha: 0.2)),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: _Sphere(color: const Color(0xFFF3F4F5)),
      ),
    ]);
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Listing Preview',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _brand.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'PREVIEW',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: _brand,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Cover image section ───────────────────────────────────────────────────

  Widget _buildCoverImage(BuildContext context) {
    final imageUrl = listing['imageUrl'] as String? ?? '';
    final status = (listing['status'] as String? ?? 'available').toLowerCase();
    final imagePaths = listing['image_paths'] as String? ?? '';
    final extraCount = _parseImageCount(imagePaths);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 240,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImageWidget(imageUrl),
              // Subtle bottom gradient for badge readability
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.38),
                      ],
                    ),
                  ),
                ),
              ),
              // Status badge — bottom left
              Positioned(
                bottom: 14,
                left: 16,
                child: _buildStatusBadge(status),
              ),
              // Photo count badge — bottom right (only if multiple images)
              if (extraCount > 1)
                Positioned(
                  bottom: 14,
                  right: 16,
                  child: _buildPhotoBadge(extraCount),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final category = listing['category'] as String? ?? 'Property';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _brand.withValues(alpha: 0.15),
            _brand.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Text(
          category.isNotEmpty ? category[0].toUpperCase() : 'P',
          style: GoogleFonts.manrope(
            fontSize: 96,
            fontWeight: FontWeight.w900,
            color: _brand.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isAvailable = status != 'sold';
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: (isAvailable ? Colors.green : Colors.red).withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isAvailable ? Colors.green : Colors.red).withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            isAvailable ? 'AVAILABLE' : 'SOLD',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isAvailable ? Colors.green.shade200 : Colors.red.shade200,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoBadge(int count) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_outlined, size: 13, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                '$count photos',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Content below image ───────────────────────────────────────────────────

  Widget _buildContent(BuildContext context) {
    final title = listing['title'] as String? ?? 'Untitled Property';
    final location = listing['location'] as String? ?? '';
    final price = listing['price'] as String? ?? '';
    final beds = listing['beds'] as String? ?? '--';
    final baths = listing['baths'] as String? ?? '--';
    final sqft = listing['sqft'] as String? ?? '--';
    final category = listing['category'] as String? ?? 'Property';
    final description = listing['description'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chip
          _buildCategoryChip(category),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Location row
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.black54),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Price
          Text(
            price,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _brand,
            ),
          ),
          const SizedBox(height: 20),

          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 20),

          // Specs row
          _buildSpecsRow(beds, baths, sqft),
          const SizedBox(height: 24),

          // Description
          if (description.trim().isNotEmpty) ...[
            _buildDescriptionSection(description),
            const SizedBox(height: 24),
          ],

          // Share button
          _buildShareButton(context, title, location, price, beds, baths, sqft),
          const SizedBox(height: 14),

          // Book Site Visit button
          _buildBookButton(context),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _brand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSpecsRow(String beds, String baths, String sqft) {
    return Row(
      children: [
        Expanded(child: _SpecTile(icon: Icons.bed_outlined, value: beds, label: 'Bedrooms')),
        const SizedBox(width: 10),
        Expanded(child: _SpecTile(icon: Icons.bathtub_outlined, value: baths, label: 'Baths')),
        const SizedBox(width: 10),
        Expanded(child: _SpecTile(icon: Icons.square_foot_outlined, value: sqft, label: 'Sqft')),
      ],
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ABOUT THIS PROPERTY',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.black45,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.black54,
            height: 1.75,
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton(
    BuildContext context,
    String title,
    String location,
    String price,
    String beds,
    String baths,
    String sqft,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _showShareDialog(context, title, location, price, beds, baths, sqft),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _brand.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          foregroundColor: _brand,
        ),
        icon: const Icon(Icons.share_outlined, size: 18),
        label: Text(
          'Share as Text',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _openBookingSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          'BOOK SITE VISIT',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void _openBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(listing: listing),
    );
  }

  void _showShareDialog(
    BuildContext context,
    String title,
    String location,
    String price,
    String beds,
    String baths,
    String sqft,
  ) {
    final text =
        '$title\n'
        'Location: $location\n'
        'Price: $price\n'
        'Bedrooms: $beds  |  Baths: $baths  |  Sqft: $sqft\n\n'
        'Listed on Ethereal Estate.';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Text(
          'Share Listing',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _brand.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _brand.withValues(alpha: 0.12)),
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: GoogleFonts.inter(color: Colors.black45, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Copied to clipboard.',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.copy, size: 16),
            label: Text('Copy', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  int _parseImageCount(String rawPaths) {
    if (rawPaths.trim().isEmpty) return 0;
    return rawPaths.split(',').where((p) => p.trim().isNotEmpty).length;
  }
}

// ─── Spec Tile ─────────────────────────────────────────────────────────────────

class _SpecTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SpecTile({required this.icon, required this.value, required this.label});

  static const _brand = Color(0xFF4C54B6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _brand, size: 22),
          const SizedBox(height: 7),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ─── Booking Bottom Sheet ──────────────────────────────────────────────────────

class _BookingSheet extends StatefulWidget {
  final Map<String, dynamic> listing;

  const _BookingSheet({required this.listing});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  static const _brand = Color(0xFF4C54B6);

  // Next 7 days (starting tomorrow)
  late final List<DateTime> _dates;
  late DateTime _selectedDate;
  String? _selectedSlot;
  bool _isConfirming = false;

  final List<String> _timeSlots = ['10:00 AM', '02:00 PM', '06:00 PM'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates = List.generate(7, (i) => now.add(Duration(days: i + 1)));
    _selectedDate = _dates.first;
  }

  // ─── Confirm booking ───────────────────────────────────────────────────────

  Future<void> _confirmBooking() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a time slot.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isConfirming = true);

    final dateString =
        '${_selectedDate.year}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.day.toString().padLeft(2, '0')}';

    final booking = {
      'id': '${widget.listing['id'] ?? 'listing'}_${DateTime.now().millisecondsSinceEpoch}',
      'propertyId': widget.listing['id'] ?? '',
      'propertyTitle': widget.listing['title'] ?? 'Untitled',
      'date': dateString,
      'timeSlot': _selectedSlot!,
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    try {
      await LocalDatabaseService().saveBooking(booking);
    } finally {
      if (mounted) {
        setState(() => _isConfirming = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking confirmed! The seller will contact you.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDragHandle(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSheetTitle(),
                          const SizedBox(height: 24),
                          _buildDateSection(),
                          const SizedBox(height: 24),
                          _buildTimeSection(),
                          const SizedBox(height: 32),
                          _buildConfirmButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetTitle() {
    return Text(
      'Book Site Visit',
      style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT DATE',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.black45,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            separatorBuilder: (context, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _buildDateChip(_dates[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip(DateTime date) {
    final isSelected = date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[(date.weekday - 1) % 7];

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 58,
        decoration: BoxDecoration(
          color: isSelected ? _brand : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _brand : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.black45,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT TIME SLOT',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.black45,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: _timeSlots.map((slot) {
            final isSelected = _selectedSlot == slot;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: slot == _timeSlots.last ? 0 : 10,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSlot = slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? _brand : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? _brand : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        slot,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isConfirming ? null : _confirmBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black54,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: _isConfirming
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'CONFIRM BOOKING',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

// ─── Background Sphere ─────────────────────────────────────────────────────────

class _Sphere extends StatelessWidget {
  final Color color;
  const _Sphere({required this.color});

  @override
  Widget build(BuildContext context) => Container(
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
