import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/app_data_store.dart';
import '../../../widgets/common/navbar.dart';
import '../../../widgets/common/footer.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataStore = AppDataStore();
    final plans = dataStore.plans;

    return Scaffold(
      appBar: const Navbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Pricing Hero
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.orangeLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          '7-DAY FREE TRIAL ON ALL REGISTRATIONS',
                          style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Simple, Transparent Pricing for Car Dealerships',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Position your showroom online, capture direct WhatsApp and phone leads, and track customer conversions with zero commissions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Plans Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: plans.map((plan) {
                      final isRec = plan.isRecommended;

                      return Container(
                        width: Responsive.isMobile(context) ? double.infinity : 350,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isRec ? AppColors.accent : AppColors.border,
                            width: isRec ? 2.5 : 1,
                          ),
                          boxShadow: isRec
                              ? [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(alpha: 0.12),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                        ),
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isRec) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'RECOMMENDED PLAN',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10.5,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Text(
                              plan.name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: Formatters.formatCurrency(plan.priceMonthly),
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  ),
                                  const TextSpan(
                                    text: ' /month',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.directions_car, size: 16, color: AppColors.accent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Up to ${plan.carLimit} Car Listings',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 36),
                            const Text('Plan Features Included:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 12),
                            ...plan.features.map(
                              (f) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        f,
                                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () => context.go('/register'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isRec ? AppColors.accent : AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  'Choose ${plan.name} (7-Day Trial)',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const Footer(),
          ],
        ),
      ),
    );
  }
}
