import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/cuisine_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../injection_container.dart';
import '../../../catalog/domain/entities/cuisine_entity.dart';
import '../../../main/presentation/cubit/main_cubit.dart';
import '../../../main/presentation/cubit/main_state.dart';
import '../cubit/category_cubit.dart';
import '../cubit/category_state.dart';

/// Bottom-nav categories tab — grid stays inside [MainPage] (bottom bar visible).
class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    sl<CategoryCubit>().loadCategoriesIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<MainCubit, MainState>(
      listenWhen: (prev, curr) =>
          prev.deliveryLocation != curr.deliveryLocation &&
          curr.deliveryLocation != null,
      listener: (context, state) {
        sl<CategoryCubit>().reloadForLocationChange();
      },
      child: BlocProvider.value(
        value: sl<CategoryCubit>(),
        child: BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state.status == CategoryStatus.loading &&
            state.cuisines.isEmpty) {
          return const CategoryGridShimmer(itemCount: 8);
        }

        if (state.status == CategoryStatus.failure &&
            state.cuisines.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage ?? 'Failed to load categories',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CategoryCubit>().loadCategories(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.cuisines.isEmpty) {
          return const MobileApiEmptyView(message: 'No categories found');
        }

        return RefreshIndicator(
          color: AppColors.brand,
          onRefresh: () => context.read<CategoryCubit>().loadCategories(),
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemCount: state.cuisines.length,
            itemBuilder: (_, index) {
              return _CategoryCell(cuisine: state.cuisines[index]);
            },
          ),
        );
      },
        ),
      ),
    );
  }
}

class _CategoryCell extends StatelessWidget {
  const _CategoryCell({required this.cuisine});

  final CuisineEntity cuisine;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => openCuisineRestaurants(context, cuisine),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: NetworkImageBox(
                  url: cuisine.image,
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  cuisine.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
