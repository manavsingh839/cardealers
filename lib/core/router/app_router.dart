import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../../views/public/home/home_page.dart';
import '../../views/public/cars/car_search_page.dart';
import '../../views/public/cars/car_detail_page.dart';
import '../../views/public/dealers/dealer_directory_page.dart';
import '../../views/public/dealers/dealer_detail_page.dart';
import '../../views/public/pricing/pricing_page.dart';
import '../../views/public/auth/dealer_login_page.dart';
import '../../views/public/auth/dealer_register_page.dart';
import '../../views/public/auth/admin_login_page.dart';
import '../../views/dealer_dashboard/dealer_dashboard_shell.dart';
import '../../views/super_admin/admin_dashboard_shell.dart';
import '../../data/app_data_store.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final user = AppDataStore().currentUser;
      final path = state.uri.path;

      final isAdminRoute = path.startsWith('/admin') && path != AppRoutes.adminLogin;
      final isDealerRoute = path.startsWith('/dealer');

      // Protect Admin routes
      if (isAdminRoute) {
        if (user == null || !user.isAdmin) {
          return AppRoutes.adminLogin;
        }
      }

      // Protect Dealer routes
      if (isDealerRoute) {
        if (user == null || !user.isDealer) {
          return AppRoutes.dealerLogin;
        }
      }

      return null;
    },
    routes: [
      // 1. Public Marketplace Routes
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.cars,
        builder: (context, state) => const CarSearchPage(),
      ),
      GoRoute(
        path: AppRoutes.carDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'car_1';
          return CarDetailPage(carId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.dealers,
        builder: (context, state) => const DealerDirectoryPage(),
      ),
      GoRoute(
        path: AppRoutes.dealerDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'dealer_1';
          return DealerDetailPage(dealerId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.pricing,
        builder: (context, state) => const PricingPage(),
      ),

      // 2. Auth Routes
      GoRoute(
        path: AppRoutes.dealerLogin,
        builder: (context, state) => const DealerLoginPage(),
      ),
      GoRoute(
        path: AppRoutes.dealerRegister,
        builder: (context, state) => const DealerRegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.adminLogin,
        builder: (context, state) => const AdminLoginPage(),
      ),

      // 3. Dealer SaaS Dashboard Routes
      GoRoute(
        path: AppRoutes.dealerDashboard,
        builder: (context, state) => const DealerDashboardShell(initialTabIndex: 0),
      ),
      GoRoute(
        path: AppRoutes.dealerEnquiries,
        builder: (context, state) => const DealerDashboardShell(initialTabIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.dealerCars,
        builder: (context, state) => const DealerDashboardShell(initialTabIndex: 2),
      ),
      GoRoute(
        path: AppRoutes.dealerAddCar,
        builder: (context, state) => const DealerDashboardShell(initialTabIndex: 3),
      ),
      GoRoute(
        path: AppRoutes.dealerSubscription,
        builder: (context, state) => const DealerDashboardShell(initialTabIndex: 4),
      ),
      GoRoute(
        path: AppRoutes.dealerProfile,
        builder: (context, state) => const DealerDashboardShell(initialTabIndex: 5),
      ),

      // 4. Super Admin Governance Routes
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardShell(initialTabIndex: 0),
      ),
      GoRoute(
        path: AppRoutes.adminDealers,
        builder: (context, state) => const AdminDashboardShell(initialTabIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.adminCars,
        builder: (context, state) => const AdminDashboardShell(initialTabIndex: 2),
      ),
      GoRoute(
        path: AppRoutes.adminSubscriptions,
        builder: (context, state) => const AdminDashboardShell(initialTabIndex: 3),
      ),
      GoRoute(
        path: AppRoutes.adminPlans,
        builder: (context, state) => const AdminDashboardShell(initialTabIndex: 4),
      ),
      GoRoute(
        path: AppRoutes.adminEnquiries,
        builder: (context, state) => const AdminDashboardShell(initialTabIndex: 5),
      ),
      GoRoute(
        path: AppRoutes.adminSettings,
        builder: (context, state) => const AdminDashboardShell(initialTabIndex: 6),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404 - Page Not Found', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Return to Marketplace Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
