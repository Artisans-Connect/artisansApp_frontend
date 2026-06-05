import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.description,
  });

  final String placeId;
  final String description;
}

class PlaceLookupResult {
  const PlaceLookupResult({
    required this.position,
    required this.address,
  });

  final LatLng position;
  final String address;
}

class PlaceLookupService {
  static final PlaceLookupService instance = PlaceLookupService._();
  PlaceLookupService._();

  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  bool get isConfigured => AppConstants.googleMapsApiKey.isNotEmpty;

  Future<List<PlaceSuggestion>> search(String query) async {
    if (!isConfigured || query.trim().length < 2) return <PlaceSuggestion>[];
    final Uri uri = Uri.parse('$_baseUrl/place/autocomplete/json').replace(
      queryParameters: <String, String>{
        'input': query.trim(),
        'key': AppConstants.googleMapsApiKey,
        'components': 'country:gh',
      },
    );
    final http.Response response = await http.get(uri);
    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return <PlaceSuggestion>[];
    final dynamic predictions = decoded['predictions'];
    if (predictions is! List) return <PlaceSuggestion>[];
    return predictions
        .whereType<Map<String, dynamic>>()
        .map(
          (Map<String, dynamic> item) => PlaceSuggestion(
            placeId: (item['place_id'] ?? '').toString(),
            description: (item['description'] ?? '').toString(),
          ),
        )
        .where((PlaceSuggestion item) =>
            item.placeId.isNotEmpty && item.description.isNotEmpty)
        .toList();
  }

  Future<PlaceLookupResult?> details(String placeId) async {
    if (!isConfigured || placeId.isEmpty) return null;
    final Uri uri = Uri.parse('$_baseUrl/place/details/json').replace(
      queryParameters: <String, String>{
        'place_id': placeId,
        'fields': 'formatted_address,geometry',
        'key': AppConstants.googleMapsApiKey,
      },
    );
    final http.Response response = await http.get(uri);
    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final dynamic result = decoded['result'];
    if (result is! Map<String, dynamic>) return null;
    final dynamic location = result['geometry']?['location'];
    if (location is! Map<String, dynamic>) return null;
    final double? lat = (location['lat'] as num?)?.toDouble();
    final double? lng = (location['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return PlaceLookupResult(
      position: LatLng(lat, lng),
      address: (result['formatted_address'] ?? '').toString(),
    );
  }

  Future<String?> reverseGeocode(LatLng position) async {
    if (!isConfigured) return null;
    final Uri uri = Uri.parse('$_baseUrl/geocode/json').replace(
      queryParameters: <String, String>{
        'latlng': '${position.latitude},${position.longitude}',
        'key': AppConstants.googleMapsApiKey,
      },
    );
    final http.Response response = await http.get(uri);
    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final dynamic results = decoded['results'];
    if (results is! List || results.isEmpty) return null;
    final dynamic first = results.first;
    if (first is! Map<String, dynamic>) return null;
    final String address = (first['formatted_address'] ?? '').toString();
    return address.isEmpty ? null : address;
  }
}
