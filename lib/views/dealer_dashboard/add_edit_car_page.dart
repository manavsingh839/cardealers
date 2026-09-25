import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../models/car_model.dart';
import '../../providers/dealer_portal_provider.dart';

class AddEditCarPage extends StatefulWidget {
  final CarModel? initialCar;
  final VoidCallback onSuccess;

  const AddEditCarPage({super.key, this.initialCar, required this.onSuccess});

  @override
  State<AddEditCarPage> createState() => _AddEditCarPageState();
}

class _AddEditCarPageState extends State<AddEditCarPage> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _variantController = TextEditingController();
  final _priceController = TextEditingController();
  final _kmController = TextEditingController();
  final _engineController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _brand = 'Maruti Suzuki';
  int _year = 2023;
  String _fuelType = 'Petrol';
  String _transmission = 'Manual';
  String _bodyType = 'SUV';
  String _ownersCount = '1st Owner';
  String _city = 'Muktsar';
  String _condition = 'Used';
  List<String> _selectedFeatures = [];
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialCar != null) {
      final c = widget.initialCar!;
      _modelController.text = c.model;
      _variantController.text = c.variant;
      _priceController.text = c.price.toStringAsFixed(0);
      _kmController.text = c.kilometers.toString();
      _engineController.text = c.engine;
      _insuranceController.text = c.insuranceValidTill;
      _colorController.text = c.color;
      _descriptionController.text = c.description;
      _brand = c.brand;
      _year = c.year;
      _fuelType = c.fuelType;
      _transmission = c.transmission;
      _bodyType = c.bodyType;
      _ownersCount = c.ownersCount;
      _city = c.city;
      _condition = c.condition;
      _selectedFeatures = List.from(c.features);
      _images = List.from(c.images);
    } else {
      _insuranceController.text = 'Valid Comprehensive (1 Year)';
      _colorController.text = 'Pearl White';
      _engineController.text = '1197 cc';
      _descriptionController.text = 'Certified inspected vehicle with zero accidents, complete service history, verified non-tampered odometer, and clean paperwork.';
      _images = [
        'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1502877338535-766e1452684a?w=800&auto=format&fit=crop&q=80',
      ];
      _selectedFeatures = ['Touchscreen Infotainment', 'Apple CarPlay & Android Auto', 'Alloy Wheels', 'Automatic Climate Control', 'Reverse Parking Camera', 'ABS with EBD'];
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _variantController.dispose();
    _priceController.dispose();
    _kmController.dispose();
    _engineController.dispose();
    _insuranceController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _addImage() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _images.add(url);
        _imageUrlController.clear();
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final portal = context.read<DealerPortalProvider>();

      final price = double.tryParse(_priceController.text.trim()) ?? 0;
      final km = int.tryParse(_kmController.text.trim()) ?? 0;

      final car = CarModel(
        id: widget.initialCar?.id ?? '',
        dealerId: portal.dealerId,
        dealerName: portal.dealer?.businessName ?? 'Dealer',
        dealerCity: _city,
        title: '$_year $_brand ${_modelController.text.trim()} ${_variantController.text.trim()}',
        slug: '${_brand.toLowerCase()}-${_modelController.text.trim().toLowerCase()}-${DateTime.now().millisecondsSinceEpoch}',
        brand: _brand,
        model: _modelController.text.trim(),
        variant: _variantController.text.trim(),
        condition: _condition,
        price: price,
        year: _year,
        kilometers: km,
        fuelType: _fuelType,
        transmission: _transmission,
        bodyType: _bodyType,
        ownersCount: _ownersCount,
        city: _city,
        insuranceValidTill: _insuranceController.text.trim(),
        color: _colorController.text.trim(),
        engine: _engineController.text.trim(),
        description: _descriptionController.text.trim(),
        features: _selectedFeatures,
        images: _images,
        coverImage: _images.isNotEmpty ? _images.first : 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800',
        createdAt: widget.initialCar?.createdAt ?? DateTime.now(),
      );

      final success = portal.saveCar(car);

      if (!success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Car Listing Limit Reached'),
            content: Text(
              'Your current plan allows up to ${portal.carLimit} cars. Please upgrade your subscription plan to add more inventory.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.emerald,
            content: Text('Vehicle listed successfully! Now visible to prospective buyers.'),
          ),
        );
        widget.onSuccess();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialCar != null ? 'Edit Vehicle Listing' : 'Add New Vehicle to Inventory',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Provide accurate vehicle specifications and high quality photos to attract genuine buyer leads.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Card 1: Core Details
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Basic Vehicle Specifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const Divider(height: 24),
                    if (isMobile) ...[
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _brand,
                        decoration: const InputDecoration(labelText: 'Brand *'),
                        items: AppConstants.brands.where((b) => b != 'All Brands').map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (v) => setState(() => _brand = v ?? 'Maruti Suzuki'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(labelText: 'Model *', hintText: 'e.g. Swift, Creta, Thar'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _variantController,
                        decoration: const InputDecoration(labelText: 'Variant *', hintText: 'e.g. ZXi+, SX(O), AX7 L'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: _year,
                        decoration: const InputDecoration(labelText: 'Manufacturing Year *'),
                        items: List.generate(10, (i) => 2026 - i).map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                        onChanged: (v) => setState(() => _year = v ?? 2023),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price (₹ INR) *', hintText: 'e.g. 850000', prefixText: '₹ '),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter price' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _kmController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Kilometres Driven *', hintText: 'e.g. 25000', suffixText: 'km'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter km' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _fuelType,
                        decoration: const InputDecoration(labelText: 'Fuel Type *'),
                        items: AppConstants.fuelTypes.where((f) => f != 'All Fuels').map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                        onChanged: (v) => setState(() => _fuelType = v ?? 'Petrol'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _transmission,
                        decoration: const InputDecoration(labelText: 'Transmission *'),
                        items: AppConstants.transmissions.where((t) => t != 'All Transmissions').map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => _transmission = v ?? 'Manual'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _bodyType,
                        decoration: const InputDecoration(labelText: 'Body Type *'),
                        items: AppConstants.bodyTypes.where((b) => b != 'All Body Types').map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (v) => setState(() => _bodyType = v ?? 'SUV'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _ownersCount,
                        decoration: const InputDecoration(labelText: 'Ownership *'),
                        items: AppConstants.ownerCounts.where((o) => o != 'Any Ownership').map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                        onChanged: (v) => setState(() => _ownersCount = v ?? '1st Owner'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _city,
                        decoration: const InputDecoration(labelText: 'Registration City *'),
                        items: AppConstants.cities.where((c) => c != 'All Cities').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _city = v ?? 'Muktsar'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(labelText: 'Exterior Color', hintText: 'e.g. Pearl White'),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          // Brand
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _brand,
                              decoration: const InputDecoration(labelText: 'Brand *'),
                              items: AppConstants.brands.where((b) => b != 'All Brands').map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                              onChanged: (v) => setState(() => _brand = v ?? 'Maruti Suzuki'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Model
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              decoration: const InputDecoration(labelText: 'Model *', hintText: 'e.g. Swift, Creta, Thar'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Variant
                          Expanded(
                            child: TextFormField(
                              controller: _variantController,
                              decoration: const InputDecoration(labelText: 'Variant *', hintText: 'e.g. ZXi+, SX(O), AX7 L'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Year
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              initialValue: _year,
                              decoration: const InputDecoration(labelText: 'Manufacturing Year *'),
                              items: List.generate(10, (i) => 2026 - i).map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                              onChanged: (v) => setState(() => _year = v ?? 2023),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Price in ₹
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Price (₹ INR) *', hintText: 'e.g. 850000', prefixText: '₹ '),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter price' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Kilometres
                          Expanded(
                            child: TextFormField(
                              controller: _kmController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Kilometres Driven *', hintText: 'e.g. 25000', suffixText: 'km'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter km' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Fuel
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _fuelType,
                              decoration: const InputDecoration(labelText: 'Fuel Type *'),
                              items: AppConstants.fuelTypes.where((f) => f != 'All Fuels').map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                              onChanged: (v) => setState(() => _fuelType = v ?? 'Petrol'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Transmission
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _transmission,
                              decoration: const InputDecoration(labelText: 'Transmission *'),
                              items: AppConstants.transmissions.where((t) => t != 'All Transmissions').map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) => setState(() => _transmission = v ?? 'Manual'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Body Type
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _bodyType,
                              decoration: const InputDecoration(labelText: 'Body Type *'),
                              items: AppConstants.bodyTypes.where((b) => b != 'All Body Types').map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                              onChanged: (v) => setState(() => _bodyType = v ?? 'SUV'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Ownership
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _ownersCount,
                              decoration: const InputDecoration(labelText: 'Ownership *'),
                              items: AppConstants.ownerCounts.where((o) => o != 'Any Ownership').map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                              onChanged: (v) => setState(() => _ownersCount = v ?? '1st Owner'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // City
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _city,
                              decoration: const InputDecoration(labelText: 'Registration City *'),
                              items: AppConstants.cities.where((c) => c != 'All Cities').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) => setState(() => _city = v ?? 'Muktsar'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Color
                          Expanded(
                            child: TextFormField(
                              controller: _colorController,
                              decoration: const InputDecoration(labelText: 'Exterior Color', hintText: 'e.g. Pearl White'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card 2: Photos
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vehicle Photos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const Divider(height: 24),
                    if (isMobile) ...[
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Paste Image URL (Unsplash or hosted image)',
                          hintText: 'https://images.unsplash.com/...',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addImage,
                          icon: const Icon(Icons.add_photo_alternate, size: 18),
                          label: const Text('Add Photo'),
                        ),
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Paste Image URL (Unsplash or hosted image)',
                                hintText: 'https://images.unsplash.com/...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _addImage,
                            icon: const Icon(Icons.add_photo_alternate, size: 18),
                            label: const Text('Add Photo'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    // Image Previews
                    if (_images.isNotEmpty) ...[
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(_images[index], width: 120, height: 90, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: InkWell(
                                    onTap: () => setState(() => _images.removeAt(index)),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                                if (index == 0)
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                                      child: const Text('Cover', style: TextStyle(color: Colors.white, fontSize: 9)),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card 3: Features & Description
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Features Checklist & Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const Divider(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.availableCarFeatures.map((f) {
                        final isSelected = _selectedFeatures.contains(f);
                        return FilterChip(
                          label: Text(f, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textPrimary)),
                          selected: isSelected,
                          selectedColor: AppColors.accent,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedFeatures.add(f);
                              } else {
                                _selectedFeatures.remove(f);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Detailed Vehicle Description',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                icon: const Icon(Icons.check, size: 20),
                label: Text(
                  widget.initialCar != null ? 'Save Changes' : 'Publish Car Listing',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
