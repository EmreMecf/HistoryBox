import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _initialized = false;
  RewardedAd? _cachedRewardedAd;
  InterstitialAd? _cachedInterstitialAd;
  BannerAd? _cachedBannerAd;
  bool _isBannerLoaded = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();

    _preloadRewardedAd();
    _preloadInterstitialAd();
    _preloadBannerAd();

    _initialized = true;
    print('AdMob reklam servisi başlatıldı');
  }

  void _preloadRewardedAd() {
    RewardedAd.load(
      adUnitId: _getAdMobRewardedId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('Rewarded reklam önceden yüklendi');
          _cachedRewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Rewarded reklam önceden yüklenemedi: $error');
          _cachedRewardedAd = null;
          Future.delayed(const Duration(minutes: 1), _preloadRewardedAd);
        },
      ),
    );
  }

  void _preloadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _getAdMobInterstitialId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('Interstitial reklam önceden yüklendi');
          _cachedInterstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Interstitial reklam önceden yüklenemedi: $error');
          _cachedInterstitialAd = null;
          Future.delayed(const Duration(minutes: 1), _preloadInterstitialAd);
        },
      ),
    );
  }

  void _preloadBannerAd() {
    _cachedBannerAd?.dispose();
    _isBannerLoaded = false;

    BannerAd? preloadBannerAd;

    try {
      preloadBannerAd = BannerAd(
        adUnitId: _getAdMobBannerId(),
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Banner reklam önceden yüklendi');
            _cachedBannerAd = preloadBannerAd;
            _isBannerLoaded = true;
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Banner reklam önceden yüklenemedi: $error');
            ad.dispose();
            _cachedBannerAd = null;
            _isBannerLoaded = false;
            Future.delayed(const Duration(minutes: 1), _preloadBannerAd);
          },
        ),
      );

      preloadBannerAd.load();
    } catch (e) {
      print('Banner reklamı ön yüklemede hata: $e');
      preloadBannerAd?.dispose();
    }
  }

  Future<Widget?> loadBannerAd() async {
    if (!_initialized) {
      await initialize();
    }

    if (_isBannerLoaded && _cachedBannerAd != null) {
      return Container(
        height: _cachedBannerAd!.size.height.toDouble(),
        width: _cachedBannerAd!.size.width.toDouble(),
        child: AdWidget(ad: _cachedBannerAd!),
      );
    }

    final completer = Completer<Widget?>();
    BannerAd? loadedBannerAd;

    try {
      loadedBannerAd = BannerAd(
        adUnitId: _getAdMobBannerId(),
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('Banner reklam yüklendi');
            _cachedBannerAd = loadedBannerAd;
            _isBannerLoaded = true;
            if (!completer.isCompleted) {
              completer.complete(
                Container(
                  height: loadedBannerAd!.size.height.toDouble(),
                  width: loadedBannerAd.size.width.toDouble(),
                  child: AdWidget(ad: loadedBannerAd),
                ),
              );
            }
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Banner reklam yüklenemedi: $error');
            ad.dispose();
            _cachedBannerAd = null;
            _isBannerLoaded = false;
            if (!completer.isCompleted) {
              completer.complete(null);
            }
            Future.delayed(const Duration(minutes: 1), _preloadBannerAd);
          },
        ),
      );

      await loadedBannerAd.load();
      return await completer.future;
    } catch (e) {
      print('Banner reklamı yüklenirken hata: $e');
      loadedBannerAd?.dispose();
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return null;
    }
  }

  Future<void> showRewardedAd({required Function onRewarded}) async {
    bool rewardEarned = false;

    if (_cachedRewardedAd != null) {
      final ad = _cachedRewardedAd!;
      _cachedRewardedAd = null;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('Rewarded reklam kapatıldı');
          if (rewardEarned) {
            onRewarded();
          }
          ad.dispose();
          _preloadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Rewarded gösterim hatası: $error');
          ad.dispose();
          _preloadRewardedAd();
        },
      );

      ad.show(
        onUserEarnedReward: (_, reward) {
          print('Ödül kazanıldı: ${reward.amount}');
          rewardEarned = true;
        },
      );
      print('Rewarded gösteriliyor');
    } else {
      print('Rewarded reklam yükleniyor (cache boş)...');
      await RewardedAd.load(
        adUnitId: _getAdMobRewardedId(),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                print('Rewarded reklam kapatıldı');
                if (rewardEarned) {
                  onRewarded();
                }
                ad.dispose();
                _preloadRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('Rewarded gösterim hatası: $error');
                ad.dispose();
                _preloadRewardedAd();
              },
            );

            ad.show(
              onUserEarnedReward: (_, reward) {
                print('Ödül kazanıldı: ${reward.amount}');
                rewardEarned = true;
              },
            );
            print('Rewarded gösteriliyor');
          },
          onAdFailedToLoad: (error) {
            print('Rewarded yüklenemedi: $error');
            Future.delayed(const Duration(seconds: 30), _preloadRewardedAd);
          },
        ),
      );
    }
  }

  Future<void> showInterstitialAd() async {
    if (_cachedInterstitialAd != null) {
      final ad = _cachedInterstitialAd!;
      _cachedInterstitialAd = null;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('Interstitial reklam kapatıldı');
          ad.dispose();
          _preloadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Interstitial gösterim hatası: $error');
          ad.dispose();
          _preloadInterstitialAd();
        },
      );

      ad.show();
      print('Interstitial gösteriliyor');
    } else {
      print('Interstitial reklam yükleniyor (cache boş)...');
      await InterstitialAd.load(
        adUnitId: _getAdMobInterstitialId(),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                print('Interstitial reklam kapatıldı');
                ad.dispose();
                _preloadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('Interstitial gösterim hatası: $error');
                ad.dispose();
                _preloadInterstitialAd();
              },
            );

            ad.show();
            print('Interstitial gösteriliyor');
          },
          onAdFailedToLoad: (error) {
            print('Interstitial yüklenemedi: $error');
            Future.delayed(const Duration(seconds: 30), _preloadInterstitialAd);
          },
        ),
      );
    }
  }

  void dispose() {
    _cachedRewardedAd?.dispose();
    _cachedInterstitialAd?.dispose();
    _cachedBannerAd?.dispose();

    _cachedRewardedAd = null;
    _cachedInterstitialAd = null;
    _cachedBannerAd = null;
    _isBannerLoaded = false;
  }

  String _getAdMobBannerId() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  String _getAdMobInterstitialId() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  String _getAdMobRewardedId() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }
}
