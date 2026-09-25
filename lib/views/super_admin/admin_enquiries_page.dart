import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/admin_portal_provider.dart';
import '../../widgets/common/status_badge.dart';

class AdminEnquiriesPage extends StatefulWidget {
  const AdminEnquiriesPage({super.key});

  @override
  State<AdminEnquiriesPage> createState() => _AdminEnquiriesPageState();
}

class _AdminEnquiriesPageState extends State<AdminEnquiriesPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminPortalProvider>();
    final enquiries = admin.enquiries;

    var filtered = enquiries;
    if (_filter != 'All') {
      filtered = enquiries.where((e) => e.status.toLowerCase() == _filter.toLowerCase()).toList();
    }

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
                      'Global Customer Enquiries & Leads',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Platform-wide lead audit logging. Tracks buyer engagement across all dealerships.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'New', 'Contacted', 'Interested', 'Converted', 'Closed'].map((f) {
                  final isSelected = _filter == f;
                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(f, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 12)),
                    selected: isSelected,
                    selectedColor: AppColors.accent,
                    onSelected: (_) => setState(() => _filter = f),
                  );
                }).toList(),
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
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final enq = filtered[index];
                final dealer = admin.dealers.firstWhere((d) => d.id == enq.dealerId, orElse: () => admin.dealers.first);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accentLight,
                    child: Text(
                      enq.customerName.isNotEmpty ? enq.customerName[0].toUpperCase() : 'C',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                    ),
                  ),
                  title: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(enq.customerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      StatusBadge(status: enq.status),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(4)),
                        child: Text('Via ${enq.source}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Car: ${enq.carTitle} • Dealership: ${dealer.businessName} (${dealer.city}) • '
                      'Phone: ${enq.customerPhone} • Date: ${Formatters.formatDateTime(enq.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
