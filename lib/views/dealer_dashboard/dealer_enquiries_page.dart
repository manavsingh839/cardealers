import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/enquiry_model.dart';
import '../../providers/dealer_portal_provider.dart';
import '../../widgets/common/status_badge.dart';

class DealerEnquiriesPage extends StatefulWidget {
  const DealerEnquiriesPage({super.key});

  @override
  State<DealerEnquiriesPage> createState() => _DealerEnquiriesPageState();
}

class _DealerEnquiriesPageState extends State<DealerEnquiriesPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<DealerPortalProvider>();
    final allEnquiries = portal.dealerEnquiries;

    List<EnquiryModel> filteredList;
    if (_selectedFilter == 'All') {
      filteredList = allEnquiries;
    } else {
      filteredList = allEnquiries.where((e) => e.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
    }

    final filters = ['All', 'New', 'Contacted', 'Interested', 'Converted', 'Closed'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 14 : 24),
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
                      'Customer Enquiries & Lead CRM',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage incoming vehicle enquiries, track stages from New to Converted deals.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${allEnquiries.length} Total Leads',
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // CRM Status Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((f) {
                final isSelected = _selectedFilter == f;
                int count;
                if (f == 'All') {
                  count = allEnquiries.length;
                } else {
                  count = allEnquiries.where((e) => e.status.toLowerCase() == f.toLowerCase()).length;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(
                      '$f ($count)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.accent,
                    onSelected: (_) => setState(() => _selectedFilter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Enquiries List
          if (filteredList.isEmpty) ...[
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
                  const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No enquiries in "$_selectedFilter" category', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('Customer leads submitted through the public website will appear here.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final enq = filteredList[index];
                return Card(
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
                        if (Responsive.isMobile(context)) ...[
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.accentLight,
                                child: Text(
                                  enq.customerName.isNotEmpty ? enq.customerName[0].toUpperCase() : 'C',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  enq.customerName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              StatusBadge(status: enq.status),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Via ${enq.source}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Car: ${enq.carTitle}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.accent),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Received: ${Formatters.formatDateTime(enq.createdAt)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: enq.status,
                                items: ['New', 'Contacted', 'Interested', 'Converted', 'Closed'].map((s) {
                                  return DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)));
                                }).toList(),
                                onChanged: (newStatus) {
                                  if (newStatus != null) {
                                    portal.updateEnquiryStatus(enq.id, newStatus);
                                  }
                                },
                              ),
                            ),
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.accentLight,
                                child: Text(
                                  enq.customerName.isNotEmpty ? enq.customerName[0].toUpperCase() : 'C',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          enq.customerName,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                        ),
                                        StatusBadge(status: enq.status),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceMuted,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Via ${enq.source}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Car: ${enq.carTitle}',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.accent),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Received: ${Formatters.formatDateTime(enq.createdAt)}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              // Status updater dropdown
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: enq.status,
                                    items: ['New', 'Contacted', 'Interested', 'Converted', 'Closed'].map((s) {
                                      return DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)));
                                    }).toList(),
                                    onChanged: (newStatus) {
                                      if (newStatus != null) {
                                        portal.updateEnquiryStatus(enq.id, newStatus);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 24),
                        // Message box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '"${enq.message}"',
                            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Contact Actions Bar
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Phone: ${enq.customerPhone} ${enq.customerEmail.isNotEmpty ? "• Email: ${enq.customerEmail}" : ""}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            Responsive.isMobile(context)
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => portal.callCustomer(enq.customerPhone),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            icon: const Icon(Icons.phone, size: 16),
                                            label: const Text('Call', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => portal.whatsappCustomer(enq.customerPhone, enq.customerName, enq.carTitle),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.whatsappDark,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            icon: const Icon(Icons.chat, size: 16),
                                            label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => portal.callCustomer(enq.customerPhone),
                                        icon: const Icon(Icons.phone, size: 16),
                                        label: const Text('Call Customer'),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => portal.whatsappCustomer(enq.customerPhone, enq.customerName, enq.carTitle),
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.whatsappDark),
                                        icon: const Icon(Icons.chat, size: 16),
                                        label: const Text('WhatsApp Customer'),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
