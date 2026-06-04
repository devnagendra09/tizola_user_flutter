import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/restaurant_review_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';

/// Android `RestaurantReviewFragment`.
class RestaurantReviewsTab extends StatefulWidget {
  const RestaurantReviewsTab({super.key, required this.seoUrl});

  final String seoUrl;

  @override
  State<RestaurantReviewsTab> createState() => _RestaurantReviewsTabState();
}

class _RestaurantReviewsTabState extends State<RestaurantReviewsTab> {
  final _items = <RestaurantReviewEntity>[];
  final _scrollController = ScrollController();
  var _loading = true;
  var _loadingMore = false;
  var _page = 1;
  var _totalPages = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(page: 1, refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 120 &&
        !_loadingMore &&
        _page < _totalPages) {
      _load(page: _page + 1, refresh: false);
    }
  }

  Future<void> _load({required int page, required bool refresh}) async {
    if (refresh) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    final result = await sl<RestaurantRepository>().getReviews(
      seoUrl: widget.seoUrl,
      page: page,
    );

    if (!mounted) return;

    if (result.isFailure) {
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = result.failure?.message ?? 'Failed to load reviews';
      });
      return;
    }

    final data = result.data!;
    setState(() {
      _loading = false;
      _loadingMore = false;
      _page = page;
      _totalPages = data.totalPages;
      if (refresh) {
        _items
          ..clear()
          ..addAll(data.items);
      } else {
        _items.addAll(data.items);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _load(page: 1, refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const MobileApiEmptyView(message: 'No reviews yet');
    }

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: () => _load(page: 1, refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brand),
              ),
            );
          }
          final review = _items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          review.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < review.rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber.shade700,
                          );
                        }),
                      ),
                    ],
                  ),
                  if (review.feedback.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      review.feedback,
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
