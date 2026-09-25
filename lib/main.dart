import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'services/firebase_service.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/car_catalog_provider.dart';
import 'providers/dealer_portal_provider.dart';
import 'providers/admin_portal_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path URL strategy for clean web URLs without '#' hash
  usePathUrlStrategy();

  // Safe Backend Initializations (with instant local seed fallback)
  await FirebaseService.initialize();
  await SupabaseService.initialize();

  runApp(const AutoDealersApp());
}

class AutoDealersApp extends StatelessWidget {
  const AutoDealersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CarCatalogProvider()),
        ChangeNotifierProvider(create: (_) => DealerPortalProvider()),
        ChangeNotifierProvider(create: (_) => AdminPortalProvider()),
      ],
      child: MaterialApp.router(
        title: 'AutoDealers India - Lead Generation Marketplace SaaS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
