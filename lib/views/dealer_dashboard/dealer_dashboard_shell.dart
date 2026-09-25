import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dealer_portal_provider.dart';
import 'dealer_overview_page.dart';
import 'dealer_enquiries_page.dart';
import 'dealer_cars_page.dart';
import 'add_edit_car_page.dart';
import 'dealer_subscription_page.dart';
import 'dealer_profile_page.dart';

class DealerDashboardShell extends StatefulWidget {
  final int initialTabIndex;

  const DealerDashboardShell({super.key, this.initialTabIndex = 0});

  @override
  State<DealerDashboardShell> createState() => _DealerDashboardShellState();
}

class _DealerDashboardShellState extends State<DealerDashboardShell> {
  late int _selectedTab;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<String> _routes = [
    AppRoutes.dealerDashboard,
    AppRoutes.dealerEnquiries,
    AppRoutes.dealerCars,
    AppRoutes.dealerAddCar,
    AppRoutes.dealerSubscription,
    AppRoutes.dealerProfile,
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

  @override
  void didUpdateWidget(covariant DealerDashboardShell oldWidget) {
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
    final dealerPortal = context.watch<DealerPortalProvider>();
    final dealer = dealerPortal.dealer;
    final isDesktop = Responsive.isDesktop(context);

    final pages = [
      DealerOverviewPage(onNavigateTab: _selectTab),
      const DealerEnquiriesPage(),
      DealerCarsPage(onAddCar: () => _selectTab(3)),
      AddEditCarPage(onSuccess: () => _selectTab(2)),
      const DealerSubscriptionPage(),
      const DealerProfilePage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.speed, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                dealer?.businessName ?? 'Dealer Dashboard',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (dealer?.isVerified == true) ...[
              const SizedBox(width: 8),
              const Icon(Icons.verified, size: 16, color: AppColors.emerald),
            ],
            if (isDesktop && dealer?.isDemo == true) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                child: const Text('Demo Dealer', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ),
            ],
          ],
        ),
        actions: [
          if (isDesktop)
            TextButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.public, size: 16),
              label: const Text('View Public Marketplace', style: TextStyle(fontSize: 13)),
            )
          else
            IconButton(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.public, size: 20),
              tooltip: 'View Public Marketplace',
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
              child: _buildNavigationMenu(context, dealerPortal),
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
                    label: Text('${dealerPortal.dealerEnquiries.length}'),
                    isLabelVisible: dealerPortal.dealerEnquiries.isNotEmpty,
                    child: const Icon(Icons.contacts_outlined),
                  ),
                  label: 'Enquiries',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text('${dealerPortal.dealerCars.length}'),
                    isLabelVisible: dealerPortal.dealerCars.isNotEmpty,
                    child: const Icon(Icons.directions_car_outlined),
                  ),
                  label: 'Inventory',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.menu_rounded),
                  label: 'More',
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // 7-Day Trial Banner (if in trial)
          if (dealer != null && dealer.isInTrial) ...[
            Container(
              width: double.infinity,
              color: dealer.remainingTrialDays <= 2 ? AppColors.redLight : AppColors.amberLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Responsive.isMobile(context)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: dealer.remainingTrialDays <= 2 ? AppColors.red : AppColors.amber,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dealer.remainingTrialDays > 0
                                    ? '7-Day Free Trial: ${dealer.remainingTrialDays} days remaining'
                                    : '7-Day Free Trial has ended',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: dealer.remainingTrialDays <= 2 ? AppColors.red : const Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dealer.remainingTrialDays > 0
                              ? 'Upgrade now to unlock higher car limits and priority WhatsApp placement.'
                              : 'Please choose a subscription plan to continue adding new car listings.',
                          style: TextStyle(
                            fontSize: 12,
                            color: dealer.remainingTrialDays <= 2 ? AppColors.red : const Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _selectTab(4), // Navigate to subscription
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dealer.remainingTrialDays <= 2 ? AppColors.red : AppColors.amber,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Choose a Plan'),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: dealer.remainingTrialDays <= 2 ? AppColors.red : AppColors.amber,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            dealer.remainingTrialDays > 0
                                ? 'Your 7-Day Free Trial ends in ${dealer.remainingTrialDays} days. Upgrade now to unlock higher car limits and priority WhatsApp placement.'
                                : 'Your 7-Day Free Trial has ended. Please choose a subscription plan to continue adding new car listings.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: dealer.remainingTrialDays <= 2 ? AppColors.red : const Color(0xFF92400E),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectTab(4), // Navigate to subscription
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dealer.remainingTrialDays <= 2 ? AppColors.red : AppColors.amber,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Choose a Plan'),
                        ),
                      ],
                    ),
            ),
          ],

          // Main body with Persistent Sidebar on Desktop
          Expanded(
            child: Row(
              children: [
                if (isDesktop) ...[
                  SizedBox(
                    width: 250,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(right: BorderSide(color: AppColors.border)),
                      ),
                      child: _buildNavigationMenu(context, dealerPortal),
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
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu(BuildContext context, DealerPortalProvider dealerPortal) {
    final navItems = [
      {'title': 'Lead Overview & ROI', 'icon': Icons.insights_rounded},
      {'title': 'Enquiries (CRM)', 'icon': Icons.contacts_outlined, 'badge': '${dealerPortal.dealerEnquiries.length}'},
      {'title': 'My Car Inventory', 'icon': Icons.directions_car_outlined, 'badge': '${dealerPortal.dealerCars.length}'},
      {'title': 'Add New Car', 'icon': Icons.add_circle_outline_rounded},
      {'title': 'Subscription & Plan', 'icon': Icons.credit_card_outlined},
      {'title': 'Showroom Profile', 'icon': Icons.business_outlined},
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'SAAS LEAD CRM',
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
            trailing: navItems[i]['badge'] != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _selectedTab == i ? AppColors.accent : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      navItems[i]['badge'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _selectedTab == i ? Colors.white : AppColors.textSecondary,
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
