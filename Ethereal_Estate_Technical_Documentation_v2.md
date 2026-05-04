# Ethereal Estate — Technical Documentation

**Version 3.0 — Spring 2026**

---

## Chapter 1 — Introduction

### 1.1 Background
The global real estate market continues its digital transformation. Version 2.0 integrated a **Python FastAPI backend** for real property data from Lahore, Pakistan. Version 3.0 focuses on UI/UX elevation, authentication improvements, and data quality.

### 1.2 Version 3.0 — New Features

| Feature | Implementation |
|---------|----------------|
| Cinematic Agent Profile Hero | `SliverAppBar` + `FlexibleSpaceBar` parallax, indigo gradient, DiceBear illustration avatar |
| Animated Stat Counters | `AnimationController` counts 0→124/9+/4.9 on screen load |
| Live Status Chip | Pulsing green dot animation via `AnimationController.repeat` |
| Testimonials Ribbon | Horizontal `ListView` with 4 client cards, accent-rotated avatars |
| Google Sign-In (wired) | `AuthService.signInWithGoogle()` connected to button (was empty) |
| Biometric Authentication | `local_auth` package — Face ID / Fingerprint on login screen |
| Email Auth + Forgot Password | Login screen converted to `StatefulWidget` with real controllers |
| Property Feed from Repository | `feedPropertiesProvider` replaces 3-item hardcoded list (now 10) |
| Unsplash Property Images | All 10 Lahore fallback properties use curated luxury building photos |
| Map — All Properties Pinned | 10 markers with real Lahore coordinates, each linked to property data |
| Agent Renamed | Agent name updated to "Ashfaq" throughout |

### 1.3 Goals Achieved (Cumulative)
- ✅ Python FastAPI backend integration
- ✅ Web-safe platform detection
- ✅ API URL auto-detection (127.0.0.1:8000 for web, emulator IP for Android)
- ✅ 34 unit tests passing
- ✅ Google Sign-In + Biometric (Face ID / Fingerprint) authentication
- ✅ Cinematic parallax agent profile with illustration avatar
- ✅ All 10 properties visible on map with accurate Lahore coordinates

---

## Chapter 2 — System Requirements

### 2.1 Technology Stack (Updated)

| Component | Technology |
|-----------|-------------|
| Backend | Python FastAPI + SQLite |
| Frontend | Flutter 3.10+ |
| State Management | Riverpod 2.x |
| Maps | flutter_map + Geoapify API |
| Auth | Firebase Auth |
| Local Storage | SQLite (sqflite) + in-memory fallback for web |

### 2.2 API Endpoints

```
GET /properties?page=1&page_size=20
GET /properties/{id}
GET /properties/search?location={query}&limit=50
```

**Response Format:**
```json
{
  "total": 223199,
  "page": 1,
  "page_size": 20,
  "pages": 11160,
  "results": [...]
}
```

---

## Chapter 3 — Implementation

### 3.1 Project Structure

```
lib/
├── core/
│   ├── models/
│   │   ├── property_model.dart
│   │   ├── booking_model.dart
│   │   └── filter_criteria.dart
│   ├── repositories/
│   │   └── property_repository.dart  ← API integration
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── local_database_service.dart
│   │   ├── property_service.dart
│   │   └── notification_service.dart
│   └── providers/
│       └── app_providers.dart  ← UserProfile provider
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart  ← NEW
│   ├── search/
│   │   ├── search_home_screen.dart
│   │   ├── search_filter_screen.dart
│   │   └── interactive_map_screen.dart  ← Geoapify
│   └── profile/
│       ├── account_settings_screen.dart
│       ├── agent_profile_screen.dart
│       └── my_collection_screen.dart
main.py  ← Python FastAPI backend
```

### 3.2 Key Code — PropertyRepository (API Integration)

```dart
// lib/core/repositories/property_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String get _baseUrl {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000';  // Web
  }
  return 'http://10.0.2.2:8000';      // Android emulator
}

class _ApiClient {
  static final _client = http.Client();

  static Future<List<PropertyModel>> fetchFeed() async {
    final uri = Uri.parse('$_baseUrl/properties?page=1&page_size=20');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch feed: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;
    return results
        .map((json) => PropertyModel.fromApiMap(json as Map<String, dynamic>))
        .toList();
  }
}

class PropertyRepository {
  static Future<List<PropertyModel>> fetchFeed() => _ApiClient.fetchFeed();
  static Future<List<PropertyModel>> fetchFeatured() => _ApiClient.fetchFeatured();
  static Future<PropertyModel?> fetchById(String id) => _ApiClient.fetchById(id);
}
```

### 3.3 Key Code — UserProfile Provider

```dart
// lib/core/providers/app_providers.dart
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
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile());

  void updateName(String name) => state = state.copyWith(displayName: name);
  void updateLocation(String location) => state = state.copyWith(location: location);
  void updatePhone(String phone) => state = state.copyWith(phone: phone);

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
```

### 3.4 Key Code — Interactive Map (All Properties Pinned)

All 10 fallback properties now have accurate Lahore coordinates stored in a `const` lookup map. Markers are generated from the loaded property list; tapping a pin selects that property and updates the preview card.

```dart
// lib/features/search/interactive_map_screen.dart
const _propertyCoords = <String, LatLng>{
  'lhr-001': LatLng(31.4439, 74.4295), // DHA Phase 6
  'lhr-002': LatLng(31.5067, 74.3333), // Gulberg III
  'lhr-003': LatLng(31.3553, 74.1934), // Bahria Town
  'lhr-004': LatLng(31.4858, 74.3266), // Model Town
  'lhr-005': LatLng(31.4697, 74.2725), // Johar Town
  'lhr-006': LatLng(31.5050, 74.3520), // Canal Road
  'lhr-007': LatLng(31.3620, 74.1950), // Askari 11
  'lhr-008': LatLng(31.5030, 74.3420), // Garden Town
  'lhr-009': LatLng(31.4588, 74.2810), // Wapda Town
  'lhr-010': LatLng(31.4000, 74.3900), // Valencia Town
};

// Markers generated dynamically from loaded properties:
MarkerLayer(
  markers: mappableProps.map((property) {
    final isSelected = _selectedProperty?.id == property.id;
    return Marker(
      point: _propertyCoords[property.id]!,
      child: GestureDetector(
        onTap: () => _onMarkerTapped(property),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF4C54B6) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFF4C54B6), width: isSelected ? 3 : 2),
          ),
          child: Icon(Icons.home_rounded, color: isSelected ? Colors.white : Color(0xFF4C54B6)),
        ),
      ),
    );
  }).toList(),
),
```

### 3.5 Key Code — Biometric Authentication

`local_auth ^2.3.0` is added to `pubspec.yaml`. `MainActivity.kt` extends `FlutterFragmentActivity` (required). Android manifest includes `USE_BIOMETRIC` + `USE_FINGERPRINT` permissions. iOS `Info.plist` includes `NSFaceIDUsageDescription`.

```dart
// lib/core/services/auth_service.dart
Future<bool> isBiometricAvailable() async {
  return await _localAuth.canCheckBiometrics &&
      await _localAuth.isDeviceSupported();
}

Future<bool> authenticateWithBiometrics() async {
  return await _localAuth.authenticate(
    localizedReason: 'Verify your identity to access Ethereal Estate',
    options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
  );
}
```

Login screen detects Face ID vs Fingerprint at `initState` and shows the correct button and icon. On success it checks `FirebaseAuth.currentUser` — if a session exists the user is taken to the home screen; otherwise prompted to sign in once first.

### 3.6 Key Code — Agent Profile (Parallax + Illustration)

Agent profile uses `ConsumerStatefulWidget` with two `AnimationController`s:

| Controller | Purpose |
|------------|---------|
| `_statsController` | Counts stats 0→target over 1.8 s with `easeOutCubic` |
| `_pulseController` | Repeating scale 0.75×↔1.25× for the live status dot |

The hero is a `SliverAppBar` with `expandedHeight: 440`. The `FlexibleSpaceBar` background contains:
- Deep indigo→purple gradient (`#0D1138` → `#3D44A8` → `#6B4FC8`)
- Three radial glow blobs for depth
- DiceBear `avataaars` illustration (seed: `Ashfaq`) in a `172px` clipped circle with glow shadow
- Name block + live status chip at bottom

### 3.7 Key Code — LocalDatabaseService (Web Fallback)

```dart
// lib/core/services/local_database_service.dart
class LocalDatabaseService {
  static final Map<String, String> _memoryPrefs = {}; // In-memory fallback for Web

  Future<String?> getPreference(String key, {String? defaultValue}) async {
    if (kIsWeb) return _memoryPrefs[key] ?? defaultValue;
    final db = await database;
    final rows = await db.query('preferences', where: 'key = ?', whereArgs: [key]);
    if (rows.isNotEmpty) return rows.first['value'] as String;
    return defaultValue;
  }

  Future<void> setPreference(String key, String value) async {
    if (kIsWeb) {
      _memoryPrefs[key] = value;
      return;
    }
    final db = await database;
    await db.insert('preferences', {'key': key, 'value': value});
  }
}
```

### 3.6 Python FastAPI Backend

```python
# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Ethereal Estate API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/properties", response_model=PaginatedResponse)
def list_properties(page: int = 1, page_size: int = 20, type: str = None):
    # Returns PaginatedResponse with 'results' key
    ...

@app.get("/properties/search")
def search_properties(location: str = None, max_price: int = None, limit: int = 50):
    # Returns list of Property objects
    ...
```

---

## Chapter 4 — Testing

### 4.1 Unit Tests (34 Passing)

| Test File | Coverage |
|-----------|-----------|
| property_model_test.dart | Serialization, fromMap, fromApiMap, copyWith, equality |
| property_repository_test.dart | fromApiMap mapping (areaSqft→sqft, int→String) |
| filter_criteria_test.dart | isDefault, copyWith, aliases |
| local_database_service_test.dart | Singleton, saveProperty, saveBooking |
| booking_model_test.dart | Serialization, formattedDate |
| widget_test.dart | GlassCard, ShimmerBox rendering |

### 4.2 Running Tests

```bash
flutter test
# Output: 34 tests passed
```

---

## Chapter 5 — Navigation

### Bottom Navigation (6 Tabs)

| Index | Icon | Screen | Route |
|-------|------|--------|--------|
| 0 | 🏠 Home | PropertyFeedScreen | `/feed` |
| 1 | 🔍 Search | SearchHomeScreen | `/search` |
| 2 | 🗺️ Map | InteractiveMapScreen | `/map` |
| 3 | ⭐ Collection | MyCollectionScreen | `/collection` |
| 4 | 👤 Agent | AgentProfileScreen | `/agent` |
| 5 | ⚙️ Profile | AccountSettingsScreen | `/profile` |

---

## Appendix — Running the Application

### Prerequisites
1. Python 3.8+ installed
2. Flutter 3.10+ SDK
3. Firebase project configured

### Backend Setup
```bash
# Start FastAPI server
cd etherealestate
uvicorn main:app --reload

# Server runs on http://127.0.0.1:8000
```

### Flutter Web Build
```bash
flutter build web
# Output: build/web/
```

### Key Files Reference

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, routes, Firebase init |
| `lib/core/repositories/property_repository.dart` | API calls + 10-property Lahore fallback with Unsplash images |
| `lib/core/services/auth_service.dart` | Firebase Auth + Google Sign-In + biometric (`local_auth`) |
| `lib/core/providers/app_providers.dart` | UserProfile, feedProperties, featuredProperties providers |
| `lib/features/auth/login_screen.dart` | StatefulWidget — email/Google/biometric auth, forgot password |
| `lib/features/auth/signup_screen.dart` | Registration with name input |
| `lib/features/property/property_feed_screen.dart` | ConsumerWidget — all 10 properties from repository |
| `lib/features/search/interactive_map_screen.dart` | Geoapify map, 10 pins from property data with real Lahore coords |
| `lib/features/profile/agent_profile_screen.dart` | Parallax hero, illustration avatar (Ashfaq), animated stats, testimonials |
| `lib/features/profile/account_settings_screen.dart` | Profile editing, Lahore default location |
| `main.py` | FastAPI backend with CORS |
| `android/app/src/main/AndroidManifest.xml` | Biometric permissions (`USE_BIOMETRIC`, `USE_FINGERPRINT`) |
| `android/app/src/main/kotlin/.../MainActivity.kt` | `FlutterFragmentActivity` (required for local_auth) |
| `ios/Runner/Info.plist` | `NSFaceIDUsageDescription` for Face ID |

---

*Documentation Updated: Spring 2026 — Version 3.0*
