import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/admin_settings_model.dart';
import '../../providers/admin_portal_provider.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  late final TextEditingController _trialDaysController;
  late final TextEditingController _maxImagesController;
  late final TextEditingController _bannerController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _dealerApproval = false;
  bool _carApproval = false;
  bool _razorpayEnabled = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AdminPortalProvider>().settings;
    _trialDaysController = TextEditingController(text: settings.defaultTrialDays.toString());
    _maxImagesController = TextEditingController(text: settings.maxImagesPerCar.toString());
    _bannerController = TextEditingController(text: settings.bannerMessage);
    _emailController = TextEditingController(text: settings.platformContactEmail);
    _phoneController = TextEditingController(text: settings.platformContactPhone);
    _dealerApproval = settings.dealerApprovalRequired;
    _carApproval = settings.carApprovalRequired;
    _razorpayEnabled = settings.isRazorpayEnabled;
  }

  @override
  void dispose() {
    _trialDaysController.dispose();
    _maxImagesController.dispose();
    _bannerController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final admin = context.read<AdminPortalProvider>();
    final trialDays = int.tryParse(_trialDaysController.text.trim()) ?? 7;
    final maxImages = int.tryParse(_maxImagesController.text.trim()) ?? 10;

    final updated = AdminSettingsModel(
      defaultTrialDays: trialDays,
      dealerApprovalRequired: _dealerApproval,
      carApprovalRequired: _carApproval,
      maxImagesPerCar: maxImages,
      bannerMessage: _bannerController.text.trim(),
      platformContactEmail: _emailController.text.trim(),
      platformContactPhone: _phoneController.text.trim(),
      isRazorpayEnabled: _razorpayEnabled,
    );

    admin.updateSettings(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.emerald,
        content: Text('Platform settings updated successfully!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

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
                      'Platform Governance & Settings',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Configure default trial duration, auto-approval rules, and payment gateways.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save Settings'),
              ),
            ],
          ),
          const SizedBox(height: 24),

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
                  const Text('Onboarding & Free Trial Rules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Divider(height: 24),

                  if (isMobile) ...[
                    TextFormField(
                      controller: _trialDaysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Default Free Trial Duration (Days) *',
                        hintText: '7',
                        suffixText: 'Days',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _maxImagesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max Images Per Car Listing',
                        hintText: '10',
                        suffixText: 'Photos',
                      ),
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _trialDaysController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Default Free Trial Duration (Days) *',
                              hintText: '7',
                              suffixText: 'Days',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxImagesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max Images Per Car Listing',
                              hintText: '10',
                              suffixText: 'Photos',
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Toggles
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Require Admin Approval for New Dealers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('When enabled, newly registered dealerships remain pending until admin reviews documentation.', style: TextStyle(fontSize: 12)),
                    value: _dealerApproval,
                    onChanged: (val) => setState(() => _dealerApproval = val),
                  ),
                  const Divider(height: 20),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Require Admin Moderation for Car Listings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('When enabled, added cars require admin approval before going live on the marketplace.', style: TextStyle(fontSize: 12)),
                    value: _carApproval,
                    onChanged: (val) => setState(() => _carApproval = val),
                  ),
                  const Divider(height: 20),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Live Razorpay Automated Billing', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('When disabled, payments run in simulated/manual admin activation mode.', style: TextStyle(fontSize: 12)),
                    value: _razorpayEnabled,
                    onChanged: (val) => setState(() => _razorpayEnabled = val),
                  ),
                  const Divider(height: 28),

                  const Text('Platform Branding & Contact Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _bannerController,
                    decoration: const InputDecoration(
                      labelText: 'Announcement Banner Message (Top of Website)',
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (isMobile) ...[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Platform Support Email'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Platform Support Helpline'),
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Platform Support Email'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(labelText: 'Platform Support Helpline'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
