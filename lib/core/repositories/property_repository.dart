// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/filter_criteria.dart';
import '../models/property_model.dart';

const _lahoreProperties = <PropertyModel>[
  PropertyModel(id: 'lhr-001', title: 'DHA Grand Residence',      location: 'DHA Phase 6, Lahore',    price: 'PKR 8,50,00,000',  imageUrl: 'https://picsum.photos/seed/lhr001/600/400', beds: '5', baths: '5', sqft: '5,000',  category: 'House'),
  PropertyModel(id: 'lhr-002', title: 'Gulberg Elite Penthouse',   location: 'Gulberg III, Lahore',    price: 'PKR 4,20,00,000',  imageUrl: 'https://picsum.photos/seed/lhr002/600/400', beds: '3', baths: '3', sqft: '2,800',  category: 'Flat'),
  PropertyModel(id: 'lhr-003', title: 'Bahria Town Mansion',       location: 'Bahria Town, Lahore',    price: 'PKR 12,50,00,000', imageUrl: 'https://picsum.photos/seed/lhr003/600/400', beds: '6', baths: '6', sqft: '7,500',  category: 'House'),
  PropertyModel(id: 'lhr-004', title: 'Model Town Classic',        location: 'Model Town, Lahore',     price: 'PKR 5,50,00,000',  imageUrl: 'https://picsum.photos/seed/lhr004/600/400', beds: '4', baths: '4', sqft: '4,000',  category: 'House'),
  PropertyModel(id: 'lhr-005', title: 'Johar Town Upper Portion',  location: 'Johar Town, Lahore',     price: 'PKR 2,20,00,000',  imageUrl: 'https://picsum.photos/seed/lhr005/600/400', beds: '3', baths: '2', sqft: '2,200',  category: 'Upper Portion'),
  PropertyModel(id: 'lhr-006', title: 'Canal View Farm House',     location: 'Canal Road, Lahore',     price: 'PKR 18,00,00,000', imageUrl: 'https://picsum.photos/seed/lhr006/600/400', beds: '6', baths: '5', sqft: '10,000', category: 'Farm House'),
  PropertyModel(id: 'lhr-007', title: 'Askari 11 Residence',       location: 'Askari 11, Lahore',      price: 'PKR 6,80,00,000',  imageUrl: 'https://picsum.photos/seed/lhr007/600/400', beds: '4', baths: '4', sqft: '4,500',  category: 'House'),
  PropertyModel(id: 'lhr-008', title: 'Garden Town Apartment',     location: 'Garden Town, Lahore',    price: 'PKR 1,80,00,000',  imageUrl: 'https://picsum.photos/seed/lhr008/600/400', beds: '2', baths: '2', sqft: '1,200',  category: 'Flat'),
  PropertyModel(id: 'lhr-009', title: 'Wapda Town Lower Portion',  location: 'Wapda Town, Lahore',     price: 'PKR 1,50,00,000',  imageUrl: 'https://picsum.photos/seed/lhr009/600/400', beds: '2', baths: '2', sqft: '1,100',  category: 'Lower Portion'),
  PropertyModel(id: 'lhr-010', title: 'Valencia Town Villa',       location: 'Valencia Town, Lahore',  price: 'PKR 9,00,00,000',  imageUrl: 'https://picsum.photos/seed/lhr010/600/400', beds: '5', baths: '5', sqft: '5,500',  category: 'House'),
];

String get _baseUrl {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000';
  }
  return 'http://192.168.100.52:8000';
}

class _ApiClient {
  static final _client = http.Client();

  static Future<List<PropertyModel>> fetchFeed({String? location}) async {
    final uri = Uri.parse('$_baseUrl/properties?page=1&page_size=20${location != null ? '&location=$location' : ''}');
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

  static Future<List<PropertyModel>> fetchFeatured() async {
    final uri = Uri.parse('$_baseUrl/properties?page=1&page_size=10');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch featured: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;
    return results
        .map((json) => PropertyModel.fromApiMap(json as Map<String, dynamic>))
        .toList();
  }

  static Future<PropertyModel?> fetchById(String id) async {
    final uri = Uri.parse('$_baseUrl/properties/$id');
    final response = await _client.get(uri);

    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch property: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return PropertyModel.fromApiMap(body);
  }

  static Future<List<PropertyModel>> search(String query) async {
    final uri = Uri.parse('$_baseUrl/properties/search?location=$query&limit=50');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to search: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((json) => PropertyModel.fromApiMap(json as Map<String, dynamic>))
        .toList();
  }
}

class PropertyRepository {
  static List<PropertyModel>? _cachedFeed;
  static List<PropertyModel>? _cachedFeatured;

  static Future<List<PropertyModel>> fetchFeed({String? location}) async {
    if (_cachedFeed == null) {
      try {
        _cachedFeed = await _ApiClient.fetchFeed(location: location);
        if (_cachedFeed!.isEmpty) _cachedFeed = List.of(_lahoreProperties);
      } catch (_) {
        _cachedFeed = List.of(_lahoreProperties);
      }
    }
    return _cachedFeed!;
  }

  static Future<List<PropertyModel>> fetchFeatured() async {
    if (_cachedFeatured == null) {
      try {
        _cachedFeatured = await _ApiClient.fetchFeatured();
        if (_cachedFeatured!.isEmpty) _cachedFeatured = List.of(_lahoreProperties);
      } catch (_) {
        _cachedFeatured = List.of(_lahoreProperties);
      }
    }
    return _cachedFeatured!;
  }

  static List<PropertyModel> get feed =>
      _cachedFeed ?? [];

  static List<PropertyModel> get featured =>
      _cachedFeatured ?? [];

  static List<PropertyModel> get all =>
      _cachedFeed ?? [];

  static Future<PropertyModel?> fetchById(String id) => _ApiClient.fetchById(id);

  static Future<List<PropertyModel>> search(String query) => _ApiClient.search(query);

  static List<PropertyModel> searchSync(String query) {
    final q = query.toLowerCase();
    return (_cachedFeed ?? []).where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }

  static Future<List<PropertyModel>> filter(String query, FilterCriteria? criteria) async {
    final results = await _ApiClient.search(query);
    if (criteria == null) return results;
    return filterList(results, query, criteria);
  }

  static List<PropertyModel> filterSync(String query, FilterCriteria? criteria) {
    final props = criteria == null
        ? (_cachedFeed ?? [])
        : filterList(_cachedFeed ?? [], query, criteria);
    if (query.isEmpty) return props;
    return props.where((p) {
      final q = query.toLowerCase();
      return p.title.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q);
    }).toList();
  }

  static List<PropertyModel> filterList(
      List<PropertyModel> properties, String query, FilterCriteria criteria) {
    return properties.where((p) {
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!p.location.toLowerCase().contains(q) &&
            !p.title.toLowerCase().contains(q)) {
          return false;
        }
      }

      if (criteria.minPrice != null && p.priceValue < criteria.minPrice!) {
        return false;
      }
      if (criteria.maxPrice != null && p.priceValue > criteria.maxPrice!) {
        return false;
      }

      if (criteria.minBeds != null) {
        if (criteria.minBeds == 4) {
          if (p.bedrooms < 4) return false;
        } else {
          if (p.bedrooms != criteria.minBeds) return false;
        }
      }

      if (criteria.propertyType != null && p.type != criteria.propertyType) {
        return false;
      }

      return true;
    }).toList();
  }
}