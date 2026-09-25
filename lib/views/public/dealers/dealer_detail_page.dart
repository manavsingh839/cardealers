import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/app_data_store.dart';
import '../../../models/dealer_model.dart';
import '../../../services/analytics_service.dart';
import '../../../widgets/common/navbar.dart';
import '../../../widgets/common/footer.dart';
import '../../../widgets/common/car_card.dart';
import '../../../widgets/common/enquiry_dialog.dart';

class DealerDetailPage extends StatefulWidget {
  final String dealerId;

  const DealerDetailPage({super.key, required this.dealerId});

  @override
  State<DealerDetailPage> createState() => _DealerDetailPageState();
}

class _DealerDetailPageState extends State<DealerDetailPage> {
  final AnalyticsService _analytics = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    final dataStore = AppDataStore();
    DealerModel? dealer;
    try {
      dealer = dataStore.dealers.firstWhere((d) => d.id == widget.dealerId);
    } catch (_) {
      dealer = dataStore.dealers.first;
    }

    // Track profile view
    _analytics.trackDealerProfileView(dealer);

    final dealerCars = dataStore.cars.where((c) => c.dealerId == dealer!.id && c.status == 'available').toList();

    return Scaffold(
      appBar: const Navbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dealer Header Banner
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundImage: NetworkImage(dealer.logoUrl),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  dealer.businessName,
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                                if (dealer.isVerified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.emeraldLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified, size: 14, color: AppColors.emerald),
                                        SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'Verified Dealer',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (dealer.isDemo)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Demo Dealer', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text('${dealer.address}, ${dealer.city}, ${dealer.state}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              dealer.description,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                            ),
                            const SizedBox(height: 16),
                            // Quick Action Buttons
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    EnquiryDialog.show(
                                      context,
                                      dealerId: dealer!.id,
                                      dealerName: dealer.businessName,
                                      source: 'Dealer Profile Page CTA',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                                  icon: const Icon(Icons.mail_outline_rounded, size: 16),
                                  label: const Text('Send Enquiry'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _analytics.triggerWhatsAppChat(
                                      whatsappNumber: dealer!.whatsapp,
                                      dealerId: dealer.id,
                                      source: 'Dealer Profile WhatsApp CTA',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.whatsappDark, foregroundColor: Colors.white),
                                  icon: const Icon(Icons.chat, size: 16),
                                  label: const Text('WhatsApp Dealership'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _analytics.triggerPhoneCall(
                                      phoneNumber: dealer!.phone,
                                      dealerId: dealer.id,
                                      source: 'Dealer Profile Call CTA',
                                    );
                                  },
                                  icon: const Icon(Icons.phone_outlined, size: 16),
                                  label: Text('Call ${dealer.phone}'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Dealer Cars Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Cars Available (${dealerCars.length})',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          TextButton.icon(
                            onPressed: () => context.go('/cars'),
                            icon: const Icon(Icons.arrow_forward, size: 14),
                            label: const Text('Search All Cars'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (dealerCars.isEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text('This dealership has no active listings currently.'),
                          ),
                        ),
                      ] else ...[
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final count = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);
                            if (count == 1) {
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: dealerCars.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 18),
                                itemBuilder: (context, index) => CarCard(car: dealerCars[index], showDealer: false),
                              );
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: count,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                childAspectRatio: count == 2 ? 0.72 : 0.70,
                              ),
                              itemCount: dealerCars.length,
                              itemBuilder: (context, index) => CarCard(car: dealerCars[index], showDealer: false),
                            );
                          },
                        ),
                      ],
                    ],
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
