import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/app_data_store.dart';
import '../../../models/car_model.dart';
import '../../../models/dealer_model.dart';
import '../../../services/analytics_service.dart';
import '../../../widgets/common/navbar.dart';
import '../../../widgets/common/footer.dart';
import '../../../widgets/common/enquiry_dialog.dart';

class CarDetailPage extends StatefulWidget {
  final String carId;

  const CarDetailPage({super.key, required this.carId});

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  int _selectedImageIndex = 0;
  final AnalyticsService _analytics = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    final dataStore = AppDataStore();
    final car = dataStore.cars.firstWhere((c) => c.id == widget.carId, orElse: () => dataStore.cars.first);
    final dealer = dataStore.dealers.firstWhere((d) => d.id == car.dealerId, orElse: () => dataStore.dealers.first);

    final isDesktop = Responsive.isDesktop(context);
    final allImages = car.images.isNotEmpty ? car.images : [car.coverImage];

    return Scaffold(
      appBar: const Navbar(),
      bottomNavigationBar: !isDesktop
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: const Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Price (Excl. RTO)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Formatters.formatPriceLakh(car.price),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accent),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _analytics.triggerWhatsAppChat(
                          whatsappNumber: dealer.whatsapp,
                          dealerId: dealer.id,
                          carId: car.id,
                          carTitle: car.title,
                          source: 'Mobile Sticky Bottom Bar WhatsApp',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whatsappDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        EnquiryDialog.show(
                          context,
                          car: car,
                          dealerId: dealer.id,
                          dealerName: dealer.businessName,
                          source: 'Mobile Sticky Bottom Bar Enquiry',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.mail_outline_rounded, size: 16),
                      label: const Text('Enquire', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Breadcrumbs Bar
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: EdgeInsets.symmetric(horizontal: Responsive.isMobile(context) ? 14 : 24, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => context.go('/'),
                          child: const Text('Home', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ),
                        const Text(' / ', style: TextStyle(color: AppColors.textMuted)),
                        InkWell(
                          onTap: () => context.go('/cars'),
                          child: const Text('Used Cars', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ),
                        const Text(' / ', style: TextStyle(color: AppColors.textMuted)),
                        Text(car.city, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const Text(' / ', style: TextStyle(color: AppColors.textMuted)),
                        Text(
                          car.title,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Content Area
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.isMobile(context) ? 14 : 24,
                vertical: Responsive.isMobile(context) ? 16 : 30,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column (Gallery + Specs + Features + Description)
                            Expanded(
                              flex: 7,
                              child: _buildLeftCarContent(context, car, allImages),
                            ),
                            const SizedBox(width: 32),
                            // Right Column (Sticky Pricing Card + Lead CTAs + Dealer Card)
                            Expanded(
                              flex: 4,
                              child: _buildRightActionSidebar(context, car, dealer),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildLeftCarContent(context, car, allImages),
                            const SizedBox(height: 24),
                            _buildRightActionSidebar(context, car, dealer),
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

  Widget _buildLeftCarContent(BuildContext context, CarModel car, List<String> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Location
        Text(
          car.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${car.city}, India', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${car.viewsCount} Views',
                style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Large Image Gallery
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Image.network(
              images[_selectedImageIndex % images.length],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.directions_car, size: 64, color: AppColors.textMuted),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Thumbnail Row
        if (images.length > 1) ...[
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedImageIndex;
                return InkWell(
                  onTap: () => setState(() => _selectedImageIndex = index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.border,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(images[index], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Key Highlights Grid
        Card(
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
                const Text('Key Specifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Divider(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 550;
                    final itemWidth = isMobile ? (constraints.maxWidth - 16) / 2 : 180.0;
                    return Wrap(
                      spacing: isMobile ? 16 : 24,
                      runSpacing: isMobile ? 16 : 20,
                      children: [
                        _specBox(Icons.calendar_month_outlined, 'Manufacturing Year', '${car.year}', width: itemWidth),
                        _specBox(Icons.speed, 'Kilometres Driven', Formatters.formatKm(car.kilometers), width: itemWidth),
                        _specBox(Icons.local_gas_station_outlined, 'Fuel Type', car.fuelType, width: itemWidth),
                        _specBox(Icons.settings_outlined, 'Transmission', car.transmission, width: itemWidth),
                        _specBox(Icons.person_outline, 'Ownership', car.ownersCount, width: itemWidth),
                        _specBox(Icons.security_outlined, 'Insurance Valid Till', car.insuranceValidTill, width: itemWidth),
                        _specBox(Icons.palette_outlined, 'Color', car.color, width: itemWidth),
                        _specBox(Icons.electric_bolt_outlined, 'Engine Capacity', car.engine, width: itemWidth),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Description
        Card(
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
                const Text('Dealer\'s Vehicle Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Divider(height: 24),
                Text(
                  car.description,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Features Checklist
        if (car.features.isNotEmpty) ...[
          Card(
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
                  const Text('Car Features & Equipment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Divider(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: car.features.map((f) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: AppColors.emerald),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(f, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _specBox(IconData icon, String label, String value, {double width = 180}) {
    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightActionSidebar(BuildContext context, CarModel car, DealerModel dealer) {
    return Column(
      children: [
        // Lead CTA Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price (Excluding RTO Transfer)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      Formatters.formatPriceLakh(car.price),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Verified Deal',
                        style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.formatCurrency(car.price),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const Divider(height: 32),

                // Primary CTA: "Enquire About This Car"
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      EnquiryDialog.show(
                        context,
                        car: car,
                        dealerId: dealer.id,
                        dealerName: dealer.businessName,
                        source: 'Car Detail Page Hero CTA',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.mail_outline_rounded, size: 20),
                    label: const Text(
                      'Enquire About This Car',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary CTA: WhatsApp Dealer
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _analytics.triggerWhatsAppChat(
                        whatsappNumber: dealer.whatsapp,
                        dealerId: dealer.id,
                        carId: car.id,
                        carTitle: car.title,
                        source: 'Car Detail Page WhatsApp Button',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whatsappDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text(
                      'WhatsApp Dealer',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tertiary CTA: Call Dealer
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _analytics.triggerPhoneCall(
                        phoneNumber: dealer.phone,
                        dealerId: dealer.id,
                        carId: car.id,
                        source: 'Car Detail Page Call Button',
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.textPrimary, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.phone_outlined, size: 18),
                    label: Text(
                      'Call Dealer (${dealer.phone})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Dealer Info Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
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
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (dealer.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, size: 16, color: AppColors.emerald),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('${dealer.city}, ${dealer.state}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (dealer.isVerified)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 16, color: AppColors.emerald),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Verified Business Documentation',
                            style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (dealer.isDemo) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Demo Dealer Profile (Sample Data)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  dealer.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(dealer.workingHours, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push('/dealer/${dealer.id}'),
                    child: const Text('View All Cars from This Dealer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
