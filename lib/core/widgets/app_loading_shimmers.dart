import 'package:flutter/material.dart';

import 'app_shimmer.dart';

/// Skeleton row matching [RestaurantCard] layout (~70dp image + text column).
class RestaurantListShimmer extends StatelessWidget {
  const RestaurantListShimmer({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 80, height: 80, borderRadius: 5),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: ShimmerBox(
                                width: double.infinity,
                                height: 18,
                                borderRadius: 4,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const ShimmerBox(width: 36, height: 20, borderRadius: 2),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const ShimmerBox(width: double.infinity, height: 12, borderRadius: 4),
                        const SizedBox(height: 8),
                        const ShimmerBox(width: 120, height: 12, borderRadius: 4),
                        const SizedBox(height: 8),
                        const ShimmerBox(width: 180, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 2-column category grid placeholder.
class CategoryGridShimmer extends StatelessWidget {
  const CategoryGridShimmer({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ShimmerBox(width: 75, height: 75, borderRadius: 40),
            const SizedBox(height: 10),
            const ShimmerBox(width: 100, height: 14, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

class OrdersListShimmer extends StatelessWidget {
  const OrdersListShimmer({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const ShimmerBox(width: 56, height: 56, borderRadius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerBox(width: double.infinity, height: 16, borderRadius: 4),
                      const SizedBox(height: 8),
                      const ShimmerBox(width: 140, height: 12, borderRadius: 4),
                      const SizedBox(height: 6),
                      const ShimmerBox(width: 100, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CartPageShimmer extends StatelessWidget {
  const CartPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const ShimmerBox(width: double.infinity, height: 22, borderRadius: 4),
          const SizedBox(height: 16),
          for (var i = 0; i < 4; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 64, height: 64, borderRadius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
                      const SizedBox(height: 8),
                      const ShimmerBox(width: 120, height: 12, borderRadius: 4),
                      const SizedBox(height: 12),
                      const ShimmerBox(width: 80, height: 28, borderRadius: 6),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

/// Restaurant detail first paint: banner + search + menu rows.
class RestaurantDetailShimmer extends StatelessWidget {
  const RestaurantDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const ShimmerBox(width: double.infinity, height: 140, borderRadius: 16),
          const SizedBox(height: 12),
          const ShimmerBox(width: double.infinity, height: 48, borderRadius: 28),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 36,
                  borderRadius: 5,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 36,
                  borderRadius: 5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerBox(width: 120, height: 32, borderRadius: 20),
          const SizedBox(height: 16),
          for (var i = 0; i < 8; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 72, height: 72, borderRadius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerBox(width: double.infinity, height: 16, borderRadius: 4),
                      const SizedBox(height: 8),
                      const ShimmerBox(width: 160, height: 12, borderRadius: 4),
                      const SizedBox(height: 12),
                      const ShimmerBox(width: 56, height: 28, borderRadius: 6),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class ListFooterShimmer extends StatelessWidget {
  const ListFooterShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: AppShimmer(
        child: const ShimmerBox(width: double.infinity, height: 36, borderRadius: 8),
      ),
    );
  }
}

class PaymentOptionsShimmer extends StatelessWidget {
  const PaymentOptionsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const ShimmerBox(width: 200, height: 20, borderRadius: 4),
          const SizedBox(height: 24),
          for (var i = 0; i < 4; i++) ...[
            const ShimmerBox(width: double.infinity, height: 56, borderRadius: 12),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
