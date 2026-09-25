import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/navbar.dart';
import '../../../widgets/common/footer.dart';

class DealerRegisterPage extends StatefulWidget {
  const DealerRegisterPage({super.key});

  @override
  State<DealerRegisterPage> createState() => _DealerRegisterPageState();
}

class _DealerRegisterPageState extends State<DealerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedCity = 'Muktsar';
  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final auth = context.read<AuthProvider>();

      auth.registerDealer(
        businessName: _businessNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim().isNotEmpty
            ? _whatsappController.text.trim()
            : _phoneController.text.trim(),
        city: _selectedCity,
        address: _addressController.text.trim(),
      );

      setState(() => _isLoading = false);
      context.go('/dealer/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '7-DAY FREE TRIAL INCLUDED',
                                style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700, fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Register Your Dealership',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'List your cars, capture direct customer enquiries, and monitor lead conversions.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 24),

                            // Business Name
                            TextFormField(
                              controller: _businessNameController,
                              decoration: const InputDecoration(
                                labelText: 'Showroom / Dealership Business Name *',
                                prefixIcon: Icon(Icons.storefront_outlined, size: 20),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter business name' : null,
                            ),
                            const SizedBox(height: 16),

                            // Owner Name
                            TextFormField(
                              controller: _ownerNameController,
                              decoration: const InputDecoration(
                                labelText: 'Dealer / Owner Full Name *',
                                prefixIcon: Icon(Icons.person_outline, size: 20),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter owner name' : null,
                            ),
                            const SizedBox(height: 16),

                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Business Email Address *',
                                prefixIcon: Icon(Icons.email_outlined, size: 20),
                              ),
                              validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
                            ),
                            const SizedBox(height: 16),

                            // Phone & WhatsApp
                            if (Responsive.isMobile(context)) ...[
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Calling Phone *',
                                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                                ),
                                validator: (v) => (v == null || v.length < 10) ? 'Enter phone' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _whatsappController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'WhatsApp Number',
                                  prefixIcon: Icon(Icons.chat_outlined, size: 20),
                                ),
                              ),
                            ] else
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        labelText: 'Calling Phone *',
                                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                                      ),
                                      validator: (v) => (v == null || v.length < 10) ? 'Enter phone' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _whatsappController,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        labelText: 'WhatsApp Number',
                                        prefixIcon: Icon(Icons.chat_outlined, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),

                            // City
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCity,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Showroom City *',
                                prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                              ),
                              items: AppConstants.cities
                                  .where((c) => c != 'All Cities')
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedCity = v ?? 'Muktsar'),
                            ),
                            const SizedBox(height: 16),

                            // Address
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Showroom Street Address *',
                                prefixIcon: Icon(Icons.home_outlined, size: 20),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter address' : null,
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
                                child: Text(
                                  _isLoading ? 'Setting up trial...' : 'Start 7-Day Free Trial Now',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text('Already have a dealer account? ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  TextButton(
                                    onPressed: () => context.go('/login'),
                                    child: const Text('Log In here', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
