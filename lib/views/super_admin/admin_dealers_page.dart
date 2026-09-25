import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../providers/admin_portal_provider.dart';
import '../../widgets/common/status_badge.dart';

class AdminDealersPage extends StatefulWidget {
  const AdminDealersPage({super.key});

  @override
  State<AdminDealersPage> createState() => _AdminDealersPageState();
}

class _AdminDealersPageState extends State<AdminDealersPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminPortalProvider>();
    final allDealers = admin.dealers;

    var filtered = allDealers;
    if (_filter == 'Pending') {
      filtered = allDealers.where((d) => d.verificationStatus == 'pending' || d.verificationStatus == 'submitted').toList();
    } else if (_filter == 'Verified') {
      filtered = allDealers.where((d) => d.isVerified).toList();
    } else if (_filter == 'Suspended') {
      filtered = allDealers.where((d) => d.status == 'suspended').toList();
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
                      'Dealer Moderation & Verification Pipeline',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pipeline: Pending -> Submitted -> Approved -> Verified. Only Verified dealers receive the public badge.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Pending', 'Verified', 'Suspended'].map((f) {
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
          const SizedBox(height: 20),

          // Dealers Table
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
                final dealer = filtered[index];
                final isVerified = dealer.isVerified;
                final isSuspended = dealer.status == 'suspended';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(dealer.logoUrl),
                  ),
                  title: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(dealer.businessName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      StatusBadge(status: dealer.verificationStatus, isVerified: isVerified),
                      if (dealer.isDemo)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                          child: const Text('Demo Dealer', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${dealer.city} • Phone: ${dealer.phone} • Plan: ${dealer.subscriptionPlanId.toUpperCase()} (${dealer.subscriptionStatus}) • Joined: ${Formatters.formatDate(dealer.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  trailing: Responsive.isMobile(context)
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (value) {
                            if (value == 'view') context.push('/dealer/${dealer.id}');
                            if (value == 'approve') admin.approveDealer(dealer.id);
                            if (value == 'verify') admin.verifyDealer(dealer.id);
                            if (value == 'reactivate') admin.reactivateDealer(dealer.id);
                            if (value == 'suspend') admin.suspendDealer(dealer.id);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.open_in_new, size: 16),
                                  SizedBox(width: 8),
                                  Text('View Profile'),
                                ],
                              ),
                            ),
                            if (dealer.verificationStatus == 'pending' || dealer.verificationStatus == 'submitted')
                              const PopupMenuItem(
                                value: 'approve',
                                child: Row(
                                  children: [
                                    Icon(Icons.check, size: 16, color: AppColors.accent),
                                    SizedBox(width: 8),
                                    Text('Approve Dealer'),
                                  ],
                                ),
                              ),
                            if (!isVerified)
                              const PopupMenuItem(
                                value: 'verify',
                                child: Row(
                                  children: [
                                    Icon(Icons.verified, size: 16, color: AppColors.emerald),
                                    SizedBox(width: 8),
                                    Text('Grant Verified Badge'),
                                  ],
                                ),
                              ),
                            if (isSuspended)
                              const PopupMenuItem(
                                value: 'reactivate',
                                child: Row(
                                  children: [
                                    Icon(Icons.restore, size: 16, color: AppColors.emerald),
                                    SizedBox(width: 8),
                                    Text('Reactivate Dealer'),
                                  ],
                                ),
                              )
                            else
                              const PopupMenuItem(
                                value: 'suspend',
                                child: Row(
                                  children: [
                                    Icon(Icons.block, size: 16, color: AppColors.red),
                                    SizedBox(width: 8),
                                    Text('Suspend Dealer'),
                                  ],
                                ),
                              ),
                          ],
                        )
                      : Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // View public profile
                            IconButton(
                              icon: const Icon(Icons.open_in_new, size: 18),
                              tooltip: 'View Profile',
                              onPressed: () => context.push('/dealer/${dealer.id}'),
                            ),
                            // Action: Approve
                            if (dealer.verificationStatus == 'pending' || dealer.verificationStatus == 'submitted') ...[
                              ElevatedButton(
                                onPressed: () => admin.approveDealer(dealer.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: const Text('Approve', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                            // Action: Grant Verified Badge
                            if (!isVerified) ...[
                              ElevatedButton.icon(
                                onPressed: () => admin.verifyDealer(dealer.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.emerald,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.verified, size: 14),
                                label: const Text('Verify', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                            // Action: Suspend / Reactivate
                            if (isSuspended) ...[
                              OutlinedButton(
                                onPressed: () => admin.reactivateDealer(dealer.id),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                child: const Text('Reactivate', style: TextStyle(color: AppColors.emerald, fontSize: 11)),
                              ),
                            ] else ...[
                              OutlinedButton(
                                onPressed: () => admin.suspendDealer(dealer.id),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                child: const Text('Suspend', style: TextStyle(color: AppColors.red, fontSize: 11)),
                              ),
                            ],
                          ],
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
