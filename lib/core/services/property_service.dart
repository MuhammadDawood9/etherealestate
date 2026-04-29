import 'package:flutter/foundation.dart';
import '../models/property_model.dart' show PropertyModel;
import '../repositories/property_repository.dart';

class PropertyService {
  static final PropertyService _instance = PropertyService._();
  factory PropertyService() => _instance;
  PropertyService._();

  Future<List<PropertyModel>> getFeedProperties() async {
    try {
      return await PropertyRepository.fetchFeed();
    } catch (e) {
      if (kDebugMode) debugPrint('getFeedProperties error: $e');
      return [];
    }
  }

  Future<List<PropertyModel>> getFeaturedProperties() async {
    try {
      return await PropertyRepository.fetchFeatured();
    } catch (e) {
      if (kDebugMode) debugPrint('getFeaturedProperties error: $e');
      return [];
    }
  }
}