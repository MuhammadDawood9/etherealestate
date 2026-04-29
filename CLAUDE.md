# Ethereal Estate — Developer Reference

Luxury real estate Flutter app. Glassmorphic design, Firebase Auth, SQLite persistence.

## Architecture

```
lib/
  core/
    models/
      property_model.dart     - PropertyModel with toMap/fromMap
      booking_model.dart      - BookingModel with formattedDate helper
      filter_criteria.dart    - FilterCriteria (type, price range, bedrooms)
    repositories/
      property_repository.dart - Static feed/featured lists, search(), filter()
    services/
      auth_service.dart       - Firebase Auth (sign in, register, sign out, reset)
      local_database_service.dart - SQLite v2 (saved_properties + bookings tables)
features/
    auth/
      login_screen.dart
      signup_screen.dart
    booking/booking_calendar_screen.dart
    onboarding_screen.dart
    profile/
      account_settings_screen.dart
      agent_profile_screen.dart
      my_collection_screen.dart
    property/
      floor_plan_screen.dart
      property_details_screen.dart
      property_feed_screen.dart
    search/
      interactive_map_screen.dart  - flutter_map + OSM tiles + lat/lng markers
      search_filter_screen.dart
      search_home_screen.dart
    splash_screen.dart
  shared/widgets/
    app_menu_sheet.dart
    bottom_nav_bar.dart
    glass_card.dart
  firebase_options.dart
  main.dart
```
