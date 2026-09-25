import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../providers/admin_portal_provider.dart';
import '../../widgets/common/stat_card.dart';

class AdminOverviewPage extends StatelessWidget {
  final Function(int) onNavigateTab;

  const AdminOverviewPage({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminPortalProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Super Admin Platform Overview',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Multi-vendor ecosystem health, dealer verification pipeline, and revenue tracking.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => onNavigateTab(1),
                icon: const Icon(Icons.verified_user_outlined, size: 18),
                label: const Text('Review Dealers'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Primary KPIs Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 950 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.count(
                crossAxisCount: count,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: constraints.maxWidth > 950 ? 1.4 : (constraints.maxWidth > 600 ? 1.6 : 2.0),
                children: [
                  StatCard(
                    title: 'Total Dealerships',
                    value: '${admin.totalDealers}',
                    icon: Icons.storefront_outlined,
                    color: AppColors.accent,
                    subtitle: '${admin.verifiedDealers} verified showrooms',
                    onTap: () => onNavigateTab(1),
                  ),
                  StatCard(
                    title: 'Pending Verification',
                    value: '${admin.pendingDealers}',
                    icon: Icons.pending_actions_outlined,
                    color: AppColors.orange,
                    subtitle: 'Requires admin action',
                    onTap: () => onNavigateTab(1),
                  ),
                  StatCard(
                    title: 'Active Car Inventory',
                    value: '${admin.activeCars} / ${admin.totalCars}',
                    icon: Icons.directions_car_outlined,
                    color: AppColors.emerald,
                    subtitle: '${admin.featuredCars} featured listings',
                    onTap: () => onNavigateTab(2),
                  ),
                  StatCard(
                    title: 'Monthly Recurring Revenue',
                    value: Formatters.formatCurrency(admin.monthlyRevenue),
                    icon: Icons.currency_rupee_rounded,
                    color: AppColors.primary,
                    subtitle: 'Estimated subscription MRR',
                    onTap: () => onNavigateTab(3),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Secondary Row: Enquiries & Conversion Overview
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 900 ? 3 : 1;
              return GridView.count(
                crossAxisCount: count,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
                children: [
                  StatCard(
                    title: 'Total Platform Enquiries',
                    value: '${admin.totalEnquiries}',
                    icon: Icons.contacts_outlined,
                    color: AppColors.purple,
                    subtitle: '${admin.convertedEnquiries} converted deals',
                    onTap: () => onNavigateTab(5),
                  ),
                  StatCard(
                    title: 'Subscription Plans Configured',
                    value: '${admin.plans.length} Plans',
                    icon: Icons.tune_rounded,
                    color: AppColors.amber,
                    subtitle: 'Starter, Business, Pro',
                    onTap: () => onNavigateTab(4),
                  ),
                  StatCard(
                    title: 'Default Free Trial Period',
                    value: '${admin.settings.defaultTrialDays} Days',
                    icon: Icons.hourglass_bottom_rounded,
                    color: AppColors.emerald,
                    subtitle: 'Configured in Settings',
                    onTap: () => onNavigateTab(6),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
