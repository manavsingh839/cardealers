import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/car_catalog_provider.dart';
import '../../../data/app_data_store.dart';
import '../../../widgets/common/navbar.dart';
import '../../../widgets/common/footer.dart';
import '../../../widgets/common/car_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedBrand = 'All Brands';
  String _selectedCity = 'All Cities';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CarCatalogProvider>();
    final dataStore = AppDataStore();
    final featuredCars = catalog.featuredCars;
    final latestCars = dataStore.cars.take(8).toList();
    final verifiedDealers = dataStore.dealers.where((d) => d.isVerified).take(6).toList();

    return Scaffold(
      appBar: const Navbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Search Section
            _buildHero(context, catalog),

            // 2. Value Proposition Strip
            _buildValuePropositionStrip(context),

            // 3. Featured Cars
            if (featuredCars.isNotEmpty) _buildFeaturedSection(context, featuredCars),

            // 4. Browse by Brand
            _buildBrowseByBrand(context, catalog),

            // 5. Latest Arrivals
            _buildLatestArrivals(context, latestCars),

            // 6. Browse by City
            _buildBrowseByCity(context, catalog),

            // 7. Featured Verified Dealers
            _buildFeaturedDealers(context, verifiedDealers),

            // 8. Why Choose Us & How it works
            _buildWhyChooseUs(context),

            // 9. Footer
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, CarCatalogProvider catalog) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F264A)],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: isMobile ? 40 : 70),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.orange, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isMobile ? 'AUTOMOTIVE LEAD GENERATION' : 'INDIA\'S AUTOMOTIVE LEAD GENERATION MARKETPLACE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                'Find Your Dream Car or\nList Your Vehicles for Verified Leads',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 28 : 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),

              // Subtitle
              Text(
                'Browse 50+ inspected pre-owned cars from top certified Indian dealerships, or join as a dealer with 7 Days Free Trial.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // Hero Search Card
              Container(
                padding: isMobile
                    ? const EdgeInsets.all(16)
                    : const EdgeInsets.fromLTRB(16, 8, 8, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: isMobile
                    ? Column(
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search by model (e.g. Swift, Thar, Creta)...',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (v) => _searchQuery = v,
                          ),
                          const SizedBox(height: 10),
                          _buildMobileBrandDropdown(),
                          const SizedBox(height: 10),
                          _buildMobileCityDropdown(),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => _executeSearch(context, catalog),
                              icon: const Icon(Icons.search),
                              label: const Text('Search Available Cars'),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 1. Text input
                            Expanded(
                              flex: 3,
                              child: TextField(
                                textAlignVertical: TextAlignVertical.center,
                                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                decoration: const InputDecoration(
                                  hintText: 'Search car model or keyword...',
                                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.normal),
                                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                onChanged: (v) => _searchQuery = v,
                                onSubmitted: (_) => _executeSearch(context, catalog),
                              ),
                            ),

                            // Divider 1
                            Container(
                              height: 28,
                              width: 1,
                              color: AppColors.border,
                              margin: const EdgeInsets.symmetric(horizontal: 14),
                            ),

                            // 2. Brand Dropdown
                            Expanded(
                              flex: 2,
                              child: _buildDesktopBrandDropdown(),
                            ),

                            // Divider 2
                            Container(
                              height: 28,
                              width: 1,
                              color: AppColors.border,
                              margin: const EdgeInsets.symmetric(horizontal: 14),
                            ),

                            // 3. City Dropdown
                            Expanded(
                              flex: 2,
                              child: _buildDesktopCityDropdown(),
                            ),

                            const SizedBox(width: 12),

                            // 4. Action Button
                            SizedBox(
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: () => _executeSearch(context, catalog),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 22),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.search, size: 18),
                                label: const Text(
                                  'Search Cars',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopBrandDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedBrand,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 20),
        onChanged: (v) => setState(() => _selectedBrand = v ?? 'All Brands'),
        selectedItemBuilder: (context) {
          return AppConstants.brands.map((b) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.directions_car_outlined, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    b,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList();
        },
        items: AppConstants.brands.map((b) {
          return DropdownMenuItem<String>(
            value: b,
            child: Row(
              children: [
                const Icon(Icons.directions_car_outlined, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(b, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDesktopCityDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedCity,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 20),
        onChanged: (v) => setState(() => _selectedCity = v ?? 'All Cities'),
        selectedItemBuilder: (context) {
          return AppConstants.cities.map((c) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList();
        },
        items: AppConstants.cities.map((c) {
          return DropdownMenuItem<String>(
            value: c,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(c, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileBrandDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBrand,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 20),
          onChanged: (v) => setState(() => _selectedBrand = v ?? 'All Brands'),
          selectedItemBuilder: (context) {
            return AppConstants.brands.map((b) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car_outlined, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(b, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                ],
              );
            }).toList();
          },
          items: AppConstants.brands.map((b) {
            return DropdownMenuItem<String>(
              value: b,
              child: Row(
                children: [
                  const Icon(Icons.directions_car_outlined, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(b, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileCityDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 20),
          onChanged: (v) => setState(() => _selectedCity = v ?? 'All Cities'),
          selectedItemBuilder: (context) {
            return AppConstants.cities.map((c) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(c, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                ],
              );
            }).toList();
          },
          items: AppConstants.cities.map((c) {
            return DropdownMenuItem<String>(
              value: c,
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(c, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _executeSearch(BuildContext context, CarCatalogProvider catalog) {
    catalog.setSearchQuery(_searchQuery);
    catalog.setBrand(_selectedBrand);
    catalog.setCity(_selectedCity);
    context.push('/cars');
  }

  Widget _buildValuePropositionStrip(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.orangeLight,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      child: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars_rounded, color: AppColors.orange, size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Are you a Dealer? List Your Cars & Get More Customer Enquiries',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9A3412),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => context.go('/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              child: const Text('Start 7-Day Free Trial'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, List featuredCars) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          'Featured Handpicked Vehicles',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Verified pre-owned cars from top dealerships with inspection certificates',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/cars'),
                    icon: const Text('View All Cars'),
                    label: const Icon(Icons.arrow_forward, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 650 ? 2 : 1);
                  final count = featuredCars.length > 6 ? 6 : featuredCars.length;
                  if (crossAxisCount == 1) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: count,
                      separatorBuilder: (context, index) => const SizedBox(height: 18),
                      itemBuilder: (context, index) => CarCard(car: featuredCars[index]),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: crossAxisCount == 2 ? 0.72 : 0.70,
                    ),
                    itemCount: count,
                    itemBuilder: (context, index) => CarCard(car: featuredCars[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseByBrand(BuildContext context, CarCatalogProvider catalog) {
    final brands = [
      {'name': 'Maruti Suzuki', 'icon': Icons.directions_car, 'count': '14 Cars'},
      {'name': 'Hyundai', 'icon': Icons.directions_car_filled, 'count': '9 Cars'},
      {'name': 'Tata', 'icon': Icons.shield_outlined, 'count': '8 Cars'},
      {'name': 'Mahindra', 'icon': Icons.terrain, 'count': '7 Cars'},
      {'name': 'Toyota', 'icon': Icons.verified_user_outlined, 'count': '6 Cars'},
      {'name': 'Kia', 'icon': Icons.speed, 'count': '4 Cars'},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Browse by Popular Brands',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text('Explore certified vehicles by top automotive manufacturers in India', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 650;
                  final itemWidth = isNarrow ? (constraints.maxWidth - 14) / 2 : 170.0;
                  return Wrap(
                    spacing: isNarrow ? 14 : 16,
                    runSpacing: isNarrow ? 14 : 16,
                    children: brands.map((b) {
                      return InkWell(
                        onTap: () {
                          catalog.setBrand(b['name'] as String);
                          context.push('/cars');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: itemWidth,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Icon(b['icon'] as IconData, size: 30, color: AppColors.accent),
                              const SizedBox(height: 8),
                              Text(
                                b['name'] as String,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                b['count'] as String,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestArrivals(BuildContext context, List latestCars) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          'Recently Added Vehicles',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text('Fresh pre-owned inventory added by verified dealerships across India', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => context.push('/cars'),
                    child: const Text('Explore All Listings'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 650 ? 2 : 1);
                  if (crossAxisCount == 1) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: latestCars.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 18),
                      itemBuilder: (context, index) => CarCard(car: latestCars[index]),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: crossAxisCount == 2 ? 0.72 : 0.70,
                    ),
                    itemCount: latestCars.length,
                    itemBuilder: (context, index) => CarCard(car: latestCars[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseByCity(BuildContext context, CarCatalogProvider catalog) {
    final cities = [
      {'name': 'Muktsar', 'state': 'Punjab', 'count': '6 Dealers'},
      {'name': 'Delhi NCR', 'state': 'Capital Region', 'count': '12 Dealers'},
      {'name': 'Mumbai', 'state': 'Maharashtra', 'count': '9 Dealers'},
      {'name': 'Chandigarh', 'state': 'Punjab & Haryana', 'count': '8 Dealers'},
      {'name': 'Bengaluru', 'state': 'Karnataka', 'count': '11 Dealers'},
      {'name': 'Pune', 'state': 'Maharashtra', 'count': '7 Dealers'},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Browse Cars by City', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Discover certified inventory from dealerships located nearest to you', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 650;
                  final itemWidth = isNarrow ? (constraints.maxWidth - 14) / 2 : 175.0;
                  return Wrap(
                    spacing: isNarrow ? 14 : 16,
                    runSpacing: isNarrow ? 14 : 16,
                    children: cities.map((c) {
                      return InkWell(
                        onTap: () {
                          catalog.setCity(c['name'] as String);
                          context.push('/cars');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: itemWidth,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_city, color: AppColors.accent, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      c['name'] as String,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c['state'] as String,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 2),
                              Text(c['count'] as String, style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedDealers(BuildContext context, List verifiedDealers) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        Text('Featured Verified Dealers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('Connect with established dealers with verified registration and transparent pricing', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => context.push('/dealers'),
                    child: const Text('View All Dealers'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: verifiedDealers.map((dealer) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: InkWell(
                      onTap: () => context.push('/dealer/${dealer.id}'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: Responsive.isMobile(context) ? double.infinity : 360,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
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
                                            const SizedBox(width: 6),
                                            const Icon(Icons.verified, size: 16, color: AppColors.emerald),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${dealer.city}, ${dealer.state}',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              dealer.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                            ),
                            const Divider(height: 24, color: AppColors.border),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (dealer.isDemo)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Demo Dealer', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  )
                                else
                                  const SizedBox(),
                                TextButton.icon(
                                  onPressed: () => context.push('/dealer/${dealer.id}'),
                                  icon: const Text('View Inventory', style: TextStyle(fontSize: 13)),
                                  label: const Icon(Icons.arrow_forward_rounded, size: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhyChooseUs(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Text(
                'Why Choose AutoDealers India',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Built for buyers who demand trust and dealers who want real customer enquiries',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _benefitCard(
                    context,
                    Icons.verified_user_rounded,
                    AppColors.emerald,
                    'Verified Dealerships',
                    'Every dealer undergoes verification checks to ensure clear title transfers and authentic documents.',
                  ),
                  _benefitCard(
                    context,
                    Icons.chat_bubble_outline_rounded,
                    AppColors.whatsappDark,
                    'Instant WhatsApp Leads',
                    'Direct contact via WhatsApp and phone. No intermediaries, no hidden fees, instant responses.',
                  ),
                  _benefitCard(
                    context,
                    Icons.security_rounded,
                    AppColors.accent,
                    'Transparent Pricing in ₹',
                    'All prices displayed in accurate Indian Rupee Lakhs with full RTO, insurance, and service background.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitCard(BuildContext context, IconData icon, Color color, String title, String desc) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      width: isMobile ? double.infinity : 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
