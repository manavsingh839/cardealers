import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/app_data_store.dart';
import '../../../models/dealer_model.dart';
import '../../../widgets/common/navbar.dart';
import '../../../widgets/common/footer.dart';

class DealerDirectoryPage extends StatefulWidget {
  const DealerDirectoryPage({super.key});

  @override
  State<DealerDirectoryPage> createState() => _DealerDirectoryPageState();
}

class _DealerDirectoryPageState extends State<DealerDirectoryPage> {
  String _selectedCity = 'All Cities';

  @override
  Widget build(BuildContext context) {
    final dataStore = AppDataStore();
    List<DealerModel> dealers = dataStore.dealers.where((d) => d.status == 'approved').toList();

    if (_selectedCity != 'All Cities') {
      dealers = dealers.where((d) => d.city == _selectedCity).toList();
    }

    return Scaffold(
      appBar: const Navbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Header
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verified Automotive Dealerships',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Connect directly with certified pre-owned car showrooms across major Indian cities',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      // City filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: AppConstants.cities.take(8).map((city) {
                            final isSelected = _selectedCity == city;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(city, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary)),
                                selected: isSelected,
                                selectedColor: AppColors.accent,
                                onSelected: (_) => setState(() => _selectedCity = city),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Dealer Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final count = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                      if (count == 1) {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dealers.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final dealer = dealers[index];
                            final dealerCars = dataStore.cars.where((c) => c.dealerId == dealer.id).length;
                            return _buildDealerCard(context, dealer, dealerCars);
                          },
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: count,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: count == 2 ? 1.25 : 1.15,
                        ),
                        itemCount: dealers.length,
                        itemBuilder: (context, index) {
                          final dealer = dealers[index];
                          final dealerCars = dataStore.cars.where((c) => c.dealerId == dealer.id).length;
                          return _buildDealerCard(context, dealer, dealerCars);
                        },
                      );
                    },
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

  Widget _buildDealerCard(BuildContext context, DealerModel dealer, int dealerCars) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => context.push('/dealer/${dealer.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(dealer.logoUrl),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                dealer.businessName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (dealer.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, size: 16, color: AppColors.emerald),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dealer.city}, ${dealer.state}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        if (dealer.isDemo) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text('Demo Dealer', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                dealer.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 10),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$dealerCars Available Cars',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent, fontSize: 13),
                  ),
                  OutlinedButton(
                    onPressed: () => context.push('/dealer/${dealer.id}'),
                    child: const Text('View Profile', style: TextStyle(fontSize: 12)),
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
