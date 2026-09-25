import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../providers/admin_portal_provider.dart';
import '../../widgets/common/status_badge.dart';

class AdminCarsPage extends StatefulWidget {
  const AdminCarsPage({super.key});

  @override
  State<AdminCarsPage> createState() => _AdminCarsPageState();
}

class _AdminCarsPageState extends State<AdminCarsPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminPortalProvider>();
    final allCars = admin.cars;

    var filtered = allCars;
    if (_filter == 'Featured') {
      filtered = allCars.where((c) => c.isFeatured).toList();
    } else if (_filter == 'Available') {
      filtered = allCars.where((c) => c.status == 'available').toList();
    } else if (_filter == 'Sold') {
      filtered = allCars.where((c) => c.status == 'sold').toList();
    }

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
                      'Car Listings & Featured Moderation',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Toggle featured cars for top marketplace placement. Featured metadata stored for future monetization.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Featured', 'Available', 'Sold'].map((f) {
                  final isSelected = _filter == f;
                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(f, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 12)),
                    selected: isSelected,
                    selectedColor: AppColors.accent,
                    onSelected: (_) => setState(() => _filter = f),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final car = filtered[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      car.coverImage,
                      width: 70,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(width: 70, height: 50, color: Colors.grey.shade200),
                    ),
                  ),
                  title: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        car.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      StatusBadge(status: car.status),
                      if (car.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(4)),
                          child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${Formatters.formatPriceLakh(car.price)} • Dealer: ${car.dealerName} (${car.dealerCity}) • ${car.viewsCount} Views • ${car.whatsappClicks} WhatsApp Leads',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  trailing: Responsive.isMobile(context)
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (value) {
                            if (value == 'view') {
                              context.push('/car/${car.id}');
                            } else if (value == 'feature') {
                              admin.toggleFeatured(car.id, !car.isFeatured);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: car.isFeatured ? AppColors.primary : AppColors.amber,
                                  content: Text(car.isFeatured ? 'Car removed from featured' : 'Car marked as Featured!'),
                                ),
                              );
                            } else if (value == 'delete') {
                              admin.deleteCar(car.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.open_in_new, size: 16),
                                  SizedBox(width: 8),
                                  Text('View on Website'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'feature',
                              child: Row(
                                children: [
                                  Icon(car.isFeatured ? Icons.star_border : Icons.star, size: 16, color: AppColors.amber),
                                  SizedBox(width: 8),
                                  Text(car.isFeatured ? 'Unfeature Car' : 'Feature Car'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 16, color: AppColors.red),
                                  SizedBox(width: 8),
                                  Text('Delete Car'),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.open_in_new, size: 18),
                              tooltip: 'View on Website',
                              onPressed: () => context.push('/car/${car.id}'),
                            ),
                            // Feature / Unfeature Button
                            ElevatedButton.icon(
                              onPressed: () {
                                admin.toggleFeatured(car.id, !car.isFeatured);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: car.isFeatured ? AppColors.primary : AppColors.amber,
                                    content: Text(car.isFeatured ? 'Car removed from featured' : 'Car marked as Featured!'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: car.isFeatured ? Colors.grey.shade200 : AppColors.amber,
                                foregroundColor: car.isFeatured ? AppColors.textPrimary : Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              icon: Icon(car.isFeatured ? Icons.star_border : Icons.star, size: 14),
                              label: Text(car.isFeatured ? 'Unfeature' : 'Feature Car', style: const TextStyle(fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                              tooltip: 'Delete Car',
                              onPressed: () => admin.deleteCar(car.id),
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
