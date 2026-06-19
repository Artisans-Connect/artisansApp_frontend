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
      {'id': 'plumbing_leak_repair', 'name': 'Leak repair', 'slug': 'leak_repair', 'description': 'Faucets, pipes, tanks and drainage leaks', 'sort_order': 1},
      {'id': 'plumbing_installation', 'name': 'Installation', 'slug': 'installation', 'description': 'Fixtures, sinks, toilets and pumps', 'sort_order': 2},
      {'id': 'plumbing_drainage_septic', 'name': 'Drainage & septic', 'slug': 'drainage_septic', 'description': 'Blocked drains, soakaways and septic issues', 'sort_order': 3},
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
      {'id': 'electrical_wiring', 'name': 'Wiring', 'slug': 'wiring', 'description': 'Panels, outlets, sockets and lighting', 'sort_order': 1},
      {'id': 'electrical_repairs', 'name': 'Repairs', 'slug': 'repairs', 'description': 'Faults, trips and replacements', 'sort_order': 2},
      {'id': 'electrical_generator_inverter', 'name': 'Generator & inverter', 'slug': 'generator_inverter', 'description': 'Generator, inverter and backup power support', 'sort_order': 3},
    ],
  },
  {
    'id': 'carpentry',
    'name': 'Carpentry',
    'slug': 'carpentry',
    'icon_name': 'wrench',
    'color_hex': '#B55D00',
    'description': 'Furniture, cabinets, doors, woodwork',
    'sort_order': 3,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'carpentry_furniture', 'name': 'Furniture', 'slug': 'furniture', 'description': 'Build and repair furniture', 'sort_order': 1},
      {'id': 'carpentry_frames_doors', 'name': 'Frames & doors', 'slug': 'frames_doors', 'description': 'Install and adjust doors, frames and locks', 'sort_order': 2},
      {'id': 'carpentry_cabinets_wardrobes', 'name': 'Cabinets & wardrobes', 'slug': 'cabinets_wardrobes', 'description': 'Kitchen cabinets, wardrobes and shelving', 'sort_order': 3},
    ],
  },
  {
    'id': 'masonry',
    'name': 'Masonry & Blockwork',
    'slug': 'masonry',
    'icon_name': 'bricks',
    'color_hex': '#8B5E3C',
    'description': 'Blocks, plastering, concrete and masonry repairs',
    'sort_order': 4,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'masonry_block_laying', 'name': 'Block laying', 'slug': 'block_laying', 'description': 'Blockwork, walls and partitions', 'sort_order': 1},
      {'id': 'masonry_plastering', 'name': 'Plastering', 'slug': 'plastering', 'description': 'Wall plastering and screeding', 'sort_order': 2},
      {'id': 'masonry_concrete_repair', 'name': 'Concrete repair', 'slug': 'concrete_repair', 'description': 'Concrete, steps and surface repairs', 'sort_order': 3},
    ],
  },
  {
    'id': 'welding',
    'name': 'Welding & Fabrication',
    'slug': 'welding',
    'icon_name': 'fire',
    'color_hex': '#607D8B',
    'description': 'Metal gates, burglar proofing and fabrication',
    'sort_order': 5,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'welding_metal_gates', 'name': 'Metal gates', 'slug': 'metal_gates', 'description': 'Gates, frames and metal doors', 'sort_order': 1},
      {'id': 'welding_burglar_proofing', 'name': 'Burglar proofing', 'slug': 'burglar_proofing', 'description': 'Window bars and security grills', 'sort_order': 2},
      {'id': 'welding_fabrication_repair', 'name': 'Fabrication repair', 'slug': 'fabrication_repair', 'description': 'Welding repairs and custom metal work', 'sort_order': 3},
    ],
  },
  {
    'id': 'construction',
    'name': 'Construction & Renovation',
    'slug': 'construction',
    'icon_name': 'barricade',
    'color_hex': '#FF9800',
    'description': 'Building, renovation and structural repairs',
    'sort_order': 6,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'construction_renovation', 'name': 'Renovation', 'slug': 'renovation', 'description': 'Remodeling and general renovation', 'sort_order': 1},
      {'id': 'construction_structural_repair', 'name': 'Structural repair', 'slug': 'structural_repair', 'description': 'Masonry, concrete and structural fixes', 'sort_order': 2},
      {'id': 'construction_site_labour', 'name': 'Site labour', 'slug': 'site_labour', 'description': 'General construction labour and finishing', 'sort_order': 3},
    ],
  },
  {
    'id': 'automotive',
    'name': 'Automotive & Small Engine',
    'slug': 'automotive',
    'icon_name': 'car',
    'color_hex': '#795548',
    'description': 'Vehicle, motorbike and small engine repairs',
    'sort_order': 7,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'automotive_car_mechanic', 'name': 'Car mechanic', 'slug': 'car_mechanic', 'description': 'Diagnosis, servicing and repairs', 'sort_order': 1},
      {'id': 'automotive_motorbike_repair', 'name': 'Motorbike repair', 'slug': 'motorbike_repair', 'description': 'Motorbike and tricycle repairs', 'sort_order': 2},
      {'id': 'automotive_auto_body_spraying', 'name': 'Auto body & spraying', 'slug': 'auto_body_spraying', 'description': 'Body work, spraying and panel repairs', 'sort_order': 3},
    ],
  },
  {
    'id': 'painting',
    'name': 'Painting',
    'slug': 'painting',
    'icon_name': 'palette',
    'color_hex': '#F44336',
    'description': 'Interior, exterior and decorative painting',
    'sort_order': 8,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'painting_interior', 'name': 'Interior', 'slug': 'interior', 'description': 'Walls, ceilings and rooms', 'sort_order': 1},
      {'id': 'painting_exterior', 'name': 'Exterior', 'slug': 'exterior', 'description': 'Outdoor surfaces and weather coating', 'sort_order': 2},
      {'id': 'painting_decorative_finish', 'name': 'Decorative finish', 'slug': 'decorative_finish', 'description': 'Texture, patterns and special finishes', 'sort_order': 3},
    ],
  },
  {
    'id': 'tiling',
    'name': 'Tiling & Flooring',
    'slug': 'tiling',
    'icon_name': 'squares_four',
    'color_hex': '#009688',
    'description': 'Floor tiles, wall tiles and floor finishing',
    'sort_order': 9,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'tiling_floor_tiling', 'name': 'Floor tiling', 'slug': 'floor_tiling', 'description': 'Floor tile installation and replacement', 'sort_order': 1},
      {'id': 'tiling_wall_tiling', 'name': 'Wall tiling', 'slug': 'wall_tiling', 'description': 'Kitchen, bathroom and wall tiles', 'sort_order': 2},
      {'id': 'tiling_terrazzo_floor_finish', 'name': 'Terrazzo & floor finish', 'slug': 'terrazzo_floor_finish', 'description': 'Terrazzo, screed and floor finishing', 'sort_order': 3},
    ],
  },
  {
    'id': 'roofing',
    'name': 'Roofing & Ceiling',
    'slug': 'roofing',
    'icon_name': 'house_line',
    'color_hex': '#9C27B0',
    'description': 'Roofing sheets, ceiling panels and leak fixes',
    'sort_order': 10,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'roofing_roof_installation', 'name': 'Roof installation', 'slug': 'roof_installation', 'description': 'Roofing sheets, trusses and installation', 'sort_order': 1},
      {'id': 'roofing_ceiling_work', 'name': 'Ceiling work', 'slug': 'ceiling_work', 'description': 'PVC, POP and panel ceilings', 'sort_order': 2},
      {'id': 'roofing_roof_leak_repair', 'name': 'Roof leak repair', 'slug': 'roof_leak_repair', 'description': 'Leak tracing and roof patching', 'sort_order': 3},
    ],
  },
  {
    'id': 'hvac',
    'name': 'HVAC & Refrigeration',
    'slug': 'hvac',
    'icon_name': 'snowflake',
    'color_hex': '#2196F3',
    'description': 'Cooling, refrigeration and ventilation',
    'sort_order': 11,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'hvac_ac_service', 'name': 'AC service', 'slug': 'ac_service', 'description': 'Air conditioners and cooling units', 'sort_order': 1},
      {'id': 'hvac_refrigeration', 'name': 'Refrigeration', 'slug': 'refrigeration', 'description': 'Fridges, freezers and cold rooms', 'sort_order': 2},
      {'id': 'hvac_ventilation', 'name': 'Ventilation', 'slug': 'ventilation', 'description': 'Fans, ducts and airflow', 'sort_order': 3},
    ],
  },
  {
    'id': 'appliance_repair',
    'name': 'Appliance & Electronics Repair',
    'slug': 'appliance_repair',
    'icon_name': 'plug',
    'color_hex': '#3F51B5',
    'description': 'Home appliances, electronics and diagnostics',
    'sort_order': 12,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'appliance_repair_kitchen_appliances', 'name': 'Kitchen appliances', 'slug': 'kitchen_appliances', 'description': 'Cookers, blenders, microwaves and kettles', 'sort_order': 1},
      {'id': 'appliance_repair_laundry_appliances', 'name': 'Laundry appliances', 'slug': 'laundry_appliances', 'description': 'Washing machines and irons', 'sort_order': 2},
      {'id': 'appliance_repair_electronics_repair', 'name': 'Electronics repair', 'slug': 'electronics_repair', 'description': 'TVs, audio and household electronics', 'sort_order': 3},
    ],
  },
  {
    'id': 'cleaning',
    'name': 'Cleaning',
    'slug': 'cleaning',
    'icon_name': 'broom',
    'color_hex': '#00A86B',
    'description': 'Home, office and deep cleaning',
    'sort_order': 13,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'cleaning_deep_clean', 'name': 'Deep clean', 'slug': 'deep_clean', 'description': 'Home and office deep cleaning', 'sort_order': 1},
      {'id': 'cleaning_move_in_out', 'name': 'Move-in/out', 'slug': 'move_in_out', 'description': 'Full property clean', 'sort_order': 2},
      {'id': 'cleaning_fumigation_pest_control', 'name': 'Fumigation & pest control', 'slug': 'fumigation_pest_control', 'description': 'Pest control and fumigation', 'sort_order': 3},
    ],
  },
  {
    'id': 'landscaping',
    'name': 'Landscaping',
    'slug': 'landscaping',
    'icon_name': 'mountains',
    'color_hex': '#4CAF50',
    'description': 'Lawn, garden and outdoor maintenance',
    'sort_order': 14,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'landscaping_lawn_care', 'name': 'Lawn care', 'slug': 'lawn_care', 'description': 'Mowing and trimming', 'sort_order': 1},
      {'id': 'landscaping_garden_design', 'name': 'Garden design', 'slug': 'garden_design', 'description': 'Plants and layout', 'sort_order': 2},
      {'id': 'landscaping_compound_cleanup', 'name': 'Compound cleanup', 'slug': 'compound_cleanup', 'description': 'Weeding and outdoor clearing', 'sort_order': 3},
    ],
  },
  {
    'id': 'fashion',
    'name': 'Fashion & Dressmaking',
    'slug': 'fashion',
    'icon_name': 'scissors',
    'color_hex': '#E91E63',
    'description': 'Tailoring, alterations and garment making',
    'sort_order': 15,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'fashion_dressmaking', 'name': 'Dressmaking', 'slug': 'dressmaking', 'description': 'New garments and custom outfits', 'sort_order': 1},
      {'id': 'fashion_alterations', 'name': 'Alterations', 'slug': 'alterations', 'description': 'Resizing, repairs and adjustments', 'sort_order': 2},
      {'id': 'fashion_school_work_uniforms', 'name': 'School & work uniforms', 'slug': 'school_work_uniforms', 'description': 'Uniform sewing and repairs', 'sort_order': 3},
    ],
  },
  {
    'id': 'beauty',
    'name': 'Hair & Beauty',
    'slug': 'beauty',
    'icon_name': 'scissors',
    'color_hex': '#AD1457',
    'description': 'Hairdressing, barbering and beauty services',
    'sort_order': 16,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'beauty_hairdressing', 'name': 'Hairdressing', 'slug': 'hairdressing', 'description': 'Braids, styling and treatments', 'sort_order': 1},
      {'id': 'beauty_barbering', 'name': 'Barbering', 'slug': 'barbering', 'description': 'Haircuts, grooming and shaving', 'sort_order': 2},
      {'id': 'beauty_makeup_nails', 'name': 'Makeup & nails', 'slug': 'makeup_nails', 'description': 'Makeup, nails and beauty prep', 'sort_order': 3},
    ],
  },
  {
    'id': 'catering',
    'name': 'Catering & Events',
    'slug': 'catering',
    'icon_name': 'fork_knife',
    'color_hex': '#C15A3D',
    'description': 'Cooking, baking and event food services',
    'sort_order': 17,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'catering_home_cooking', 'name': 'Home cooking', 'slug': 'home_cooking', 'description': 'Home meals and small gatherings', 'sort_order': 1},
      {'id': 'catering_baking', 'name': 'Baking', 'slug': 'baking', 'description': 'Cakes, pastries and baked goods', 'sort_order': 2},
      {'id': 'catering_event_catering', 'name': 'Event catering', 'slug': 'event_catering', 'description': 'Food for parties and events', 'sort_order': 3},
    ],
  },
  {
    'id': 'upholstery',
    'name': 'Upholstery',
    'slug': 'upholstery',
    'icon_name': 'armchair',
    'color_hex': '#6D4C41',
    'description': 'Sofas, cushions, curtains and soft furnishings',
    'sort_order': 18,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'upholstery_sofa_repair', 'name': 'Sofa repair', 'slug': 'sofa_repair', 'description': 'Sofa frames, cushions and covering', 'sort_order': 1},
      {'id': 'upholstery_curtains_blinds', 'name': 'Curtains & blinds', 'slug': 'curtains_blinds', 'description': 'Curtain sewing and blind fitting', 'sort_order': 2},
      {'id': 'upholstery_cushions_covers', 'name': 'Cushions & covers', 'slug': 'cushions_covers', 'description': 'Cushions, covers and soft furnishings', 'sort_order': 3},
    ],
  },
  {
    'id': 'security',
    'name': 'Security & Locksmith',
    'slug': 'security',
    'icon_name': 'lock_key',
    'color_hex': '#455A64',
    'description': 'Locks, keys, burglar proofing and access repairs',
    'sort_order': 19,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'security_locksmith', 'name': 'Locksmith', 'slug': 'locksmith', 'description': 'Keys, locks and lockouts', 'sort_order': 1},
      {'id': 'security_burglar_proofing', 'name': 'Burglar proofing', 'slug': 'security_burglar_proofing', 'description': 'Security bars and metal protection', 'sort_order': 2},
      {'id': 'security_cctv_access', 'name': 'CCTV & access', 'slug': 'cctv_access', 'description': 'Cameras, doorbells and access support', 'sort_order': 3},
    ],
  },
  {
    'id': 'ict_support',
    'name': 'ICT & Device Support',
    'slug': 'ict_support',
    'icon_name': 'desktop_tower',
    'color_hex': '#1565C0',
    'description': 'Computer, phone, network and device support',
    'sort_order': 20,
    'subcategories': <Map<String, dynamic>>[
      {'id': 'ict_support_computer_repair', 'name': 'Computer repair', 'slug': 'computer_repair', 'description': 'Laptops, desktops and software setup', 'sort_order': 1},
      {'id': 'ict_support_phone_repair', 'name': 'Phone repair', 'slug': 'phone_repair', 'description': 'Phones, screens and accessories', 'sort_order': 2},
      {'id': 'ict_support_network_setup', 'name': 'Network setup', 'slug': 'network_setup', 'description': 'Routers, Wi-Fi and small office networks', 'sort_order': 3},
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
