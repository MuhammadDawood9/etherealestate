import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/admin_providers.dart';
import '../../core/services/admin_service.dart';
import '../../shared/widgets/shimmer_box.dart';

class AdminBookingsScreen extends ConsumerStatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  ConsumerState<AdminBookingsScreen> createState() =>
      _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends ConsumerState<AdminBookingsScreen> {
  int _tabIndex = 0; // 0=All, 1=Upcoming, 2=Past

  String get _today {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> all) {
    if (_tabIndex == 0) return all;
    final today = _today;
    if (_tabIndex == 1) {
      return all
          .where((b) => (b['date'] as String? ?? '').compareTo(today) >= 0)
          .toList();
    }
    return all
        .where((b) => (b['date'] as String? ?? '').compareTo(today) < 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(adminBookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF060E1E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: bookings.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: 5,
                  itemBuilder: (ctx, i) => const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: ShimmerBox(height: 90),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Failed to load bookings',
                      style: GoogleFonts.inter(color: Colors.redAccent)),
                ),
                data: (all) {
                  final list = _filter(all);
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 44, color: Colors.white12),
                          const SizedBox(height: 16),
                          Text(
                            'No bookings found.',
                            style: GoogleFonts.inter(color: Colors.white38),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    itemCount: list.length,
                    itemBuilder: (context, i) => _BookingCard(
                      data: list[i],
                      onCancel: () =>
                          _confirmCancel(context, list[i]['id'] as String),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        'All Bookings',
        style: GoogleFonts.manrope(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    const labels = ['All', 'Upcoming', 'Past'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = _tabIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _tabIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF7B84FF).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active
                      ? const Color(0xFF7B84FF).withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w400,
                  color: active
                      ? const Color(0xFF7B84FF)
                      : Colors.white38,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _confirmCancel(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Booking',
            style: GoogleFonts.manrope(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(
          'This will permanently remove this booking from Firestore.',
          style: GoogleFonts.inter(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep',
                style: GoogleFonts.inter(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AdminService().cancelBooking(id);
            },
            child: Text('Cancel Booking',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onCancel;

  const _BookingCard({required this.data, required this.onCancel});

  bool get _isUpcoming {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return (data['date'] as String? ?? '').compareTo(today) >= 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isUpcoming
              ? const Color(0xFF4ECDC4).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isUpcoming
                      ? const Color(0xFF4ECDC4).withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isUpcoming
                      ? Icons.event_available
                      : Icons.event_busy_outlined,
                  color: _isUpcoming
                      ? const Color(0xFF4ECDC4)
                      : Colors.white24,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['propertyTitle'] as String? ?? '—',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${data['date'] ?? ''} · ${data['timeSlot'] ?? ''}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              if (_isUpcoming)
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (data['userEmail'] != null) ...[
            const SizedBox(height: 10),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 14, color: Colors.white24),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data['userEmail'] as String? ?? 'Unknown user',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white38),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
