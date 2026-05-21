import 'package:flutter/material.dart';

import '../../../../core/widgets/network_image_box.dart';
import '../../domain/entities/home_banner_entity.dart';

class HomePromoCarousel extends StatefulWidget {
  const HomePromoCarousel({
    super.key,
    required this.sliders,
    required this.couponBanners,
  });

  final List<HomeSliderEntity> sliders;
  final List<HomeBannerEntity> couponBanners;

  @override
  State<HomePromoCarousel> createState() => _HomePromoCarouselState();
}

class _HomePromoCarouselState extends State<HomePromoCarousel> {
  late final PageController _controller;
  int _page = 0;

  List<String> get _images {
    if (widget.sliders.isNotEmpty) {
      return widget.sliders
          .map((e) => e.image)
          .whereType<String>()
          .where((url) => url.isNotEmpty)
          .toList();
    }
    return widget.couponBanners
        .map((e) => e.promotionImage)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: NetworkImageBox(
                    url: images[i],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (i) {
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
        const SizedBox(height: 8),
      ],
    );
  }
}
