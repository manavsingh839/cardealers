import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../providers/dealer_portal_provider.dart';
import '../../widgets/common/status_badge.dart';

class DealerCarsPage extends StatefulWidget {
  final VoidCallback onAddCar;

  const DealerCarsPage({super.key, required this.onAddCar});

  @override
  State<DealerCarsPage> createState() => _DealerCarsPageState();
}

class _DealerCarsPageState extends State<DealerCarsPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<DealerPortalProvider>();
    final allCars = portal.dealerCars;

    var displayCars = allCars;
    if (_filter == 'Active') {
      displayCars = allCars.where((c) => c.status == 'available').toList();
    } else if (_filter == 'Sold') {
      displayCars = allCars.where((c) => c.status == 'sold').toList();
    }

    final carsUsed = allCars.length;
    final carLimit = portal.carLimit;
    final isLimitReached = carsUsed >= carLimit;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Add Car CTA
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Car Inventory Management',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your showroom stock, view performance, and mark vehicles as sold.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: isLimitReached ? null : widget.onAddCar,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Vehicle'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Plan Listing Limit Usage Indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLimitReached ? AppColors.redLight : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isLimitReached ? AppColors.red : AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  isLimitReached ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
                  color: isLimitReached ? AppColors.red : AppColors.accent,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(
                            isLimitReached
                                ? 'Listing Limit Reached ($carsUsed / $carLimit Cars)'
                                : 'Inventory Slot Usage: $carsUsed / $carLimit Cars Allowed',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isLimitReached ? AppColors.red : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${((carsUsed / carLimit) * 100).toInt()}% used',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: carLimit > 0 ? (carsUsed / carLimit).clamp(0.0, 1.0) : 1.0,
                          backgroundColor: AppColors.surfaceMuted,
                          color: isLimitReached ? AppColors.red : AppColors.accent,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Filter Chips (All, Active, Sold)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['All', 'Active', 'Sold'].map((f) {
              final isSelected = _filter == f;
              return ChoiceChip(
                label: Text('$f (${_getCount(f, allCars)})', style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary)),
                selected: isSelected,
                showCheckmark: false,
                selectedColor: AppColors.accent,
                onSelected: (_) => setState(() => _filter = f),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Inventory Table / List
          if (displayCars.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('No vehicles found in this category.'),
              ),
            ),
          ] else ...[
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayCars.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final car = displayCars[index];
                  final isAvailable = car.status == 'available';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        car.coverImage,
                        width: 75,
                        height: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 75,
                          height: 55,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.directions_car, size: 28),
                        ),
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
                        StatusBadge(status: isAvailable ? 'Active' : 'Sold'),
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
                        '${Formatters.formatPriceLakh(car.price)} • ${car.fuelType} • ${car.transmission} • ${Formatters.formatKm(car.kilometers)} • ${car.viewsCount} Views • ${car.whatsappClicks} WhatsApp Leads',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    trailing: Responsive.isMobile(context)
                        ? PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (val) {
                              if (val == 'view') context.push('/car/${car.id}');
                              if (val == 'sold') portal.markCarSold(car.id);
                              if (val == 'delete') _confirmDelete(context, portal, car.id);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'view', child: Text('View on Website')),
                              if (isAvailable) const PopupMenuItem(value: 'sold', child: Text('Mark as Sold')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete Car', style: TextStyle(color: AppColors.red))),
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
                              if (isAvailable) ...[
                                TextButton.icon(
                                  onPressed: () => portal.markCarSold(car.id),
                                  icon: const Icon(Icons.check, size: 16, color: AppColors.emerald),
                                  label: const Text('Mark Sold', style: TextStyle(color: AppColors.emerald, fontSize: 12)),
                                ),
                              ],
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                                tooltip: 'Delete Car',
                                onPressed: () => _confirmDelete(context, portal, car.id),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _getCount(String filter, List cars) {
    if (filter == 'All') return cars.length;
    if (filter == 'Active') return cars.where((c) => c.status == 'available').length;
    if (filter == 'Sold') return cars.where((c) => c.status == 'sold').length;
    return 0;
  }

  void _confirmDelete(BuildContext context, DealerPortalProvider portal, String carId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Car Listing?'),
        content: const Text('Are you sure you want to remove this vehicle from your inventory? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              portal.deleteCar(carId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
