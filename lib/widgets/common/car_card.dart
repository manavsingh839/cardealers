import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/car_model.dart';
import '../../services/analytics_service.dart';
import '../../data/app_data_store.dart';
import 'enquiry_dialog.dart';

class CarCard extends StatelessWidget {
  final CarModel car;
  final bool showDealer;

  const CarCard({
    super.key,
    required this.car,
    this.showDealer = true,
  });

  @override
  Widget build(BuildContext context) {
    final dataStore = AppDataStore();
    final dealer = dataStore.dealers.firstWhere((d) => d.id == car.dealerId, orElse: () => dataStore.dealers.first);
    final analytics = AnalyticsService();

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          analytics.trackCarView(car);
          context.push('/car/${car.id}');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    car.coverImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.directions_car, size: 48, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
                // Badges overlay
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    children: [
                      if (car.isFeatured) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'FEATURED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          car.condition.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Views Counter
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.remove_red_eye_outlined, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${car.viewsCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    car.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price
                  Text(
                    Formatters.formatPriceLakh(car.price),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Specs Row (Kms, Fuel, Transmission, City)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _specItem(Icons.speed, Formatters.formatKm(car.kilometers)),
                      _specItem(Icons.local_gas_station, car.fuelType),
                      _specItem(Icons.settings, car.transmission),
                      _specItem(Icons.location_on_outlined, car.city),
                    ],
                  ),

                  if (showDealer) ...[
                    const Divider(height: 20, color: AppColors.border),
                    // Dealer Info Bar
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(dealer.logoUrl),
                          backgroundColor: Colors.grey.shade200,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  dealer.businessName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (dealer.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, size: 14, color: AppColors.emerald),
                              ],
                              if (dealer.isDemo) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    'Demo',
                                    style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Quick WhatsApp Icon
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.whatsappDark),
                          tooltip: 'WhatsApp Dealer',
                          onPressed: () {
                            analytics.triggerWhatsAppChat(
                              whatsappNumber: dealer.whatsapp,
                              dealerId: dealer.id,
                              carId: car.id,
                              carTitle: car.title,
                              source: 'Car Card WhatsApp Icon',
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        // Quick Enquiry Icon
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.accent),
                          tooltip: 'Enquire',
                          onPressed: () {
                            EnquiryDialog.show(
                              context,
                              car: car,
                              dealerId: dealer.id,
                              dealerName: dealer.businessName,
                              source: 'Car Card Quick Enquiry',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
