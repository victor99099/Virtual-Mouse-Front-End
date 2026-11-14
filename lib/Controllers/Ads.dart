import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;

  void loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-9161012727067749/1765867914', // Test Ad Unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          print("Interstitial Ad Loaded!");
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("Failed to load interstitial ad: $error");
        },
      ),
    );
  }

  void showAd(Function onAdClosed) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print("Interstitial Ad Closed");
          ad.dispose();
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print("Failed to show ad: $error");
          ad.dispose();
          onAdClosed();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null; // Load a new ad after showing
    } else {
      print("No ad available.");
      onAdClosed();
    }
  }
}

class NativeAdManager {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  bool get isAdLoaded => _isAdLoaded;
  NativeAd? get nativeAd => _nativeAd;

  void loadNativeAd(VoidCallback onAdLoaded) {
    _nativeAd = NativeAd(
      adUnitId: "ca-app-pub-9161012727067749/4419951417",
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isAdLoaded = true;
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          print('Native Ad failed to load: $error');
          _isAdLoaded = false;
          ad.dispose();
        },
      ),
      factoryId: 'nativeAdFactory',
      request: AdRequest(),
    )..load();
  }

  void disposeAd() {
    _nativeAd?.dispose();
    _isAdLoaded = false;
  }
}
class NativeAdManager2 {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  bool get isAdLoaded => _isAdLoaded;
  NativeAd? get nativeAd => _nativeAd;

  void loadNativeAd(VoidCallback onAdLoaded) {
    _nativeAd = NativeAd(
      adUnitId: "ca-app-pub-9161012727067749/4419951417",
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isAdLoaded = true;
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          print('Native Ad failed to load: $error');
          _isAdLoaded = false;
          ad.dispose();
        },
      ),
      factoryId: 'nativeAdFactory',
      request: AdRequest(),
    )..load();
  }

  void disposeAd() {
    _nativeAd?.dispose();
    _isAdLoaded = false;
  }
}
