import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../providers/dealer_portal_provider.dart';

class DealerProfilePage extends StatefulWidget {
  const DealerProfilePage({super.key});

  @override
  State<DealerProfilePage> createState() => _DealerProfilePageState();
}

class _DealerProfilePageState extends State<DealerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _workingHoursController;
  late final TextEditingController _gstController;
  late final TextEditingController _logoUrlController;
  String _selectedCity = 'Muktsar';

  @override
  void initState() {
    super.initState();
    final dealer = context.read<DealerPortalProvider>().dealer;
    _businessNameController = TextEditingController(text: dealer?.businessName ?? '');
    _phoneController = TextEditingController(text: dealer?.phone ?? '');
    _whatsappController = TextEditingController(text: dealer?.whatsapp ?? '');
    _addressController = TextEditingController(text: dealer?.address ?? '');
    _descriptionController = TextEditingController(text: dealer?.description ?? '');
    _workingHoursController = TextEditingController(text: dealer?.workingHours ?? 'Mon - Sat: 9:30 AM - 7:30 PM');
    _gstController = TextEditingController(text: dealer?.gstNumber ?? '');
    _logoUrlController = TextEditingController(text: dealer?.logoUrl ?? '');
    _selectedCity = dealer?.city ?? 'Muktsar';
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _workingHoursController.dispose();
    _gstController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final portal = context.read<DealerPortalProvider>();
      final current = portal.dealer;
      if (current != null) {
        final updated = current.copyWith(
          businessName: _businessNameController.text.trim(),
          phone: _phoneController.text.trim(),
          whatsapp: _whatsappController.text.trim(),
          address: _addressController.text.trim(),
          city: _selectedCity,
          description: _descriptionController.text.trim(),
          workingHours: _workingHoursController.text.trim(),
          gstNumber: _gstController.text.trim(),
          logoUrl: _logoUrlController.text.trim(),
        );

        portal.updateProfile(updated);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.emerald,
            content: Text('Dealership profile updated successfully!'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<DealerPortalProvider>();
    final dealer = portal.dealer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
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
                        'Dealership Profile & Branding',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Information displayed on your public dealer page and automotive listings.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Profile'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Profile Card
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
                    // Avatar & Verification Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(_logoUrlController.text.trim().isNotEmpty
                              ? _logoUrlController.text.trim()
                              : 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=200'),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(dealer?.businessName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                                  if (dealer?.isVerified == true) ...[
                                    const Icon(Icons.verified, size: 18, color: AppColors.emerald),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Verification Status: ${dealer?.verificationStatus.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: dealer?.isVerified == true ? AppColors.emerald : AppColors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(labelText: 'Dealership / Showroom Business Name *'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    if (Responsive.isMobile(context)) ...[
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Calling Phone Number *', prefixIcon: Icon(Icons.phone_outlined, size: 20)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _whatsappController,
                        decoration: const InputDecoration(labelText: 'WhatsApp Lead Number *', prefixIcon: Icon(Icons.chat_outlined, size: 20)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCity,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'City *', prefixIcon: Icon(Icons.location_city_outlined, size: 20)),
                        items: AppConstants.cities.where((c) => c != 'All Cities').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _selectedCity = v ?? 'Muktsar'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _gstController,
                        decoration: const InputDecoration(labelText: 'GST Number (Optional)', prefixIcon: Icon(Icons.receipt_long_outlined, size: 20)),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(labelText: 'Calling Phone Number *', prefixIcon: Icon(Icons.phone_outlined, size: 20)),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _whatsappController,
                              decoration: const InputDecoration(labelText: 'WhatsApp Lead Number *', prefixIcon: Icon(Icons.chat_outlined, size: 20)),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedCity,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'City *', prefixIcon: Icon(Icons.location_city_outlined, size: 20)),
                              items: AppConstants.cities.where((c) => c != 'All Cities').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) => setState(() => _selectedCity = v ?? 'Muktsar'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _gstController,
                              decoration: const InputDecoration(labelText: 'GST Number (Optional)', prefixIcon: Icon(Icons.receipt_long_outlined, size: 20)),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Full Showroom Address *', prefixIcon: Icon(Icons.home_outlined, size: 20)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _workingHoursController,
                      decoration: const InputDecoration(labelText: 'Working Hours', prefixIcon: Icon(Icons.schedule_outlined, size: 20)),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _logoUrlController,
                      decoration: const InputDecoration(labelText: 'Logo / Showroom Image URL', prefixIcon: Icon(Icons.image_outlined, size: 20)),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Showroom Description & Specialties',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
