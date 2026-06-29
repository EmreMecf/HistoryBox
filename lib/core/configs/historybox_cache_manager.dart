import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class HistoryBoxCacheManager {
  static const key = 'historyboxCache';
  
  static final HistoryBoxCacheManager instance = HistoryBoxCacheManager._();
  static CacheManager? _cacheManager;

  HistoryBoxCacheManager._();

  CacheManager get cacheManager {
    _cacheManager ??= CacheManager(
      Config(
        key,
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 100,
      ),
    );
    return _cacheManager!;
  }

  Future<void> clearCache() async {
    await cacheManager.emptyCache();
  }
}
