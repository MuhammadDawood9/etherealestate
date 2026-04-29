import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';

final isAdminProvider = StreamProvider<bool>((ref) {
  return AdminService().isAdminStream();
});

final adminStatsProvider =
    FutureProvider<({int properties, int bookings, int upcoming})>((ref) {
  return AdminService().getStats();
});

final adminPropertiesProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return AdminService().propertiesStream();
});

final adminBookingsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return AdminService().allBookingsStream();
});
