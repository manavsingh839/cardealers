import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../providers/dealer_portal_provider.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/charts/lead_analytics_chart.dart';

class DealerOverviewPage extends StatelessWidget {
  final Function(int) onNavigateTab;

  const DealerOverviewPage({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<DealerPortalProvider>();
    final stats = portal.stats;
    final dealer = portal.dealer;
    final recentEnquiries = portal.dealerEnquiries.take(5).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${dealer?.businessName ?? "Dealer"}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Real-time customer enquiries, direct buyer leads, and conversion analytics.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => onNavigateTab(3), // Add car tab
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Vehicle'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 1. Lead Overview Cards (Top Priority)
          const Text(
            'Lead Overview & Inquiries Pipeline',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 950 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
              return GridView.count(
                crossAxisCount: count,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: count == 2 ? 1.25 : (count == 3 ? 1.35 : 1.5),
                children: [
                  StatCard(
                    title: 'Total Enquiries',
                    value: '${stats.totalEnquiries}',
                    icon: Icons.mark_email_read_outlined,
                    color: AppColors.accent,
                    subtitle: '${stats.newEnquiries} new uncontacted',
                    onTap: () => onNavigateTab(1),
                  ),
                  StatCard(
                    title: 'New Leads',
                    value: '${stats.newEnquiries}',
                    icon: Icons.fiber_new_rounded,
                    color: AppColors.orange,
                    subtitle: 'Requires immediate call',
                    onTap: () => onNavigateTab(1),
                  ),
                  StatCard(
                    title: 'Contacted',
                    value: '${stats.contactedEnquiries}',
                    icon: Icons.phone_forwarded_outlined,
                    color: AppColors.purple,
                    onTap: () => onNavigateTab(1),
                  ),
                  StatCard(
                    title: 'Interested',
                    value: '${stats.interestedEnquiries}',
                    icon: Icons.thumb_up_outlined,
                    color: AppColors.amber,
                    onTap: () => onNavigateTab(1),
                  ),
                  StatCard(
                    title: 'Converted Deals',
                    value: '${stats.convertedLeads}',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.emerald,
                    subtitle: 'Closed sales',
                    onTap: () => onNavigateTab(1),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 2. Direct Interaction Lead Metrics (Car Views, Profile Views, WhatsApp, Phone)
          const Text(
            'Direct Buyer Contact Triggers',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 900 ? 4 : 2;
              return GridView.count(
                crossAxisCount: count,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: count == 2 ? 1.25 : 1.6,
                children: [
                  StatCard(
                    title: 'Car Views',
                    value: '${stats.carViews}',
                    icon: Icons.directions_car_outlined,
                    color: AppColors.primaryLight,
                    subtitle: 'Inventory impressions',
                  ),
                  StatCard(
                    title: 'Profile Views',
                    value: '${stats.profileViews}',
                    icon: Icons.visibility_outlined,
                    color: AppColors.primary,
                    subtitle: 'Dealership page visits',
                  ),
                  StatCard(
                    title: 'WhatsApp Clicks',
                    value: '${stats.whatsappClicks}',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: AppColors.whatsappDark,
                    subtitle: 'Direct chat enquiries',
                  ),
                  StatCard(
                    title: 'Phone Clicks',
                    value: '${stats.phoneClicks}',
                    icon: Icons.phone_in_talk_outlined,
                    color: AppColors.accent,
                    subtitle: 'Direct phone dials',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // 3. Dealer ROI & Performance Section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Platform Performance & ROI',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Track how customers are discovering and contacting your showroom.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Active Plan: ${portal.currentPlan?.name ?? "Starter"}',
                          style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Wrap(
                    spacing: 36,
                    runSpacing: 20,
                    children: [
                      _roiMetric(
                        'Total Direct Leads',
                        '${stats.totalCustomerInteractions}',
                        'WhatsApp + Phone + Forms',
                        AppColors.accent,
                      ),
                      _roiMetric(
                        'Enquiry Conversion Rate',
                        '${stats.enquiryConversionRate}%',
                        'Enquiries per Car View',
                        AppColors.orange,
                      ),
                      _roiMetric(
                        'Lead Closing Rate',
                        '${stats.leadConversionRate}%',
                        'Converted per Enquiry',
                        AppColors.emerald,
                      ),
                      _roiMetric(
                        'Inventory Utilization',
                        '${portal.dealerCars.length} / ${portal.carLimit} Cars',
                        '${portal.carLimit - portal.dealerCars.length} listings remaining',
                        AppColors.primaryLight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 4. Chart & Recent Enquiries Feed Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: LeadAnalyticsChart(stats: stats)),
                        const SizedBox(width: 20),
                        Expanded(flex: 6, child: _buildRecentEnquiriesCard(context, portal, recentEnquiries)),
                      ],
                    )
                  : Column(
                      children: [
                        LeadAnalyticsChart(stats: stats),
                        const SizedBox(height: 20),
                        _buildRecentEnquiriesCard(context, portal, recentEnquiries),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _roiMetric(String label, String value, String sub, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5),
        ),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildRecentEnquiriesCard(BuildContext context, DealerPortalProvider portal, List enquiries) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Recent Customer Enquiries',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(1),
                  child: const Text('View All Enquiries'),
                ),
              ],
            ),
            const Divider(height: 16),
            if (enquiries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No enquiries received yet. Listings are active on marketplace.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: enquiries.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final enq = enquiries[index];
                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.accentLight,
                        child: Text(
                          enq.customerName.isNotEmpty ? enq.customerName[0].toUpperCase() : 'C',
                          style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(enq.customerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis),
                                StatusBadge(status: enq.status),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              enq.carTitle,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Via ${enq.source} • ${Formatters.formatDate(enq.createdAt)}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      // Quick Call & WhatsApp Buttons
                      IconButton(
                        icon: const Icon(Icons.phone, size: 18, color: AppColors.accent),
                        tooltip: 'Call Customer',
                        onPressed: () => portal.callCustomer(enq.customerPhone),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat, size: 18, color: AppColors.whatsappDark),
                        tooltip: 'WhatsApp Customer',
                        onPressed: () => portal.whatsappCustomer(enq.customerPhone, enq.customerName, enq.carTitle),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
