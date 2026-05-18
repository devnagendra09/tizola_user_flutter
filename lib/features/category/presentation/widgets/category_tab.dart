import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../injection_container.dart';
import '../cubit/category_cubit.dart';
import '../cubit/category_state.dart';

class CategoryTab extends StatelessWidget {
  const CategoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryCubit>()..loadCategories(),
      child: const _CategoryView(),
    );
  }
}

class _CategoryView extends StatelessWidget {
  const _CategoryView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state.status == CategoryStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brand),
          );
        }

        if (state.status == CategoryStatus.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.errorMessage ?? 'Failed to load categories'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      context.read<CategoryCubit>().loadCategories(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.cuisines.isEmpty) {
          return const Center(child: Text('No categories found'));
        }

        return RefreshIndicator(
          color: AppColors.brand,
          onRefresh: () => context.read<CategoryCubit>().loadCategories(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: state.cuisines.length,
            itemBuilder: (context, index) {
              final cuisine = state.cuisines[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${cuisine.name} — restaurants coming soon'),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: NetworkImageBox(
                          url: cuisine.image,
                          width: 72,
                          height: 72,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          cuisine.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (cuisine.restaurantCount != null)
                        Text(
                          '${cuisine.restaurantCount} restaurants',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
