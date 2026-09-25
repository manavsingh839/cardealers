import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cardealers/core/theme/app_theme.dart';
import 'package:cardealers/providers/auth_provider.dart';
import 'package:cardealers/providers/car_catalog_provider.dart';
import 'package:cardealers/providers/dealer_portal_provider.dart';
import 'package:cardealers/providers/admin_portal_provider.dart';

import 'package:cardealers/views/public/home/home_page.dart';
import 'package:cardealers/views/public/cars/car_search_page.dart';
import 'package:cardealers/views/public/cars/car_detail_page.dart';
import 'package:cardealers/views/public/dealers/dealer_directory_page.dart';
import 'package:cardealers/views/public/dealers/dealer_detail_page.dart';
import 'package:cardealers/views/public/pricing/pricing_page.dart';
import 'package:cardealers/views/public/auth/dealer_login_page.dart';
import 'package:cardealers/views/public/auth/dealer_register_page.dart';
import 'package:cardealers/views/public/auth/admin_login_page.dart';
import 'package:cardealers/views/dealer_dashboard/dealer_dashboard_shell.dart';
import 'package:cardealers/views/super_admin/admin_dashboard_shell.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestHttpClient();
  }
}

class _TestHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}
  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}
  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _TestHttpClientRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _TestHttpClientRequest();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _TestHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _TestHttpClientResponse();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  @override
  final HttpHeaders headers = _TestHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final Uint8List _transparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

Widget _wrap(Widget child, {AuthProvider? auth, CarCatalogProvider? catalog, DealerPortalProvider? dealer, AdminPortalProvider? admin}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: auth ?? AuthProvider()),
      ChangeNotifierProvider<CarCatalogProvider>.value(value: catalog ?? CarCatalogProvider()),
      ChangeNotifierProvider<DealerPortalProvider>.value(value: dealer ?? DealerPortalProvider()),
      ChangeNotifierProvider<AdminPortalProvider>.value(value: admin ?? AdminPortalProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: Material(child: child),
    ),
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });
  final viewports = <String, Size>{
    'Mobile Small (360x640)': const Size(360, 640),
    'Mobile Standard (390x844)': const Size(390, 844),
    'Tablet Portrait (768x1024)': const Size(768, 1024),
    'Desktop Standard (1280x800)': const Size(1280, 800),
    'Desktop Wide (1440x900)': const Size(1440, 900),
  };

  group('Public Screens Responsiveness & Overflow Audit', () {
    for (final entry in viewports.entries) {
      testWidgets('HomePage on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_wrap(const HomePage()));
        await tester.pumpAndSettle();
      });

      testWidgets('CarSearchPage on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_wrap(const CarSearchPage()));
        await tester.pumpAndSettle();
      });

      testWidgets('CarDetailPage on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_wrap(const CarDetailPage(carId: 'car_1')));
        await tester.pumpAndSettle();
      });

      testWidgets('DealerDirectoryPage on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_wrap(const DealerDirectoryPage()));
        await tester.pumpAndSettle();
      });

      testWidgets('DealerDetailPage on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_wrap(const DealerDetailPage(dealerId: 'dealer_1')));
        await tester.pumpAndSettle();
      });

      testWidgets('PricingPage on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_wrap(const PricingPage()));
        await tester.pumpAndSettle();
      });

      testWidgets('Auth Pages on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_wrap(const DealerLoginPage()));
        await tester.pumpAndSettle();

        await tester.pumpWidget(_wrap(const DealerRegisterPage()));
        await tester.pumpAndSettle();

        await tester.pumpWidget(_wrap(const AdminLoginPage()));
        await tester.pumpAndSettle();
      });
    }
  });

  group('Dealer Dashboard Shell Audit', () {
    for (final entry in viewports.entries) {
      testWidgets('DealerDashboard tabs on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final auth = AuthProvider();
        auth.loginAsDealer('dealer_1');

        for (int tab = 0; tab < 6; tab++) {
          await tester.pumpWidget(_wrap(DealerDashboardShell(initialTabIndex: tab), auth: auth));
          await tester.pumpAndSettle();
        }
      });
    }
  });

  group('Super Admin Dashboard Shell Audit', () {
    for (final entry in viewports.entries) {
      testWidgets('AdminDashboard tabs on ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final auth = AuthProvider();
        auth.loginAsAdmin();

        for (int tab = 0; tab < 7; tab++) {
          await tester.pumpWidget(_wrap(AdminDashboardShell(initialTabIndex: tab), auth: auth));
          await tester.pumpAndSettle();
        }
      });
    }
  });
}
