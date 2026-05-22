import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/cart_navigation.dart';
import '../../../../core/navigation/order_navigation.dart';
import '../../../../core/navigation/search_navigation.dart';
import '../../../../core/navigation/categories_navigation.dart';
import '../../../../core/navigation/deep_link_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/system_ui_styles.dart';
import '../../../../core/push/push_notification_service.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/widgets/home_tab.dart';
import '../../../location/presentation/pages/location_info_page.dart';
import '../../../orders/presentation/widgets/orders_tab.dart';
import '../cubit/main_cubit.dart';
import '../cubit/main_state.dart';
import '../widgets/account_tab.dart';
import '../widgets/main_location_app_bar.dart';
import '../widgets/order_status_track_bar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<MainCubit>(),
      child: const _MainView(),
    );
  }
}

class _MainView extends StatefulWidget {
  const _MainView();

  @override
  State<_MainView> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        openPendingShareDeepLink(context);
        final mainCubit = context.read<MainCubit>();
        mainCubit.refreshInProgressOrder();
        mainCubit.refreshCartBadge();
        sl<PushNotificationService>().syncTokenWithServer();
        sl<PushNotificationService>().handlePendingNavigation();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      final mainCubit = context.read<MainCubit>();
      mainCubit.refreshInProgressOrder();
      mainCubit.refreshCartBadge();
      sl<PushNotificationService>().syncTokenWithServer();
    }
  }

  static const _tabs = [
    HomeTab(),
    SizedBox.shrink(),
    OrdersTab(),
    AccountTab(),
  ];

  Future<void> _openChangeLocation(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const LocationInfoPage(),
      ),
    );
    if (context.mounted && changed == true) {
      context.read<MainCubit>().loadDeliveryLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainCubit, MainState>(
      listenWhen: (prev, curr) => prev.showLoginDialog != curr.showLoginDialog,
      listener: (context, state) async {
        if (!state.showLoginDialog) return;

        final goLogin = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Login required'),
            content: const Text('Please login to continue.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Login'),
              ),
            ],
          ),
        );

        if (!context.mounted) return;
        context.read<MainCubit>().dismissLoginDialog();

        if (goLogin == true) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const LoginPage()),
          );
        }
      },
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          final onHomeTab = state.currentIndex == 0;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: onHomeTab ? AppSystemUi.homeHero : AppSystemUi.brandAppBar,
            child: Scaffold(
              appBar: onHomeTab
                  ? null
                  : MainLocationAppBar(
                      location: state.deliveryLocation,
                      cartItemCount: state.cartItemCount,
                      onLocationTap: () => _openChangeLocation(context),
                      onSearch: () => openSearchScreen(context),
                      onCart: () => openCart(context),
                    ),
              body: IndexedStack(
                index: state.currentIndex,
                children: _tabs,
              ),
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.inProgressOrder != null)
                    OrderStatusTrackBar(
                      order: state.inProgressOrder!,
                      onTrackTap: () {
                        openOrderFromTrackBar(
                          context,
                          state.inProgressOrder!,
                        );
                      },
                    ),
                  BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: state.currentIndex,
                    selectedItemColor: AppColors.brand,
                    unselectedItemColor: Colors.grey,
                    onTap: (index) {
                      if (index == 1) {
                        openCategoriesScreen(context);
                        return;
                      }
                      context.read<MainCubit>().onTabSelected(index);
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.grid_view_outlined),
                        activeIcon: Icon(Icons.grid_view),
                        label: 'Category',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.receipt_long_outlined),
                        activeIcon: Icon(Icons.receipt_long),
                        label: 'Orders',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person),
                        label: 'Account',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
