import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cardealers/core/utils/formatters.dart';
import 'package:cardealers/models/car_model.dart';
import 'package:cardealers/providers/auth_provider.dart';
import 'package:cardealers/providers/admin_portal_provider.dart';
import 'package:cardealers/views/super_admin/admin_dashboard_shell.dart';
import 'package:cardealers/widgets/common/navbar.dart';

void main() {
  test('Formatters Indian Currency Test', () {
    expect(Formatters.formatPriceLakh(765000), equals('₹7.65 Lakh'));
    expect(Formatters.formatPriceLakh(1580000), equals('₹15.80 Lakh'));
    expect(Formatters.formatKm(18400), equals('18,400 km'));
  });

  test('Car Model Featured and Availability Check', () {
    final car = CarModel(
      id: 'car_test',
      dealerId: 'dealer_1',
      dealerName: 'Apex Motors',
      dealerCity: 'Muktsar',
      title: '2023 Maruti Swift',
      slug: 'swift-2023',
      brand: 'Maruti Suzuki',
      model: 'Swift',
      variant: 'ZXi+',
      price: 750000,
      year: 2023,
      kilometers: 15000,
      fuelType: 'Petrol',
      transmission: 'Manual',
      bodyType: 'Hatchback',
      city: 'Muktsar',
      description: 'Test description',
      coverImage: 'https://example.com/car.jpg',
      isFeatured: true,
      status: 'available',
      createdAt: DateTime.now(),
    );

    expect(car.isFeatured, isTrue);
    expect(car.isAvailable, isTrue);
    expect(car.isSold, isFalse);
  });

  testWidgets('AdminDashboardShell renders sidebar nav and allows tab switching without errors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authProvider = AuthProvider();
    authProvider.loginAsAdmin();
    final adminPortalProvider = AdminPortalProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<AdminPortalProvider>.value(value: adminPortalProvider),
        ],
        child: const MaterialApp(
          home: AdminDashboardShell(initialTabIndex: 0),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Admin Dashboard Shell header and sidebar rendered
    expect(find.text('Super Admin Portal'), findsOneWidget);
    expect(find.text('Platform Overview'), findsOneWidget);
    expect(find.text('Dealers Moderation'), findsOneWidget);
    expect(find.text('Car Moderation'), findsOneWidget);

    // Tap Pricing Plans Config nav item in the sidebar
    final plansNav = find.text('Pricing Plans Config');
    expect(plansNav, findsOneWidget);
    await tester.tap(plansNav);
    await tester.pumpAndSettle();

    // Verify Pricing Plans page header is displayed
    expect(find.text('Configurable Subscription Plans'), findsOneWidget);

    // Tap Platform Settings nav item in the sidebar
    final settingsNav = find.text('Platform Settings');
    expect(settingsNav, findsOneWidget);
    await tester.tap(settingsNav);
    await tester.pumpAndSettle();

    // Verify Platform Settings page header is displayed
    expect(find.text('Platform Governance & Settings'), findsOneWidget);
  });

  testWidgets('Unauthenticated public visitor does not see Admin Portal or pre-logged dealer', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authProvider = AuthProvider();
    authProvider.logout(); // ensure guest state

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MaterialApp(
          home: Scaffold(
            appBar: Navbar(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Public links must be visible
    expect(find.text('Browse Cars'), findsOneWidget);
    expect(find.text('Verified Dealers'), findsOneWidget);
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Dealer Login'), findsOneWidget);
    expect(find.text('List Cars & Get Enquiries'), findsOneWidget);

    // Admin Portal and Apex Motors should NOT be visible to public guest
    expect(find.text('Admin Portal'), findsNothing);
    expect(find.text('Apex Motors'), findsNothing);
  });
}
