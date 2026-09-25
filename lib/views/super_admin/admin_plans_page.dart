import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/subscription_plan_model.dart';
import '../../providers/admin_portal_provider.dart';

class AdminPlansPage extends StatelessWidget {
  const AdminPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminPortalProvider>();
    final plans = admin.plans;

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
                      'Configurable Subscription Plans',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Modify pricing, vehicle inventory limits, and features dynamically without touching code.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openPlanEditor(context, admin, null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create New Plan'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Plans Grid
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: plans.map((plan) {
              return Container(
                width: Responsive.isMobile(context) ? double.infinity : 340,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: plan.isRecommended ? AppColors.accent : AppColors.border, width: plan.isRecommended ? 2 : 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(plan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        ),
                        if (plan.isRecommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(4)),
                            child: const Text('RECOMMENDED', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${Formatters.formatCurrency(plan.priceMonthly)} / month',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Text('Inventory Allowance: ${plan.carLimit} Cars', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent)),
                    const Divider(height: 28),
                    const Text('Features List:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    ...plan.features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check, size: 14, color: AppColors.emerald),
                            const SizedBox(width: 8),
                            Expanded(child: Text(f, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openPlanEditor(context, admin, plan),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit Plan Settings'),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _openPlanEditor(BuildContext context, AdminPortalProvider admin, SubscriptionPlanModel? existing) {
    final nameController = TextEditingController(text: existing?.name ?? 'Custom Plan');
    final priceController = TextEditingController(text: existing?.priceMonthly.toStringAsFixed(0) ?? '1499');
    final limitController = TextEditingController(text: existing?.carLimit.toString() ?? '50');
    final featuresController = TextEditingController(text: existing?.features.join('\n') ?? 'List up to 50 cars\nVerified profile\nWhatsApp leads');
    bool isRec = existing?.isRecommended ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(existing != null ? 'Edit ${existing.name} Plan' : 'Create Pricing Plan'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Plan Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price Monthly (₹ INR)', prefixText: '₹ '),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: limitController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Car Listing Limit'),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Highlight as Recommended Plan'),
                      value: isRec,
                      onChanged: (val) => setDialogState(() => isRec = val ?? false),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: featuresController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Plan Features (One per line)',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(priceController.text.trim()) ?? 999;
                  final limit = int.tryParse(limitController.text.trim()) ?? 30;
                  final features = featuresController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();

                  final plan = SubscriptionPlanModel(
                    id: existing?.id ?? 'plan_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim(),
                    priceMonthly: price,
                    carLimit: limit,
                    isRecommended: isRec,
                    features: features,
                  );

                  admin.updatePlan(plan);
                  Navigator.pop(context);
                },
                child: const Text('Save Plan'),
              ),
            ],
          );
        },
      ),
    );
  }
}
