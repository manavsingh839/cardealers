import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../providers/admin_portal_provider.dart';
import '../../widgets/common/status_badge.dart';

class AdminSubscriptionsPage extends StatelessWidget {
  const AdminSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminPortalProvider>();
    final dealers = admin.dealers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
                      'Dealer Subscription & Trial Oversight',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Control trial countdowns, manually activate or extend subscriptions, and manage tier limits.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Estimated MRR: ${Formatters.formatCurrency(admin.monthlyRevenue)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Table Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dealers.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final dealer = dealers[index];
                final carsCount = admin.cars.where((c) => c.dealerId == dealer.id).length;
                final plan = admin.plans.firstWhere((p) => p.id == dealer.subscriptionPlanId, orElse: () => admin.plans.first);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(dealer.logoUrl),
                  ),
                  title: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(dealer.businessName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      StatusBadge(status: dealer.subscriptionStatus),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(4)),
                        child: Text(plan.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accent)),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Slots: $carsCount / ${dealer.isInTrial ? 10 : plan.carLimit} Cars • '
                      '${dealer.isInTrial ? "Trial (${dealer.remainingTrialDays} days left)" : "Renews: ${dealer.renewalDate != null ? Formatters.formatDate(dealer.renewalDate!) : "N/A"}"} • '
                      'City: ${dealer.city}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  trailing: Responsive.isMobile(context)
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (action) {
                            if (action == 'activate') {
                              admin.activateSubscription(dealer.id, plan.id, 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.emerald,
                                  content: Text('Subscription activated for ${dealer.businessName} (30 days)'),
                                ),
                              );
                            } else if (action == 'extend') {
                              admin.extendSubscription(dealer.id, 7);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.emerald,
                                  content: Text('Extended subscription by 7 days for ${dealer.businessName}'),
                                ),
                              );
                            } else if (action == 'expire') {
                              admin.expireSubscription(dealer.id);
                            } else if (action == 'extend_trial') {
                              admin.extendTrial(dealer.id, 7);
                            } else if (action.startsWith('plan_')) {
                              final targetPlanId = action.replaceFirst('plan_', '');
                              admin.activateSubscription(dealer.id, targetPlanId, 1);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'activate',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: AppColors.accent),
                                  SizedBox(width: 8),
                                  Text('Activate 1 Mo'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'extend',
                              child: Row(
                                children: [
                                  Icon(Icons.add, size: 16, color: AppColors.emerald),
                                  SizedBox(width: 8),
                                  Text('+7 Days Extension'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(value: 'extend_trial', child: Text('Extend Trial +7 Days')),
                            const PopupMenuItem(value: 'plan_starter', child: Text('Switch to Starter (₹499)')),
                            const PopupMenuItem(value: 'plan_business', child: Text('Switch to Business (₹999)')),
                            const PopupMenuItem(value: 'plan_pro', child: Text('Switch to Pro (₹1,999)')),
                            const PopupMenuDivider(),
                            const PopupMenuItem(value: 'expire', child: Text('Mark Expired', style: TextStyle(color: Colors.red))),
                          ],
                        )
                      : Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Activate 1 Month Subscription
                            ElevatedButton(
                              onPressed: () {
                                admin.activateSubscription(dealer.id, plan.id, 1);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.emerald,
                                    content: Text('Subscription activated for ${dealer.businessName} (30 days)'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              child: const Text('Activate 1 Mo', style: TextStyle(fontSize: 11)),
                            ),
                            // Extend 7 Days
                            OutlinedButton(
                              onPressed: () {
                                admin.extendSubscription(dealer.id, 7);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.emerald,
                                    content: Text('Extended subscription by 7 days for ${dealer.businessName}'),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                              child: const Text('+7 Days', style: TextStyle(fontSize: 11)),
                            ),
                            // Actions Menu (Change Plan, Expire)
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18),
                              onSelected: (action) {
                                if (action == 'expire') {
                                  admin.expireSubscription(dealer.id);
                                } else if (action == 'extend_trial') {
                                  admin.extendTrial(dealer.id, 7);
                                } else if (action.startsWith('plan_')) {
                                  final targetPlanId = action.replaceFirst('plan_', '');
                                  admin.activateSubscription(dealer.id, targetPlanId, 1);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'extend_trial', child: Text('Extend Trial +7 Days')),
                                const PopupMenuItem(value: 'plan_starter', child: Text('Switch to Starter (₹499)')),
                                const PopupMenuItem(value: 'plan_business', child: Text('Switch to Business (₹999)')),
                                const PopupMenuItem(value: 'plan_pro', child: Text('Switch to Pro (₹1,999)')),
                                const PopupMenuDivider(),
                                const PopupMenuItem(value: 'expire', child: Text('Mark Expired', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
