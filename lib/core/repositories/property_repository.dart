// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/filter_criteria.dart';
import '../models/property_model.dart';

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
    _cachedFeed ??= await _ApiClient.fetchFeed(location: location);
    return _cachedFeed!;
  }

  static Future<List<PropertyModel>> fetchFeatured() async {
    _cachedFeatured ??= await _ApiClient.fetchFeatured();
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