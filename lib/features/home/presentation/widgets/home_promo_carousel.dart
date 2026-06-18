import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/navigation/restaurant_navigation.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../catalog/domain/entities/restaurant_entity.dart';
import '../../domain/entities/home_banner_entity.dart';

/// Coupon promo banners (`available_coupons`) — matches Android `homeAdBanner`.
class HomeCouponBannerCarousel extends StatelessWidget {
  const HomeCouponBannerCarousel({super.key, required this.banners});

  final List<HomeBannerEntity> banners;

  @override
  Widget build(BuildContext context) {
    final items = banners
        .where((b) => b.promotionImage?.trim().isNotEmpty == true)
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return _HomeImageCarousel(
      height: 140,
      itemCount: items.length,
      imageUrl: (i) => items[i].promotionImage,
      onTap: (i) {
        final banner = items[i];
        final id = banner.restaurantId?.trim();
        if (id == null || id.isEmpty) return;
        openRestaurantDetail(
          context,
          RestaurantEntity(
            id: id,
            name: banner.restaurantName ?? '',
            seoUrl: banner.restaurantSeoUrl ?? '',
          ),
        );
      },
    );
  }
}

/// Home page sliders (`customer/home_page_sliders`) — matches Android `homeSliderBanner`.
class HomeSliderCarousel extends StatelessWidget {
  const HomeSliderCarousel({super.key, required this.sliders});

  final List<HomeSliderEntity> sliders;

  @override
  Widget build(BuildContext context) {
    final items = sliders
        .where((s) => s.image?.trim().isNotEmpty == true)
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return _HomeImageCarousel(
      height: 120,
      itemCount: items.length,
      imageUrl: (i) => items[i].image,
      onTap: (i) async {
        final url = items[i].redirectionUrl?.trim();
        if (url == null || url.isEmpty || url == '1') return;
        final uri = Uri.tryParse(url);
        if (uri == null) return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
    );
  }
}

class _HomeImageCarousel extends StatefulWidget {
  const _HomeImageCarousel({
    required this.height,
    required this.itemCount,
    required this.imageUrl,
    this.onTap,
  });

  final double height;
  final int itemCount;
  final String? Function(int index) imageUrl;
  final void Function(int index)? onTap;

  @override
  State<_HomeImageCarousel> createState() => _HomeImageCarouselState();
}

class _HomeImageCarouselState extends State<_HomeImageCarousel> {
  late final PageController _controller;
  int _page = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.itemCount <= 1) return;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.itemCount;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant _HomeImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.itemCount,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final child = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: NetworkImageBox(
                    url: widget.imageUrl(i),
                    fit: BoxFit.cover,
                  ),
                ),
              );
              if (widget.onTap == null) return child;
              return GestureDetector(onTap: () => widget.onTap!(i), child: child);
            },
          ),
        ),
        if (widget.itemCount > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.itemCount, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF0349A9)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}
