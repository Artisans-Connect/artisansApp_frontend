import '../cache/cache_keys.dart';
import '../cache/cached_fetch.dart';
import '../network/api_client.dart';

/// Fallback categories data used when API is unavailable or returns empty.
/// Network-first approach: API → Fallback
const List<Map<String, dynamic>> _fallbackCategories = <Map<String, dynamic>>[
  {
    'id': 'plumbing',
    'name': 'Plumbing',
    'slug': 'plumbing',
    'icon_name': 'drop',
    'color_hex': '#4648D4',
    'description': 'Repairs, installation, maintenance',
    'sort_order': 1,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'plumbing_leaks', 'name': 'Leak repair', 'slug': 'leak_repair', 'description': 'Faucets, pipes, drainage', 'sort_order': 1},
      {'id': 'plumbing_install', 'name': 'Installation', 'slug': 'installation', 'description': 'Fixtures and appliances', 'sort_order': 2},
    ],
  },
  {
    'id': 'electrical',
    'name': 'Electrical',
    'slug': 'electrical',
    'icon_name': 'lightning',
    'color_hex': '#0058BE',
    'description': 'Wiring, repairs, installations',
    'sort_order': 2,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'electrical_wiring', 'name': 'Wiring', 'slug': 'wiring', 'description': 'Panels, outlets, lighting', 'sort_order': 1},
      {'id': 'electrical_repair', 'name': 'Repairs', 'slug': 'repairs', 'description': 'Faults and replacements', 'sort_order': 2},
    ],
  },
  {
    'id': 'carpentry',
    'name': 'Carpentry',
    'slug': 'carpentry',
    'icon_name': 'wrench',
    'color_hex': '#B55D00',
    'description': 'Furniture, repairs, custom work',
    'sort_order': 3,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'carpentry_furniture', 'name': 'Furniture', 'slug': 'furniture', 'description': 'Build and repair', 'sort_order': 1},
      {'id': 'carpentry_frames', 'name': 'Frames & doors', 'slug': 'frames_doors', 'description': 'Install and adjust', 'sort_order': 2},
    ],
  },
  {
    'id': 'cleaning',
    'name': 'Cleaning',
    'slug': 'cleaning',
    'icon_name': 'broom',
    'color_hex': '#00E676',
    'description': 'Home, office, deep cleaning',
    'sort_order': 4,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'cleaning_deep', 'name': 'Deep clean', 'slug': 'deep_clean', 'description': 'Home and office', 'sort_order': 1},
      {'id': 'cleaning_move', 'name': 'Move-in/out', 'slug': 'move_in_out', 'description': 'Full property clean', 'sort_order': 2},
    ],
  },
  {
    'id': 'painting',
    'name': 'Painting',
    'slug': 'painting',
    'icon_name': 'palette',
    'color_hex': '#F44336',
    'description': 'Interior, exterior, decorative',
    'sort_order': 5,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'painting_interior', 'name': 'Interior', 'slug': 'interior', 'description': 'Walls and ceilings', 'sort_order': 1},
      {'id': 'painting_exterior', 'name': 'Exterior', 'slug': 'exterior', 'description': 'Outdoor surfaces', 'sort_order': 2},
    ],
  },
  {
    'id': 'construction',
    'name': 'Construction',
    'slug': 'construction',
    'icon_name': 'barricade',
    'color_hex': '#FF9800',
    'description': 'Building, renovation, repairs',
    'sort_order': 6,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'construction_reno', 'name': 'Renovation', 'slug': 'renovation', 'description': 'Remodeling work', 'sort_order': 1},
      {'id': 'construction_repair', 'name': 'Structural repair', 'slug': 'structural_repair', 'description': 'Masonry and builds', 'sort_order': 2},
    ],
  },
  {
    'id': 'hvac',
    'name': 'HVAC',
    'slug': 'hvac',
    'icon_name': 'snowflake',
    'color_hex': '#2196F3',
    'description': 'Cooling, heating, ventilation',
    'sort_order': 7,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'hvac_ac', 'name': 'AC service', 'slug': 'ac_service', 'description': 'Cooling units', 'sort_order': 1},
      {'id': 'hvac_heat', 'name': 'Heating', 'slug': 'heating', 'description': 'Boilers and heaters', 'sort_order': 2},
    ],
  },
  {
    'id': 'landscaping',
    'name': 'Landscaping',
    'slug': 'landscaping',
    'icon_name': 'mountains',
    'color_hex': '#4CAF50',
    'description': 'Lawn, garden, outdoor design',
    'sort_order': 8,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'landscape_lawn', 'name': 'Lawn care', 'slug': 'lawn_care', 'description': 'Mowing and trimming', 'sort_order': 1},
      {'id': 'landscape_garden', 'name': 'Garden design', 'slug': 'garden_design', 'description': 'Plants and layout', 'sort_order': 2},
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
    return normalized.isNotEmpty ? normalized : _fallbackCategories;
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
      final List<dynamic> categories = await listCategories();
      
      // Find the category by slug or id
      final dynamic category = categories.firstWhere(
        (dynamic c) =>
            (c is Map && (c['slug'] == categorySlugOrId || c['id'] == categorySlugOrId)) ||
            (c is Map && c['categoryKey'] == categorySlugOrId),
        orElse: () => null,
      );

      if (category is Map && category['subcategories'] is List) {
        return _normalizeSubcategories(category['subcategories'] as List);
      }

      return <dynamic>[];
    } catch (e) {
      return <dynamic>[];
    }
  }

  List<dynamic> _readListResponse(dynamic response) {
    if (response is List) return response;
    if (response is Map<String, dynamic> && response['data'] is List) {
      return response['data'] as List;
    }
    return <dynamic>[];
  }

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
            (category['id'] as String).isNotEmpty)
        .toList();

    categories.sort(_compareSortOrder);
    return categories;
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
          return subcategory;
        })
        .where((Map<String, dynamic> subcategory) =>
            (subcategory['id'] as String).isNotEmpty)
        .toList();

    subcategories.sort(_compareSortOrder);
    return subcategories;
  }

  Map<String, dynamic>? _fallbackCategoryFor(Map<String, dynamic> category) {
    final String id = (category['id'] ?? '').toString().toLowerCase();
    final String slug = (category['slug'] ?? '').toString().toLowerCase();
    final String name = (category['name'] ?? '').toString().toLowerCase();

    for (final Map<String, dynamic> fallback in _fallbackCategories) {
      final String fallbackId = fallback['id'].toString().toLowerCase();
      final String fallbackSlug = fallback['slug'].toString().toLowerCase();
      final String fallbackName = fallback['name'].toString().toLowerCase();
      if (id == fallbackId ||
          id == fallbackSlug ||
          slug == fallbackSlug ||
          slug == fallbackId ||
          name == fallbackName) {
        return fallback;
      }
    }
    return null;
  }

  int _compareSortOrder(Map<String, dynamic> a, Map<String, dynamic> b) {
    final int orderA = (a['sort_order'] as num?)?.toInt() ?? 0;
    final int orderB = (b['sort_order'] as num?)?.toInt() ?? 0;
    if (orderA != orderB) return orderA.compareTo(orderB);
    return (a['name'] as String).compareTo(b['name'] as String);
  }
}
