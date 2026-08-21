import 'package:artisans_app/core/cache/cache_keys.dart';
import 'package:artisans_app/core/cache/cached_fetch.dart';
import 'package:artisans_app/core/network/api_client.dart';

/// Fallback categories data used when API is unavailable or returns empty.
/// Network-first approach: API → Fallback

const List<Map<String, dynamic>> _fallbackCategories = <Map<String, dynamic>>[
  {
    'id': 'plumbing_water',
    'name': 'Plumbing & Water Systems',
    'slug': 'plumbing_water',
    'icon_name': 'drop',
    'color_hex': '#2196F3',
    'description': 'Pipes, boreholes, water pump setup, and drainage repairs',
    'sort_order': 1,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'plumber', 'name': 'Plumber', 'slug': 'plumber', 'description': 'Pipe installation, pipe leakage repair, bathroom plumbing', 'sort_order': 1},
      {'id': 'borehole_pump_technician', 'name': 'Borehole / Pump Technician', 'slug': 'borehole_pump_technician', 'description': 'Pump repair, water tank connection, pressure pump setup', 'sort_order': 2},
      {'id': 'drainage_worker', 'name': 'Drainage Worker', 'slug': 'drainage_worker', 'description': 'Drain cleaning, gutter repair, blocked pipe work', 'sort_order': 3},
      {'id': 'sanitary_installer', 'name': 'Sanitary Installer', 'slug': 'sanitary_installer', 'description': 'WC installation, sink installation, shower installation', 'sort_order': 4},
    ],
  },
  {
    'id': 'electrical_power',
    'name': 'Electrical & Power',
    'slug': 'electrical_power',
    'icon_name': 'lightning',
    'color_hex': '#0058BE',
    'description': 'Wiring, solar panels, appliance repair, and backup generators',
    'sort_order': 2,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'electrician', 'name': 'Electrician', 'slug': 'electrician', 'description': 'Wiring, socket installation, light installation, fault tracing', 'sort_order': 1},
      {'id': 'solar_technician', 'name': 'Solar Technician', 'slug': 'solar_technician', 'description': 'Solar panel install, inverter setup, battery setup', 'sort_order': 2},
      {'id': 'appliance_electrician', 'name': 'Appliance Electrician', 'slug': 'appliance_electrician', 'description': 'Fan repair, iron repair, small appliance diagnosis', 'sort_order': 3},
      {'id': 'generator_technician', 'name': 'Generator Technician', 'slug': 'generator_technician', 'description': 'Generator repair, servicing, installation', 'sort_order': 4},
      {'id': 'cctv_security_installer', 'name': 'CCTV / Security Installer', 'slug': 'cctv_security_installer', 'description': 'CCTV camera installation, intercom setup, access control', 'sort_order': 5},
    ],
  },
  {
    'id': 'auto_mechanical',
    'name': 'Auto & Mechanical Repairs',
    'slug': 'auto_mechanical',
    'icon_name': 'car',
    'color_hex': '#795548',
    'description': 'Vehicle mechanic, spraying, auto body repair, and motorbikes',
    'sort_order': 3,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'auto_mechanic', 'name': 'Auto Mechanic', 'slug': 'auto_mechanic', 'description': 'Engine issues, servicing, brakes, suspension', 'sort_order': 1},
      {'id': 'auto_electrician', 'name': 'Auto Electrician', 'slug': 'auto_electrician', 'description': 'Car wiring, battery issues, alternator, starter problems', 'sort_order': 2},
      {'id': 'vulcanizer', 'name': 'Vulcanizer', 'slug': 'vulcanizer', 'description': 'Tyre repair, tyre replacement, wheel balancing', 'sort_order': 3},
      {'id': 'sprayer_body_worker', 'name': 'Sprayer / Auto Body Worker', 'slug': 'sprayer_body_worker', 'description': 'Car spraying, dents, body repair', 'sort_order': 4},
      {'id': 'motorcycle_mechanic', 'name': 'Motorcycle Mechanic', 'slug': 'motorcycle_mechanic', 'description': 'Motorbike servicing, repairs', 'sort_order': 5},
      {'id': 'heavy_equipment_mechanic', 'name': 'Heavy Equipment Mechanic', 'slug': 'heavy_equipment_mechanic', 'description': 'Excavator, truck, construction machinery repair', 'sort_order': 6},
    ],
  },
  {
    'id': 'construction_building',
    'name': 'Carpentry & Woodwork',
    'slug': 'construction_building',
    'icon_name': 'barricade',
    'color_hex': '#B55D00',
    'description': 'Furniture making, doors, cabinets, formwork, and roofing woodwork',
    'sort_order': 4,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'carpenter', 'name': 'Carpenter', 'slug': 'carpenter', 'description': 'Roofing woodwork, doors, cabinets, formwork, furniture repair', 'sort_order': 1},
    ],
  },
];

class CategoriesService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Fetches all active categories with their nested subcategories.
  /// 
  /// Network-first approach with local fallback:
  /// 1. Attempts to fetch from API (primary source)
  /// 2. If error or empty response, uses local fallback data
  /// 3. Guarantees non-empty list of categories
  /// 
  /// Results are cached according to [CacheKeys.categoriesTtl].
  /// Pass [forceRefresh] = true to bypass the cache and fetch fresh data.
  Future<List<dynamic>> listCategories({bool forceRefresh = false}) async {
    final List<dynamic> cachedOrFresh = await CachedFetch.get<List<dynamic>>(
      key: CacheKeys.categories,
      ttl: CacheKeys.categoriesTtl,
      forceRefresh: forceRefresh,
      fetch: () async {
        try {
          final response = await _apiClient.get('/categories');
          final List<Map<String, dynamic>> data = _normalizeCategories(
            _readListResponse(response),
          );

          if (data.isNotEmpty) return data;

          return _fallbackCategories;
        } catch (e) {
          return _fallbackCategories;
        }
      },
    );
    final List<Map<String, dynamic>> normalized =
        _normalizeCategories(cachedOrFresh);
    if (normalized.isEmpty) return _fallbackCategories;
    return _mergeWithFallbackWhenCatalogLooksOld(normalized);
  }

  /// Gets subcategories for a specific category by ID or slug.
  /// 
  /// First attempts to extract subcategories from cached categories data.
  /// If not found in cache, returns an empty list.
  Future<List<dynamic>> getSubcategoriesFor(String? categorySlugOrId) async {
    if (categorySlugOrId == null || categorySlugOrId.isEmpty) {
      return <dynamic>[];
    }

    try {
      final List<Map<String, dynamic>> cachedCategories =
          _normalizeCategories(await listCategories());
      final List<Map<String, dynamic>> cachedSubcategories =
          _subcategoriesFromCategories(cachedCategories, categorySlugOrId);
      if (cachedSubcategories.isNotEmpty) return cachedSubcategories;

      final List<Map<String, dynamic>> freshCategories =
          _normalizeCategories(await listCategories(forceRefresh: true));
      final List<Map<String, dynamic>> freshSubcategories =
          _subcategoriesFromCategories(freshCategories, categorySlugOrId);
      if (freshSubcategories.isNotEmpty) return freshSubcategories;

      final Map<String, dynamic>? fallback =
          _fallbackCategoryForKey(categorySlugOrId);
      return _normalizeSubcategories(
        fallback?['subcategories'] is List
            ? fallback!['subcategories'] as List
            : const <dynamic>[],
      );
    } catch (e) {
      final Map<String, dynamic>? fallback =
          _fallbackCategoryForKey(categorySlugOrId);
      return _normalizeSubcategories(
        fallback?['subcategories'] is List
            ? fallback!['subcategories'] as List
            : const <dynamic>[],
      );
    }
  }

  List<dynamic> _readListResponse(dynamic response) {
    if (response is List) return response;
    if (response is Map<String, dynamic> && response['data'] is List) {
      return response['data'] as List;
    }
    return <dynamic>[];
  }

  static const Set<String> _legacyFlatSlugs = <String>{
    'plumbing',
    'electrical',
    'carpentry',
    'masonry',
    'welding',
    'construction',
    'automotive',
    'painting',
    'tiling',
    'roofing',
    'hvac',
    'appliance_repair',
    'cleaning',
    'landscaping',
    'fashion',
    'beauty',
    'catering',
    'upholstery',
    'security',
    'ict_support',
  };

  List<Map<String, dynamic>> _normalizeCategories(List<dynamic> raw) {
    final List<Map<String, dynamic>> categories = raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> item) {
          final Map<String, dynamic> category = Map<String, dynamic>.from(item);
          category['id'] = (category['id'] ?? category['slug'] ?? '').toString();
          category['name'] = (category['name'] ?? 'Service').toString();
          category['slug'] = (category['slug'] ?? category['id']).toString();
          category['icon_name'] = category['icon_name']?.toString();
          category['color_hex'] = category['color_hex']?.toString();
          category['description'] = category['description']?.toString();
          final Map<String, dynamic>? fallback = _fallbackCategoryFor(category);
          category['icon_name'] ??= fallback?['icon_name']?.toString();
          category['color_hex'] ??= fallback?['color_hex']?.toString();
          category['description'] ??= fallback?['description']?.toString();

          final List<Map<String, dynamic>> subcategories = _normalizeSubcategories(
            category['subcategories'] is List
                ? category['subcategories'] as List
                : const <dynamic>[],
          );
          category['subcategories'] = subcategories.isNotEmpty
              ? subcategories
              : _normalizeSubcategories(
                  fallback?['subcategories'] is List
                      ? fallback!['subcategories'] as List
                      : const <dynamic>[],
                );
          return category;
        })
        .where((Map<String, dynamic> category) =>
            (category['id'] as String).isNotEmpty &&
            !_legacyFlatSlugs.contains(
              (category['slug'] ?? '').toString().trim().toLowerCase(),
            ) &&
            category['subcategories'] is List &&
            (category['subcategories'] as List).isNotEmpty)
        .toList();

    categories.sort(_compareSortOrder);
    return categories;
  }

  List<Map<String, dynamic>> _subcategoriesFromCategories(
    List<Map<String, dynamic>> categories,
    String categorySlugOrId,
  ) {
    final String key = _normalizeLookupKey(categorySlugOrId);
    for (final Map<String, dynamic> category in categories) {
      final Set<String> values = <String>{
        _normalizeLookupKey(category['id']),
        _normalizeLookupKey(category['slug']),
        _normalizeLookupKey(category['name']),
        _normalizeLookupKey(category['categoryKey']),
      }..remove('');
      if (values.contains(key)) {
        return _normalizeSubcategories(
          category['subcategories'] is List
              ? category['subcategories'] as List
              : const <dynamic>[],
        );
      }
    }
    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _normalizeSubcategories(List<dynamic> raw) {
    final List<Map<String, dynamic>> subcategories = raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> item) {
          final Map<String, dynamic> subcategory = Map<String, dynamic>.from(item);
          subcategory['id'] =
              (subcategory['id'] ?? subcategory['slug'] ?? '').toString();
          subcategory['name'] = (subcategory['name'] ?? 'Service type').toString();
          subcategory['slug'] = (subcategory['slug'] ?? subcategory['id']).toString();
          subcategory['description'] = subcategory['description']?.toString();
          if (subcategory['base_fee'] != null) {
            subcategory['base_fee'] = (subcategory['base_fee'] as num).toInt();
          }
          return subcategory;
        })
        .where((Map<String, dynamic> subcategory) =>
            (subcategory['id'] as String).isNotEmpty)
        .toList();

    subcategories.sort(_compareSortOrder);
    return subcategories;
  }

  List<Map<String, dynamic>> _mergeWithFallbackWhenCatalogLooksOld(
    List<Map<String, dynamic>> categories,
  ) {
    if (categories.length >= _fallbackCategories.length) return categories;

    final Map<String, Map<String, dynamic>> bySlug = <String, Map<String, dynamic>>{
      for (final Map<String, dynamic> fallback in _fallbackCategories)
        _normalizeLookupKey(fallback['slug']): Map<String, dynamic>.from(fallback),
    };

    for (final Map<String, dynamic> category in categories) {
      final String slug = _normalizeLookupKey(category['slug']);
      if (slug.isEmpty) continue;
      final Map<String, dynamic>? fallback = bySlug[slug];
      if (fallback == null) {
        bySlug[slug] = category;
        continue;
      }

      final List<Map<String, dynamic>> fallbackSubcategories =
          _normalizeSubcategories(
        fallback['subcategories'] is List
            ? fallback['subcategories'] as List
            : const <dynamic>[],
      );
      final List<Map<String, dynamic>> categorySubcategories =
          _normalizeSubcategories(
        category['subcategories'] is List
            ? category['subcategories'] as List
            : const <dynamic>[],
      );

      bySlug[slug] = <String, dynamic>{
        ...fallback,
        ...category,
        'subcategories': categorySubcategories.length >=
                fallbackSubcategories.length
            ? categorySubcategories
            : fallbackSubcategories,
      };
    }

    final List<Map<String, dynamic>> merged = bySlug.values.toList()
      ..sort(_compareSortOrder);
    return merged;
  }

  Map<String, dynamic>? _fallbackCategoryFor(Map<String, dynamic> category) {
    final String id = _normalizeLookupKey(category['id']);
    final String slug = _normalizeLookupKey(category['slug']);
    final String name = _normalizeLookupKey(category['name']);
    final String categoryKey = _normalizeLookupKey(category['categoryKey']);

    for (final Map<String, dynamic> fallback in _fallbackCategories) {
      final String fallbackId = _normalizeLookupKey(fallback['id']);
      final String fallbackSlug = _normalizeLookupKey(fallback['slug']);
      final String fallbackName = _normalizeLookupKey(fallback['name']);
      if (id == fallbackId ||
          id == fallbackSlug ||
          slug == fallbackSlug ||
          slug == fallbackId ||
          name == fallbackName ||
          categoryKey == fallbackId ||
          categoryKey == fallbackSlug) {
        return fallback;
      }
    }
    return null;
  }

  Map<String, dynamic>? _fallbackCategoryForKey(String key) {
    final String normalized = _normalizeLookupKey(key);
    for (final Map<String, dynamic> fallback in _fallbackCategories) {
      final Set<String> values = <String>{
        _normalizeLookupKey(fallback['id']),
        _normalizeLookupKey(fallback['slug']),
        _normalizeLookupKey(fallback['name']),
      };
      if (values.contains(normalized)) return fallback;
    }
    return null;
  }

  String _normalizeLookupKey(Object? value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s-]+'), '_');
  }

  int _compareSortOrder(Map<String, dynamic> a, Map<String, dynamic> b) {
    final int orderA = (a['sort_order'] as num?)?.toInt() ?? 0;
    final int orderB = (b['sort_order'] as num?)?.toInt() ?? 0;
    if (orderA != orderB) return orderA.compareTo(orderB);
    return (a['name'] as String).compareTo(b['name'] as String);
  }
}
