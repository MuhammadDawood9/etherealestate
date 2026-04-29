import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  static final AdminService _i = AdminService._();
  factory AdminService() => _i;
  AdminService._();

  final _db = FirebaseFirestore.instance;

  // ── Role ─────────────────────────────────────────────────────────────────────

  Stream<bool> isAdminStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(false);
    return _db
        .collection('admins')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ── Stats ─────────────────────────────────────────────────────────────────────

  Future<({int properties, int bookings, int upcoming})> getStats() async {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final results = await Future.wait([
      _db.collection('properties').count().get(),
      _db.collection('bookings').count().get(),
      _db
          .collection('bookings')
          .where('date', isGreaterThanOrEqualTo: todayStr)
          .count()
          .get(),
    ]);
    return (
      properties: results[0].count ?? 0,
      bookings: results[1].count ?? 0,
      upcoming: results[2].count ?? 0,
    );
  }

  // ── Properties ───────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> propertiesStream() {
    return _db.collection('properties').snapshots().map(
          (snap) =>
              snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  Future<void> saveProperty(Map<String, dynamic> data,
      {String? existingId}) async {
    final ref = existingId != null
        ? _db.collection('properties').doc(existingId)
        : _db.collection('properties').doc();
    final payload = {...data, 'id': ref.id};
    await ref.set(payload, SetOptions(merge: true));
  }

  Future<void> deleteProperty(String id) async {
    await _db.collection('properties').doc(id).delete();
  }

  // ── Bookings ─────────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> allBookingsStream() {
    return _db
        .collection('bookings')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> cancelBooking(String id) async {
    await _db.collection('bookings').doc(id).delete();
  }

  // Called from BookingCalendarScreen to dual-write to Firestore
  Future<void> writeBooking(Map<String, dynamic> data) async {
    await _db
        .collection('bookings')
        .doc(data['id'] as String)
        .set(data);
  }

  // ── Recent bookings for dashboard ────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> recentBookings({int limit = 5}) async {
    final snap = await _db
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}
