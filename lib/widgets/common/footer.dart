import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CTA Banner for Dealers
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Responsive.isMobile(context)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '7-DAY FREE TRIAL AVAILABLE',
                              style: TextStyle(
                                color: AppColors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Are You a Car Dealer? List Your Cars & Get More Enquiries',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Receive customer enquiries directly via WhatsApp, Phone, and our interactive CRM lead manager.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => context.go('/register'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: const Text('Start Free Trial', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '7-DAY FREE TRIAL AVAILABLE',
                                    style: TextStyle(
                                      color: AppColors.orange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Are You a Car Dealer? List Your Cars & Get More Enquiries',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Receive customer enquiries directly via WhatsApp, Phone, and our interactive CRM lead manager.',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/register'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                            label: const Text('Start Free Trial', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 48),

              // Links Grid
              Wrap(
                spacing: 40,
                runSpacing: 28,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  // Col 1: About
                  SizedBox(
                    width: Responsive.isMobile(context) ? double.infinity : 280,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                AppConstants.appName,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'India\'s leading automotive lead generation SaaS and multi-vendor pre-owned car marketplace connecting verified dealers with active buyers.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  // Col 2: Top Automotive Cities
                  SizedBox(
                    width: Responsive.isMobile(context) ? double.infinity : 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Cities',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ...['Delhi NCR', 'Mumbai', 'Bengaluru', 'Chandigarh', 'Muktsar', 'Pune'].map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              onTap: () => context.go('/cars'),
                              child: Text(
                                'Used Cars in $c',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Col 3: Popular Brands
                  SizedBox(
                    width: Responsive.isMobile(context) ? double.infinity : 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Popular Brands',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ...['Maruti Suzuki', 'Hyundai', 'Tata Motors', 'Mahindra', 'Toyota', 'Kia'].map(
                          (b) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              onTap: () => context.go('/cars'),
                              child: Text(
                                '$b Cars',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Col 4: Quick Portals
                  SizedBox(
                    width: Responsive.isMobile(context) ? double.infinity : 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SaaS Portals',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => context.go('/register'),
                          child: const Text('Dealer Registration', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => context.go('/login'),
                          child: const Text('Dealer Dashboard Login', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => context.go('/pricing'),
                          child: const Text('Subscription Plans', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => context.go('/admin/login'),
                          child: const Text('Super Admin Portal', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              const Divider(color: AppColors.primaryLight),
              const SizedBox(height: 20),

              // Bottom bar
              const Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    '© 2026 AutoDealers India. All rights reserved.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  Text(
                    'Multi-Vendor SaaS Platform • Built with Flutter & Firebase',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
