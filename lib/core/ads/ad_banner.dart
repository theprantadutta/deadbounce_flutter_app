import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../logging/app_logger.dart';
import 'ad_service.dart';

/// An anchored adaptive banner for the meta screens.
///
/// **Renders nothing at all** until an ad actually loads — no placeholder, no
/// reserved gap. A grey rectangle where an ad failed to fill looks like a bug,
/// and reserving space that stays empty is worse than showing no banner.
///
/// Allowed on Leaderboards, Awards, Statistics and the Trick-Shot gallery only.
/// Never on Home (which must stay no-scroll / no-overflow), never in-run, and
/// never on the results screen.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key, required this.adService});

  final AdService adService;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unitId = widget.adService.bannerUnitId;
    // Null when the player bought no-ads, consent wasn't given, or no unit is
    // configured. All three mean "no banner", silently.
    if (unitId == null) return;

    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
      Orientation.portrait,
      MediaQuery.sizeOf(context).width.truncate(),
    );
    if (size == null || !mounted) return;

    final banner = BannerAd(
      adUnitId: unitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          AppLogger.talker.debug('[ads] banner failed: ${error.message}');
        },
      ),
    );
    _banner = banner;
    await banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (!_loaded || banner == null) return const SizedBox.shrink();

    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }
}
