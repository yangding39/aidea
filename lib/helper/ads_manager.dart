import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsManager {
  static final AdsManager _instance = AdsManager._internal();
  factory AdsManager() => _instance;
  AdsManager._internal();

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  // 使用测试广告单元ID
  static const String appOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921'; // Android测试开屏广告ID

  /// 加载开屏广告
  Future<void> loadAppOpenAd() async {
    print('开始加载开屏广告...');
    try {
      await AppOpenAd.load(
        adUnitId: appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            print('开屏广告加载成功');
            _appOpenAd = ad;
            showAppOpenAd();
          },
          onAdFailedToLoad: (error) {
            print('开屏广告加载失败: $error');
          },
        ),
      );
    } catch (e) {
      print('加载开屏广告时发生异常: $e');
    }
  }

  /// 显示开屏广告
  Future<void> showAppOpenAd() async {
    if (_appOpenAd == null || _isShowingAd) {
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
    );

    await _appOpenAd!.show();
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}
