import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isVerified;
  final bool isDemo;

  const StatusBadge({
    super.key,
    required this.status,
    this.isVerified = false,
    this.isDemo = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.surfaceMuted;
    Color fg = AppColors.textSecondary;
    IconData? icon;

    final lower = status.toLowerCase();

    if (isVerified || lower == 'verified') {
      bg = AppColors.emeraldLight;
      fg = AppColors.emerald;
      icon = Icons.verified_rounded;
    } else if (lower == 'approved' || lower == 'active' || lower == 'converted') {
      bg = AppColors.emeraldLight;
      fg = AppColors.emerald;
      icon = Icons.check_circle_outline_rounded;
    } else if (lower == 'new' || lower == 'trial') {
      bg = AppColors.accentLight;
      fg = AppColors.accent;
      icon = Icons.fiber_new_rounded;
    } else if (lower == 'contacted' || lower == 'interested' || lower == 'submitted') {
      bg = AppColors.amberLight;
      fg = AppColors.amber;
      icon = Icons.access_time_rounded;
    } else if (lower == 'pending' || lower == 'expiring') {
      bg = AppColors.orangeLight;
      fg = AppColors.orange;
      icon = Icons.hourglass_top_rounded;
    } else if (lower == 'expired' || lower == 'suspended' || lower == 'rejected' || lower == 'closed') {
      bg = AppColors.redLight;
      fg = AppColors.red;
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, size: 14, color: fg),
          Text(
            isVerified ? 'Verified Dealer' : status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
