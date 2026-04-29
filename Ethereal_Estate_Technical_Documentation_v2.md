# Ethereal Estate — Technical Documentation

**Version 2.0 — Spring 2026**

---

## Chapter 1 — Introduction

### 1.1 Background
The global real estate market continues its digital transformation. This version integrates a **Python FastAPI backend** for real property data from Lahore, Pakistan, replacing static seed data.

### 1.2 New Features Added

| Feature | Implementation |
|---------|----------------|
| Python FastAPI Backend | `main.py` with `/properties`, `/properties/search` endpoints |
| User Registration | Dedicated `signup_screen.dart` with form validation |
| Profile Management | `UserProfile` provider syncs name/location to Firebase |
| Settings Persistence | In-memory fallback for web (SQLite unavailable) |
| Lahore Data Focus | All properties, locations, mortgage in PKR |
| Interactive Map | Geoapify API with 5 Lahore pins |
| Agent Profile | Loads from API via `featuredPropertiesProvider` |

### 1.3 Goals Achieved (Updated)
- ✅ Python FastAPI backend integration
- ✅ Web-safe platform detection (no Platform.isAndroid on web)
- ✅ API URL auto-detection (127.0.0.1:8000 for web, 10.0.2.2 for emulator)
- ✅ 34 unit tests passing

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

### 3.4 Key Code — Interactive Map (Geoapify)

```dart
// lib/features/search/interactive_map_screen.dart
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class _InteractiveMapScreenState extends ConsumerState {
  static const String _geoapifyKey = 'a608c97c6f0b41418ae0a7dcfb964c78';
  static const String _tileUrl = 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png';

  static final LatLng _lahoreCenter = const LatLng(31.5497, 74.3436);

  final List<_MapPinData> _pins = [
    _MapPinData(position: const LatLng(33.5651, 73.0169), title: 'DHA Defence'),
    _MapPinData(position: const LatLng(33.5090, 73.3310), title: 'Bahria Town'),
    _MapPinData(position: const LatLng(31.4697, 74.2725), title: 'Gulberg'),
    _MapPinData(position: const LatLng(31.4320, 74.3910), title: 'Johar Town'),
    _MapPinData(position: const LatLng(31.4504, 74.3100), title: 'Cantt'),
  ];

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(featuredPropertiesProvider);
    
    return FlutterMap(
      options: MapOptions(initialCenter: _lahoreCenter, initialZoom: 10.5),
      children: [
        TileLayer(
          urlTemplate: '$_tileUrl?apiKey=$_geoapifyKey',
          userAgentPackageName: 'com.etherealestate.app',
        ),
        MarkerLayer(
          markers: _pins.asMap().entries.map((entry) {
            return Marker(
              point: entry.value.position,
              child: Icon(Icons.location_pin, color: Color(0xFF4C54B6)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
```

### 3.5 Key Code — LocalDatabaseService (Web Fallback)

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
| `lib/core/repositories/property_repository.dart` | API calls with kIsWeb toggle |
| `lib/core/providers/app_providers.dart` | UserProfile, feedProperties, featuredProperties |
| `lib/features/auth/signup_screen.dart` | Registration with name input |
| `lib/features/search/interactive_map_screen.dart` | Geoapify map with Lahore pins |
| `lib/features/profile/account_settings_screen.dart` | Profile editing, Lahore default location |
| `main.py` | FastAPI backend with CORS |

---

*Documentation Updated: Spring 2026*
