import 'package:askaide/helper/ads_manager.dart';
import 'package:askaide/page/home.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:askaide/helper/ability.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/repo/settings_repo.dart';

class SplashScreen extends StatefulWidget {
  final SettingRepository setting;
  const SplashScreen({super.key, required this.setting});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _countdown = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 初始化广告
    MobileAds.instance.initialize().then((initStatus) {
      AdsManager().loadAppOpenAd();
    });

    // 开始倒计时
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _timer?.cancel();
            _enterApp();
          }
        });
      }
    });
  }

  void _enterApp() {
    _timer?.cancel();
    if (mounted) {
      // 获取登录状态
      final apiServerToken = widget.setting.get(settingAPIServerToken);
      final usingGuestMode =
          widget.setting.boolDefault(settingUsingGuestMode, false);
      final openAISelfHosted =
          widget.setting.boolDefault(settingOpenAISelfHosted, false);
      final deepAISelfHosted =
          widget.setting.boolDefault(settingDeepAISelfHosted, false);
      final stabilityAISelfHosted =
          widget.setting.boolDefault(settingStabilityAISelfHosted, false);

      final shouldLogin = (apiServerToken == null || apiServerToken == '') &&
          !usingGuestMode &&
          !openAISelfHosted &&
          !deepAISelfHosted &&
          !stabilityAISelfHosted;

      // 根据登录状态决定跳转路径
      if (shouldLogin) {
        context.go('/login');
      } else {
        context.go('/');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/app.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              'AIdea',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _enterApp,
              child: Text('进入应用 ($_countdown)'),
            ),
          ],
        ),
      ),
    );
  }
}
