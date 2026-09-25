import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_portal_provider.dart';
import 'admin_overview_page.dart';
import 'admin_dealers_page.dart';
import 'admin_cars_page.dart';
import 'admin_subscriptions_page.dart';
import 'admin_plans_page.dart';
import 'admin_enquiries_page.dart';
import 'admin_settings_page.dart';

class AdminDashboardShell extends StatefulWidget {
  final int initialTabIndex;

  const AdminDashboardShell({super.key, this.initialTabIndex = 0});

  @override
  State<AdminDashboardShell> createState() => _AdminDashboardShellState();
}

class _AdminDashboardShellState extends State<AdminDashboardShell> {
  late int _selectedTab;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<String> _routes = [
    AppRoutes.adminDashboard,
    AppRoutes.adminDealers,
    AppRoutes.adminCars,
    AppRoutes.adminSubscriptions,
    AppRoutes.adminPlans,
    AppRoutes.adminEnquiries,
    AppRoutes.adminSettings,
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

  @override
  void didUpdateWidget(covariant AdminDashboardShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      setState(() {
        _selectedTab = widget.initialTabIndex;
      });
    }
  }

  void _selectTab(int index) {
    if (index >= 0 && index < _routes.length) {
      setState(() => _selectedTab = index);
      try {
        context.go(_routes[index]);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = context.watch<AdminPortalProvider>();
    final isDesktop = Responsive.isDesktop(context);

    final pages = [
      AdminOverviewPage(onNavigateTab: _selectTab),
      const AdminDealersPage(),
      const AdminCarsPage(),
      const AdminSubscriptionsPage(),
      const AdminPlansPage(),
      const AdminEnquiriesPage(),
      const AdminSettingsPage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Super Admin Portal',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (isDesktop)
            TextButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.public, size: 16),
              label: const Text('View Marketplace', style: TextStyle(fontSize: 13)),
            )
          else
            IconButton(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.public, size: 20),
              tooltip: 'View Marketplace',
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              auth.logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: !isDesktop
          ? Drawer(
              child: _buildAdminMenu(context, admin),
            )
          : null,
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _selectedTab < 4 ? _selectedTab : 0,
              onTap: (index) {
                if (index == 3) {
                  _scaffoldKey.currentState?.openDrawer();
                } else {
                  _selectTab(index);
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.accent,
              unselectedItemColor: AppColors.textSecondary,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.insights_rounded),
                  label: 'Overview',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text('${admin.pendingDealers}'),
                    isLabelVisible: admin.pendingDealers > 0,
                    child: const Icon(Icons.storefront_outlined),
                  ),
                  label: 'Dealers',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.directions_car_outlined),
                  label: 'Cars',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.menu_rounded),
                  label: 'More',
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (isDesktop) ...[
            SizedBox(
              width: 250,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(right: BorderSide(color: AppColors.border)),
                ),
                child: _buildAdminMenu(context, admin),
              ),
            ),
          ],
          Expanded(
            child: Container(
              color: AppColors.background,
              child: pages[_selectedTab.clamp(0, pages.length - 1)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenu(BuildContext context, AdminPortalProvider admin) {
    final navItems = [
      {'title': 'Platform Overview', 'icon': Icons.insights_rounded},
      {'title': 'Dealers Moderation', 'icon': Icons.storefront_outlined, 'badge': '${admin.pendingDealers > 0 ? admin.pendingDealers : ""}'},
      {'title': 'Car Moderation', 'icon': Icons.directions_car_outlined},
      {'title': 'Subscriptions & Trials', 'icon': Icons.credit_card_outlined},
      {'title': 'Pricing Plans Config', 'icon': Icons.tune_rounded},
      {'title': 'All Enquiries', 'icon': Icons.contacts_outlined, 'badge': '${admin.totalEnquiries}'},
      {'title': 'Platform Settings', 'icon': Icons.settings_outlined},
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'ADMINISTRATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
        ),
        for (int i = 0; i < navItems.length; i++) ...[
          ListTile(
            selected: _selectedTab == i,
            selectedTileColor: AppColors.accentLight,
            leading: Icon(
              navItems[i]['icon'] as IconData,
              color: _selectedTab == i ? AppColors.accent : AppColors.textSecondary,
              size: 20,
            ),
            title: Text(
              navItems[i]['title'] as String,
              style: TextStyle(
                fontWeight: _selectedTab == i ? FontWeight.w700 : FontWeight.w500,
                color: _selectedTab == i ? AppColors.accent : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            trailing: (navItems[i]['badge'] as String? ?? '').isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: i == 1 && admin.pendingDealers > 0 ? AppColors.orange : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      navItems[i]['badge'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: i == 1 && admin.pendingDealers > 0 ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  )
                : null,
            onTap: () {
              if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                _scaffoldKey.currentState?.closeDrawer();
              }
              _selectTab(i);
            },
          ),
        ],
      ],
    );
  }
}
