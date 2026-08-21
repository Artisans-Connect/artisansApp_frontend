import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/location/device_location_service.dart';
import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/widgets/custom_app_bar.dart';
import 'package:artisans_app/shared/widgets/search_bar.dart';
import 'package:artisans_app/features/client/presentation/navigation/client_navigation.dart';
import 'package:artisans_app/features/client/services/explore_service.dart';
import 'package:artisans_app/features/client/presentation/widgets/explore/artisan_list_item.dart';
import 'package:artisans_app/features/client/presentation/widgets/explore/explore_empty_state.dart';
import 'package:artisans_app/features/client/presentation/widgets/explore/explore_filter_bar.dart';
import 'package:artisans_app/core/services/smart_search_service.dart';

class ExploreArtisansScreen extends StatefulWidget {
  const ExploreArtisansScreen({
    super.key,
    this.initialQuery = '',
    this.initialCategory = '',
    this.initialCategoryId = '',
    this.initialCategoryIds = const <String>[],
    this.initialCategories = const <String>[],
    this.intentSummary,
  });

  final String initialQuery;
  final String initialCategory;
  final String initialCategoryId;
  final List<String> initialCategoryIds;
  final List<String> initialCategories;
  final String? intentSummary;

  @override
  State<ExploreArtisansScreen> createState() => _ExploreArtisansScreenState();
}

class _ExploreArtisansScreenState extends State<ExploreArtisansScreen> {
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedCategoryId = '';
  String _selectedDistance = '';
  String _selectedRating = '';
  late final TextEditingController _searchController;

  List<String> _categoryIds = [];
  List<String> _categoryNames = [];
  String? _intentSummary;

  List<Map<String, dynamic>> allArtisans = [];
  bool _isLoading = true;
  bool _isParsingIntent = false;
  bool _openingMap = false;
  bool _openingMessages = false;
  final Set<String> _openingChatWorkerIds = <String>{};

  Future<void> _triggerSmartIntent() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty || _isParsingIntent) return;

    setState(() => _isParsingIntent = true);
    try {
      final SmartSearchIntent intent =
          await SmartSearchService.instance.parseIntent(query);
      if (!mounted) return;
      setState(() {
        _isParsingIntent = false;
        _searchQuery = intent.refinedQuery;
        _categoryIds = intent.categoryIds;
        _categoryNames = intent.categoryNames;
        _intentSummary =
            intent.intentSummary.isNotEmpty ? intent.intentSummary : null;
        _isLoading = true;
      });
      await _fetchArtisans();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isParsingIntent = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery;
    _selectedCategory = widget.initialCategory;
    _selectedCategoryId = widget.initialCategoryId;
    _categoryIds = List<String>.from(widget.initialCategoryIds);
    _categoryNames = List<String>.from(widget.initialCategories);
    _intentSummary = widget.intentSummary;
    _searchController = TextEditingController(text: _searchQuery);
    _fetchArtisans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchArtisans() async {
    try {
      final loc = await DeviceLocationService.getCurrentOrDefault();
      List<Map<String, dynamic>> rawArtisans = [];

      if (_categoryIds.isNotEmpty) {
        // Query artisans for each category ID concurrently
        final List<List<Map<String, dynamic>>> results = await Future.wait(
          _categoryIds.map((String id) => ExploreService.instance.getArtisans(
            limit: 50,
            radiusKm: 30,
            lat: loc.latitude,
            lng: loc.longitude,
            categoryId: id,
            forceRefresh: true,
          )),
        );

        // Merge results and remove duplicates, prioritizing nearby/available matches
        final Map<String, Map<String, dynamic>> workerMap = {};
        for (final List<Map<String, dynamic>> list in results) {
          for (final Map<String, dynamic> worker in list) {
            final String workerId = (worker['id'] ?? worker['worker_id'] ?? '').toString();
            if (workerId.isNotEmpty) {
              workerMap[workerId] = worker;
            }
          }
        }
        rawArtisans = workerMap.values.toList();

        // If no nearby artisans found with location, fetch without location bounds
        if (rawArtisans.isEmpty) {
          final List<List<Map<String, dynamic>>> fallbackResults = await Future.wait(
            _categoryIds.map((String id) => ExploreService.instance.getArtisans(
              limit: 50,
              categoryId: id,
              forceRefresh: true,
            )),
          );
          for (final List<Map<String, dynamic>> list in fallbackResults) {
            for (final Map<String, dynamic> worker in list) {
              final String workerId = (worker['id'] ?? worker['worker_id'] ?? '').toString();
              if (workerId.isNotEmpty) {
                workerMap[workerId] = worker;
              }
            }
          }
          rawArtisans = workerMap.values.toList();
        }
      } else {
        // Normal single category/general nearby search
        rawArtisans = await ExploreService.instance.getArtisans(
          limit: 50,
          radiusKm: 30,
          lat: loc.latitude,
          lng: loc.longitude,
          categoryId: _selectedCategoryId.isNotEmpty ? _selectedCategoryId : null,
          forceRefresh: true,
          onRefreshed: (List<Map<String, dynamic>> freshArtisans) {
            if (!mounted) return;
            // Only update on cache refresh if we are not in multi-intent search
            if (_categoryIds.isEmpty) {
              setState(() => allArtisans = _mapArtisans(freshArtisans));
            }
          },
        );
        if (rawArtisans.isEmpty) {
          rawArtisans = await ExploreService.instance.getArtisans(
            limit: 50,
            categoryId: _selectedCategoryId.isNotEmpty ? _selectedCategoryId : null,
            forceRefresh: true,
          );
        }
      }

      final mappedArtisans = _mapArtisans(rawArtisans);

      if (mounted) {
        setState(() {
          allArtisans = mappedArtisans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _mapArtisans(List<Map<String, dynamic>> rawArtisans) {
    return rawArtisans.map((raw) {
      final profile = raw['profiles'] as Map<String, dynamic>? ?? {};
      final name = profile['full_name'] as String? ?? 'Artisan';
      final imageUrl = profile['avatar_url'] as String? ?? '';
      final skills = raw['skills'] as List<dynamic>? ?? [];
      final profession = skills.isNotEmpty ? skills.first.toString() : 'Professional';
      final rating = (raw['rating'] as num?)?.toDouble() ?? 0.0;
      final userId = raw['id'] as String;
      final distanceKm = (raw['distance_km'] as num?)?.toDouble();

      return {
        'name': name,
        'profession': profession,
        'rating': rating,
        'reviewCount': 0,
        'imageUrl': imageUrl,
        'location': (profile['location_label'] ?? 'Location not set').toString(),
        'distance': distanceKm != null ? '${distanceKm.toStringAsFixed(1)} km' : '',
        'distanceKm': distanceKm,
        'isAvailable': raw['is_available'] == true,
        'isVerified': raw['is_verified'] == true,
        'bio': profile['bio'],
        'userId': userId,
        'id': userId,
        'phone': profile['phone'],
        'skills': skills.map((dynamic item) => item.toString()).toList(),
        'profiles': profile,
      };
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedDistance = '';
      _selectedRating = '';
      _intentSummary = null;
      _categoryIds = const <String>[];
      _categoryNames = const <String>[];
      _searchController.clear();
    });
  }

  Future<void> _showAllArtisans() async {
    setState(() {
      _selectedCategory = '';
      _selectedCategoryId = '';
      _selectedDistance = '';
      _selectedRating = '';
      _searchQuery = '';
      _intentSummary = null;
      _categoryIds = const <String>[];
      _categoryNames = const <String>[];
      _searchController.clear();
      _isLoading = true;
    });
    await _fetchArtisans();
  }

  List<Map<String, dynamic>> get _filteredArtisans {
    return allArtisans.where((Map<String, dynamic> artisan) {
      final Map<String, dynamic> profile = Map<String, dynamic>.from(
          artisan['profiles'] as Map<String, dynamic>? ??
              const <String, dynamic>{});
      final String name = (artisan['name'] as String? ?? '').toLowerCase();
      final String fullName =
          (profile['full_name'] ?? artisan['name'] ?? profile['name'] ?? '')
              .toString()
              .toLowerCase();
      final String businessName =
          (profile['business_name'] ?? artisan['business_name'] ?? '')
              .toString()
              .toLowerCase();
      final String profession =
          (artisan['profession'] as String? ?? profile['profession'] as String? ?? '')
              .toLowerCase();
      final List<String> skills =
          (artisan['skills'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic item) => item.toString().toLowerCase())
              .toList();
      final String skillText = skills.join(' ');
      final String trimmedQuery = _searchQuery.trim().toLowerCase();

      // Bypass simple text match if this was parsed by AI into categories
      if (trimmedQuery.isNotEmpty && _intentSummary == null) {
        final List<String> queryParts = trimmedQuery.split(RegExp(r'\s+'));
        for (final String part in queryParts) {
          if (!name.contains(part) &&
              !fullName.contains(part) &&
              !businessName.contains(part) &&
              !profession.contains(part) &&
              !skillText.contains(part)) {
            return false;
          }
        }
      }
      if (_selectedCategory.isNotEmpty && _selectedCategoryId.isEmpty) {
        final String category = _selectedCategory.toLowerCase();
        if (!profession.contains(category) && !skillText.contains(category)) {
          return false;
        }
      }
      if (_selectedRating.isNotEmpty) {
        final double minRating =
            double.tryParse(_selectedRating.replaceAll('+', '')) ?? 0;
        final double rating = (artisan['rating'] as num?)?.toDouble() ?? 0;
        if (rating < minRating) return false;
      }
      if (_selectedDistance.isNotEmpty && _selectedDistance != 'Nearby') {
        final double? distance = artisan['distanceKm'] as double?;
        if (distance == null) return false;
        final double maxDistance = double.tryParse(
              _selectedDistance.replaceAll(RegExp(r'[^0-9.]'), ''),
            ) ??
            double.infinity;
        if (distance > maxDistance) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _openMap() async {
    if (_openingMap) return;
    setState(() => _openingMap = true);
    await ClientNavigation.pushFlow(context, AppRoutes.mapDiscovery);
    if (mounted) setState(() => _openingMap = false);
  }

  void _openMessages() {
    if (_openingMessages) return;
    setState(() => _openingMessages = true);
    ClientNavigation.openMessages(context);
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _openingMessages = false);
    });
  }

  Future<void> _openChat(Map<String, dynamic> artisan) async {
    final String workerId = (artisan['id'] ?? artisan['userId'] ?? '').toString();
    if (_openingChatWorkerIds.contains(workerId)) return;
    setState(() => _openingChatWorkerIds.add(workerId));
    await ClientNavigation.openChatForArtisan(context, artisan);
    if (mounted) setState(() => _openingChatWorkerIds.remove(workerId));
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> artisans = _filteredArtisans;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Explore Artisans',
        onBackPressed: () => Navigator.pop(context),
        actions: <Widget>[
          IconButton(
            tooltip: 'Map view',
            onPressed: _openingMap ? null : _openMap,
            icon: _openingMap
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(PhosphorIcons.mapTrifold, color: AppColors.textPrimary),
          ),
          IconButton(
            tooltip: 'Messages',
            onPressed: _openingMessages ? null : _openMessages,
            icon: _openingMessages
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    PhosphorIcons.chatCircle,
                    color: AppColors.textPrimary,
                  ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isLoading = true);
          await _fetchArtisans();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _selectedCategory.isEmpty
                    ? 'Browse skilled artisans'
                    : 'Browse $_selectedCategory artisans',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Verified and available artisans appear first, with nearby matches prioritized when location is available.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              CustomSearchBar(
                hintText: 'Search by name or skill...',
                controller: _searchController,
                isLoading: _isParsingIntent,
                showAiButton: true,
                onAiTap: _triggerSmartIntent,
                onSearch: _triggerSmartIntent,
                onChanged: (String value) {
                  setState(() {
                    _searchQuery = value;
                    _intentSummary = null;
                    _categoryIds = const <String>[];
                    _categoryNames = const <String>[];
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              ExploreFilterBar(
                selectedCategory: _selectedCategory,
                selectedDistance: _selectedDistance,
                selectedRating: _selectedRating,
                onClearCategory: () {
                  setState(() {
                    _selectedCategory = '';
                    _selectedCategoryId = '';
                    _isLoading = true;
                  });
                  _fetchArtisans();
                },
                onDistanceSelected: (String value) {
                  setState(() {
                    _selectedDistance =
                        _selectedDistance == value ? '' : value;
                  });
                },
                onRatingSelected: (String value) {
                  setState(() {
                    _selectedRating = _selectedRating == value ? '' : value;
                  });
                },
                onClearFilters: _showAllArtisans,
                onShowAll: _showAllArtisans,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_intentSummary != null && _intentSummary!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.lightning,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Showing results for: "$_intentSummary"',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_categoryNames.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: AppSpacing.xs,
                                children: _categoryNames.map((catName) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                  ),
                                  child: Text(
                                    catName,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.x, color: AppColors.primary, size: 18),
                        onPressed: () {
                          setState(() {
                            _intentSummary = null;
                            _categoryIds = const <String>[];
                            _categoryNames = const <String>[];
                            _searchQuery = '';
                            _searchController.clear();
                            _isLoading = true;
                          });
                          _fetchArtisans();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              if (!_isLoading)
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${artisans.length} ${artisans.length == 1 ? 'Artisan' : 'Artisans'} Found',
                        style: AppTypography.labelLarge,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty ||
                        _selectedDistance.isNotEmpty ||
                        _selectedRating.isNotEmpty)
                      TextButton.icon(
                        onPressed: _clearFilters,
                        icon: Icon(PhosphorIcons.x, size: 16),
                        label: const Text('Clear'),
                      ),
                  ],
                ),
              if (!_isLoading)
                const SizedBox(height: AppSpacing.md),
              if (!_isLoading && artisans.isEmpty)
                ExploreEmptyState(
                  hasCategory: _selectedCategory.isNotEmpty,
                  onClearFilters: _clearFilters,
                  onShowAll: _showAllArtisans,
                ),
              if (!_isLoading)
                ...artisans.map((Map<String, dynamic> artisan) {
                  final String workerId = (artisan['id'] ?? artisan['userId'] ?? '').toString();
                  final bool openingChat = _openingChatWorkerIds.contains(workerId);
                  return ArtisanListItem(
                    artisan: artisan,
                    openingChat: openingChat,
                    onOpenChat: () => _openChat(artisan),
                  );
                }),
              ],
          ),
        ),
      ),
      ),
    );
  }
}


