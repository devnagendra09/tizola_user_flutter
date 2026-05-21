import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/coupon_offer_entity.dart';
import '../../domain/repositories/cart_repository.dart';

/// Android `CouponFragment` — list + manual promo entry.
class CouponOffersPage extends StatefulWidget {
  const CouponOffersPage({super.key});

  @override
  State<CouponOffersPage> createState() => _CouponOffersPageState();
}

class _CouponOffersPageState extends State<CouponOffersPage> {
  final _promoController = TextEditingController();
  List<CouponOfferEntity> _coupons = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await sl<CartRepository>().fetchAvailableCoupons();
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _loading = false;
        _error = result.failure?.message ?? 'Failed to load offers';
      });
      return;
    }
    setState(() {
      _loading = false;
      _coupons = result.data ?? [];
    });
  }

  void _applyCode(String code) {
    if (code.trim().isEmpty) {
      setState(() => _error = 'Please enter coupon code!');
      return;
    }
    Navigator.of(context).pop(code.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: CartPageShimmer(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          decoration: InputDecoration(
                            hintText: 'Enter promo code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _applyCode(_promoController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                Expanded(
                  child: _coupons.isEmpty
                      ? Center(
                          child: Text(
                            _error ?? 'No coupons available',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _coupons.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final coupon = _coupons[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  coupon.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (coupon.description != null &&
                                        coupon.description!.isNotEmpty)
                                      Text(coupon.description!),
                                    const SizedBox(height: 4),
                                    Text(
                                      coupon.couponCode,
                                      style: const TextStyle(
                                        color: AppColors.brand,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (coupon.displayEndDate != null)
                                      Text(
                                        'Valid till ${coupon.displayEndDate}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: TextButton(
                                  onPressed: () =>
                                      _applyCode(coupon.couponCode),
                                  child: const Text('Apply'),
                                ),
                                onTap: () => _applyCode(coupon.couponCode),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
