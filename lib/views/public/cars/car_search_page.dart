import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/car_catalog_provider.dart';
import '../../../widgets/common/navbar.dart';
import '../../../widgets/common/footer.dart';
import '../../../widgets/common/car_card.dart';

class CarSearchPage extends StatefulWidget {
  const CarSearchPage({super.key});

  @override
  State<CarSearchPage> createState() => _CarSearchPageState();
}

class _CarSearchPageState extends State<CarSearchPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final catalog = context.read<CarCatalogProvider>();
    _searchController.text = catalog.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CarCatalogProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final cars = catalog.filteredCars;
    final hasActiveFilters = catalog.selectedBrand != 'All Brands' ||
        catalog.selectedCity != 'All Cities' ||
        catalog.selectedFuel != 'All Fuels' ||
        catalog.selectedCondition != 'All Conditions' ||
        catalog.selectedTransmission != 'All Transmissions' ||
        catalog.selectedBodyType != 'All Body Types' ||
        catalog.selectedOwnerCount != 'Any Ownership';

    return Scaffold(
      appBar: const Navbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Filter Bar / Search Header
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.isMobile(context) ? 14 : 24,
                vertical: 14,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop
                      ? Row(
                          children: [
                            Expanded(child: _buildSearchField(catalog)),
                            const SizedBox(width: 16),
                            _buildSortDropdown(catalog, isDesktop: true),
                          ],
                        )
                      : Column(
                          children: [
                            _buildSearchField(catalog),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _openFilterBottomSheet(context, catalog),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      backgroundColor: hasActiveFilters ? AppColors.accentLight : null,
                                      side: BorderSide(
                                        color: hasActiveFilters ? AppColors.accent : AppColors.border,
                                        width: hasActiveFilters ? 1.5 : 1,
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: Icon(
                                      Icons.tune_rounded,
                                      size: 18,
                                      color: hasActiveFilters ? AppColors.accent : AppColors.textPrimary,
                                    ),
                                    label: Text(
                                      hasActiveFilters ? 'Filters (Active)' : 'Filters',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: hasActiveFilters ? AppColors.accent : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: _buildSortDropdown(catalog)),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // Content Area (Sidebar Filters + Results Grid)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.isMobile(context) ? 14 : 24,
                vertical: Responsive.isMobile(context) ? 16 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Desktop Left Filter Sidebar
                      if (isDesktop) ...[
                        SizedBox(
                          width: 300,
                          child: Card(
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: _buildFilterControls(context, catalog),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                      ],

                      // Results Area
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                Text(
                                  'Showing ${cars.length} Available Vehicles',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                ),
                                if (catalog.selectedBrand != 'All Brands' || catalog.selectedCity != 'All Cities')
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      catalog.resetFilters();
                                    },
                                    child: const Text('Reset All Filters'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            if (cars.isEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(48),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.car_crash_outlined, size: 54, color: AppColors.textMuted),
                                    const SizedBox(height: 16),
                                    const Text('No cars match your search filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    const Text('Try adjusting your budget, fuel, or city filters to find more cars.', style: TextStyle(color: AppColors.textSecondary)),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        catalog.resetFilters();
                                      },
                                      child: const Text('Reset Filters'),
                                    ),
                                  ],
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
                                      itemCount: cars.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 18),
                                      itemBuilder: (context, index) => CarCard(car: cars[index]),
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
                                    itemCount: cars.length,
                                    itemBuilder: (context, index) => CarCard(car: cars[index]),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
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

  Widget _buildSearchField(CarCatalogProvider catalog) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search cars by make, model, city...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  catalog.setSearchQuery('');
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      onSubmitted: (v) => catalog.setSearchQuery(v),
    );
  }

  Widget _buildSortDropdown(CarCatalogProvider catalog, {bool isDesktop = false}) {
    return Container(
      width: isDesktop ? 220 : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: catalog.sortBy,
          isExpanded: true,
          icon: const Icon(Icons.sort_rounded, size: 18),
          items: AppConstants.sortOptions.map((s) {
            return DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)));
          }).toList(),
          onChanged: (v) {
            if (v != null) catalog.setSortBy(v);
          },
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterControls(BuildContext context, CarCatalogProvider catalog) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.tune_rounded, size: 15, color: AppColors.accent),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Filters',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => catalog.resetFilters(),
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  'Clear All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 24, thickness: 1, color: AppColors.border),

        // Condition
        _filterLabel('Condition'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _filterChip(
              label: 'All',
              isSelected: catalog.selectedCondition == 'All Conditions',
              onSelected: () => catalog.setCondition('All Conditions'),
            ),
            _filterChip(
              label: 'Used',
              isSelected: catalog.selectedCondition == 'Used',
              onSelected: () => catalog.setCondition('Used'),
            ),
            _filterChip(
              label: 'New',
              isSelected: catalog.selectedCondition == 'New',
              onSelected: () => catalog.setCondition('New'),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Brand
        _filterLabel('Brand / Manufacturer'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: catalog.selectedBrand,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.textSecondary),
              items: AppConstants.brands.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)))).toList(),
              onChanged: (v) {
                if (v != null) catalog.setBrand(v);
              },
            ),
          ),
        ),
        const SizedBox(height: 18),

        // City
        _filterLabel('City / Location'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: catalog.selectedCity,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.textSecondary),
              items: AppConstants.cities.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)))).toList(),
              onChanged: (v) {
                if (v != null) catalog.setCity(v);
              },
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Fuel Type
        _filterLabel('Fuel Type'),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: AppConstants.fuelTypes.map((f) {
            final isSelected = catalog.selectedFuel == f;
            final label = f == 'All Fuels' ? 'All' : f;
            return _filterChip(
              label: label,
              isSelected: isSelected,
              onSelected: () => catalog.setFuel(f),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // Transmission
        _filterLabel('Transmission'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.transmissions.map((t) {
            final isSelected = catalog.selectedTransmission == t;
            final label = t == 'All Transmissions' ? 'All' : t;
            return _filterChip(
              label: label,
              isSelected: isSelected,
              onSelected: () => catalog.setTransmission(t),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // Body Type
        _filterLabel('Body Type'),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: AppConstants.bodyTypes.take(5).map((b) {
            final isSelected = catalog.selectedBodyType == b;
            final label = b == 'All Body Types' ? 'All' : b;
            return _filterChip(
              label: label,
              isSelected: isSelected,
              onSelected: () => catalog.setBodyType(b),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // Owner Count
        _filterLabel('Ownership'),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: AppConstants.ownerCounts.map((o) {
            final isSelected = catalog.selectedOwnerCount == o;
            final label = o == 'Any Ownership' ? 'All' : o;
            return _filterChip(
              label: label,
              isSelected: isSelected,
              onSelected: () => catalog.setOwnerCount(o),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _filterLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.2),
      ),
    );
  }

  void _openFilterBottomSheet(BuildContext context, CarCatalogProvider catalog) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _buildFilterControls(context, catalog),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
