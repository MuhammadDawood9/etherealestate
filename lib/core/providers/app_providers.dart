import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../models/property_model.dart' show PropertyModel;
import '../models/filter_criteria.dart';
import '../repositories/property_repository.dart' show PropertyRepository;
import '../services/auth_service.dart';
import '../services/local_database_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).valueOrNull;
});

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfile {
  final String displayName;
  final String location;
  final String phone;

  const UserProfile({
    this.displayName = 'Guest',
    this.location = 'Lahore, Pakistan',
    this.phone = '',
  });

  UserProfile copyWith({String? displayName, String? location, String? phone}) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      location: location ?? this.location,
      phone: phone ?? this.phone,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile());

  void updateName(String name) {
    state = state.copyWith(displayName: name);
  }

  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void loadFromUser(User? user) {
    if (user == null) {
      state = const UserProfile();
      return;
    }
    state = UserProfile(
      displayName: user.displayName ?? user.email?.split('@').first ?? 'Guest',
      location: 'Lahore, Pakistan',
      phone: user.phoneNumber ?? '',
    );
  }
}

final bookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final maps = await LocalDatabaseService().getBookings();
  return maps.map(BookingModel.fromMap).toList();
});

final propertyByIdProvider =
FutureProvider.family<PropertyModel?, String>((ref, id) async {
  return PropertyRepository.fetchById(id);
});

final feedPropertiesProvider = FutureProvider<List<PropertyModel>>((ref) async {
  return PropertyRepository.fetchFeed(location: 'Lahore');
});

final featuredPropertiesProvider = FutureProvider<List<PropertyModel>>((ref) async {
  return PropertyRepository.fetchFeatured();
});

// ==========================================
// PREMIUM SEARCH FILTER ENGINE
// ==========================================

final activeFilterProvider = StateProvider<FilterCriteria>((ref) {
  return FilterCriteria.defaults; // FIX: Use the static defaults we added
});

final filteredPropertiesProvider = Provider<List<PropertyModel>>((ref) {
  final allProperties = ref.watch(feedPropertiesProvider).valueOrNull ?? [];
  final criteria = ref.watch(activeFilterProvider);

  return allProperties.where((p) {
    // 1. Text Search
    if (criteria.query.isNotEmpty) {
      final q = criteria.query.toLowerCase();
      if (!p.location.toLowerCase().contains(q) && !p.title.toLowerCase().contains(q)) return false;
    }

    // 2. Price Range (FIX: Use p.priceValue double getter)
    if (criteria.minPrice != null && p.priceValue < criteria.minPrice!) return false;
    if (criteria.maxPrice != null && p.priceValue > criteria.maxPrice!) return false;

    // 3. Bedrooms (FIX: Use p.bedrooms int getter)
    if (criteria.minBeds != null) {
      if (criteria.minBeds == 4) {
        if (p.bedrooms < 4) return false;
      } else {
        if (p.bedrooms != criteria.minBeds) return false;
      }
    }

    // 4. Property Type (FIX: Use p.type getter)
    if (criteria.propertyType != null && p.type != criteria.propertyType) return false;

    return true;
  }).toList();
});

// ==========================================
// SAVED PROPERTIES (PORTFOLIO) ENGINE
// ==========================================

class SavedPropertiesNotifier extends AsyncNotifier<List<PropertyModel>> {
  final _db = LocalDatabaseService();

  @override
  Future<List<PropertyModel>> build() async {
    final maps = await _db.getSavedProperties();
    return maps.map(PropertyModel.fromMap).toList();
  }

  Future<void> toggleSave(PropertyModel property) async {
    final currentList = state.valueOrNull ?? [];
    final isSaved = currentList.any((p) => p.id == property.id);

    if (isSaved) {
      state = AsyncData(currentList.where((p) => p.id != property.id).toList());
      await _db.removeProperty(property.id); // FIX: Ensure this exists in DB service
    } else {
      state = AsyncData([...currentList, property]);
      // FIX: Changed from 'property' to 'property.toMap()'
      await _db.saveProperty(property.toMap());
    }
  }
}

final savedPropertiesProvider = AsyncNotifierProvider<SavedPropertiesNotifier, List<PropertyModel>>(() {
  return SavedPropertiesNotifier();
});

final isPropertySavedProvider = Provider.family<bool, String>((ref, id) {
  final savedList = ref.watch(savedPropertiesProvider).valueOrNull ?? [];
  return savedList.any((p) => p.id == id);
});

// ==========================================
// BOOKING (SITE VISIT) CONTROLLER
// ==========================================

class BookingController extends AsyncNotifier<List<BookingModel>> {
  final _db = LocalDatabaseService();

  @override
  Future<List<BookingModel>> build() async {
    final maps = await _db.getBookings();
    return maps.map(BookingModel.fromMap).toList();
  }

  Future<void> createBooking(BookingModel booking) async {
    final previousState = state.valueOrNull ?? [];
    state = AsyncData([booking, ...previousState]);

    try {
      await _db.saveBooking(booking.toMap());
    } catch (e, _) {
      state = AsyncData(previousState);
      rethrow;
    }
  }
}

final bookingControllerProvider =
AsyncNotifierProvider<BookingController, List<BookingModel>>(BookingController.new);