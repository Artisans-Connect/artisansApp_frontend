/// Cache key prefixes and TTLs for API responses.
abstract final class CacheKeys {
  static const String profileMe = 'profile:me';
  static const String categories = 'categories:all';
  static const String jobsMinePrefix = 'jobs:mine';
  static const String chatConversations = 'chat:conversations';
  static const String explorePrefix = 'explore:nearby';

  static const Duration profileTtl = Duration(minutes: 30);
  static const Duration categoriesTtl = Duration(hours: 24);
  static const Duration jobsTtl = Duration(minutes: 5);
  static const Duration chatTtl = Duration(minutes: 3);
  static const Duration exploreTtl = Duration(minutes: 10);

  static String jobsMine({String? status}) =>
      status == null || status.isEmpty
          ? '$jobsMinePrefix:all'
          : '$jobsMinePrefix:status=$status';

  static String exploreNearby({
    String? categoryId,
    double? lat,
    double? lng,
    double radiusKm = 5,
    int limit = 20,
  }) {
    final String latKey = lat != null ? lat.toStringAsFixed(2) : '';
    final String lngKey = lng != null ? lng.toStringAsFixed(2) : '';
    return '$explorePrefix:${categoryId ?? ''}:$latKey:$lngKey:$radiusKm:$limit';
  }

  /// Keys cleared on sign-out (user-specific data).
  static const List<String> userScopedPrefixes = <String>[
    'profile:',
    'jobs:',
    'chat:',
    'explore:',
  ];
}
