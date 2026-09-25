import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/dealer_portal_provider.dart';
import '../../data/app_data_store.dart';

class DealerSubscriptionPage extends StatelessWidget {
  const DealerSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<DealerPortalProvider>();
    final dealer = portal.dealer;
    final currentPlan = portal.currentPlan;
    final dataStore = AppDataStore();
    final allPlans = dataStore.plans;
    final carsUsed = portal.dealerCars.length;
    final carsAllowed = portal.carLimit;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription & Billing Management',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage your SaaS subscription, listing capacity, and trial status.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Current Status Banner / Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                currentPlan?.name ?? 'Starter',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: dealer?.isInTrial == true ? AppColors.amberLight : AppColors.emeraldLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  dealer?.isInTrial == true ? '7-DAY FREE TRIAL' : 'ACTIVE SUBSCRIPTION',
                                  style: TextStyle(
                                    color: dealer?.isInTrial == true ? AppColors.amber : AppColors.emerald,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dealer?.isInTrial == true
                                ? 'Trial remaining: ${dealer?.remainingTrialDays} days'
                                : 'Renews on: ${dealer?.renewalDate != null ? Formatters.formatDate(dealer!.renewalDate!) : "Monthly"}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Text(
                        Formatters.formatCurrency(currentPlan?.priceMonthly ?? 499),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.accent),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Slot usage progress bar
                  Text(
                    'Inventory Listing Capacity: $carsUsed / $carsAllowed Cars Used',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: carsAllowed > 0 ? (carsUsed / carsAllowed).clamp(0.0, 1.0) : 1.0,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceMuted,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${carsAllowed - carsUsed} additional car listings available under this plan.',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Upgrade Plans Section
          const Text(
            'Upgrade Your Plan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select a higher tier to increase your car listing capacity and gain featured lead placement.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: allPlans.map((plan) {
              final isCurrent = plan.id == dealer?.subscriptionPlanId;
              final isRec = plan.isRecommended;

              return Container(
                width: 310,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isCurrent ? AppColors.emerald : (isRec ? AppColors.accent : AppColors.border),
                    width: isCurrent || isRec ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.emeraldLight, borderRadius: BorderRadius.circular(4)),
                        child: const Text('CURRENT PLAN', style: TextStyle(color: AppColors.emerald, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    else if (isRec)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(4)),
                        child: const Text('RECOMMENDED', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(height: 10),
                    Text(plan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      '${Formatters.formatCurrency(plan.priceMonthly)} / month',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Text('Up to ${plan.carLimit} Car Listings', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.accent)),
                    const Divider(height: 24),
                    ...plan.features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check, size: 14, color: AppColors.emerald),
                            const SizedBox(width: 8),
                            Expanded(child: Text(f, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isCurrent
                            ? null
                            : () {
                                _handleUpgrade(context, dealer!.id, plan.id, plan.name);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRec ? AppColors.accent : AppColors.primary,
                        ),
                        child: Text(isCurrent ? 'Current Tier' : 'Upgrade to ${plan.name}'),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _handleUpgrade(BuildContext context, String dealerId, String planId, String planName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to $planName Plan?'),
        content: const Text(
          'Your dealership account will be upgraded immediately. Full car listing capacity and priority lead routing will be activated.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final dataStore = AppDataStore();
              dataStore.updateDealerSubscription(
                dealerId,
                planId: planId,
                status: 'active',
                renewalDate: DateTime.now().add(const Duration(days: 30)),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.emerald,
                  content: Text('Successfully upgraded to $planName Plan!'),
                ),
              );
            },
            child: const Text('Confirm Upgrade'),
          ),
        ],
      ),
    );
  }
}
