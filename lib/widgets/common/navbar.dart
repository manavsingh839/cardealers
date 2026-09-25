import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDesktop = Responsive.isDesktop(context);

    final isMobile = Responsive.isMobile(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
      child: SafeArea(
        child: Row(
          children: [
            // Brand Logo
            Flexible(
              child: InkWell(
                onTap: () => context.go('/'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AutoDealers',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'LEAD GENERATION SAAS',
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                              letterSpacing: 0.8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),
            const Spacer(),

            // Desktop Navigation Links
            if (isDesktop)
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navLink(context, 'Browse Cars', '/cars'),
                      _navLink(context, 'Verified Dealers', '/dealers'),
                      _navLink(context, 'Pricing', '/pricing'),
                      const SizedBox(width: 12),

                      // 1. If Authenticated as Super Admin
                      if (auth.isAuthenticated && auth.isAdmin) ...[
                        ElevatedButton.icon(
                          onPressed: () => context.go('/admin'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          icon: const Icon(Icons.shield_rounded, size: 16),
                          label: const Text('Admin Portal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            auth.logout();
                            context.go('/');
                          },
                          icon: const Icon(Icons.logout, size: 18, color: AppColors.textSecondary),
                          tooltip: 'Logout Admin',
                        ),
                      ]
                      // 2. If Authenticated as Dealer
                      else if (auth.isAuthenticated && auth.isDealer) ...[
                        OutlinedButton.icon(
                          onPressed: () => context.go('/dealer/dashboard'),
                          icon: const Icon(Icons.dashboard_outlined, size: 16),
                          label: Text(auth.currentDealer?.businessName ?? 'Dealer Dashboard'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            auth.logout();
                            context.go('/');
                          },
                          icon: const Icon(Icons.logout, size: 18, color: AppColors.textSecondary),
                          tooltip: 'Logout Dealer',
                        ),
                      ]
                      // 3. Public Visitor (Unauthenticated)
                      else ...[
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Dealer Login', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 10),
                        // Primary Value Proposition CTA: "List Your Cars & Get More Enquiries"
                        ElevatedButton.icon(
                          onPressed: () => context.go('/register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.bolt_rounded, size: 18),
                          label: const Text('List Cars & Get Enquiries'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else ...[
              // Mobile / Tablet Action Icons
              IconButton(
                onPressed: () => context.push('/cars'),
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Search Cars',
              ),
              IconButton(
                onPressed: () => _openMobileMenu(context, auth),
                icon: const Icon(Icons.menu_rounded),
                tooltip: 'Menu',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _navLink(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () => context.go(route),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _openMobileMenu(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Navigation Menu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(height: 16),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.directions_car_outlined, color: AppColors.accent),
                  title: const Text('Browse Cars', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/cars');
                  },
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.storefront_outlined, color: AppColors.accent),
                  title: const Text('Verified Dealers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dealers');
                  },
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.payments_outlined, color: AppColors.accent),
                  title: const Text('Pricing & Plans', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/pricing');
                  },
                ),
                if (auth.isAuthenticated && auth.isAdmin) ...[
                  const Divider(height: 16),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.shield_rounded, color: AppColors.primary),
                    title: const Text('Super Admin Portal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/admin');
                    },
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.logout, color: AppColors.red),
                    title: const Text('Logout Admin', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.red, fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      auth.logout();
                      context.go('/');
                    },
                  ),
                ] else if (auth.isAuthenticated && auth.isDealer) ...[
                  const Divider(height: 16),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.dashboard_outlined, color: AppColors.accent),
                    title: Text(auth.currentDealer?.businessName ?? 'Dealer Dashboard', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/dealer/dashboard');
                    },
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.logout, color: AppColors.red),
                    title: const Text('Logout Dealer', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.red, fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      auth.logout();
                      context.go('/');
                    },
                  ),
                ] else ...[
                  const Divider(height: 16),
                  const SizedBox(height: 4),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 20),
                    label: const Text('List Cars & Get Enquiries (Free Trial)', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/login');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Dealer Login', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
