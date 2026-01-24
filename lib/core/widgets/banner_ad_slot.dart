import 'package:flutter/material.dart';
import '../core.dart';
import '../../services/advert/ad_service.dart';

class BannerAdSlot extends StatefulWidget {
  final EdgeInsets? margin;

  const BannerAdSlot({super.key, this.margin});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  Future<Widget?>? _adFuture;

  @override
  void initState() {
    super.initState();
    _adFuture = AdService().loadBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget?>(
      future: _adFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final adWidget = snapshot.data;
        if (adWidget == null) {
          return const SizedBox.shrink();
        }
        return Container(
          alignment: Alignment.center,
          margin: widget.margin ??
              const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
          child: adWidget,
        );
      },
    );
  }
}
