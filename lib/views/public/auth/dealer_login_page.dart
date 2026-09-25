import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/app_data_store.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/navbar.dart';
import '../../../widgets/common/footer.dart';

class DealerLoginPage extends StatefulWidget {
  const DealerLoginPage({super.key});

  @override
  State<DealerLoginPage> createState() => _DealerLoginPageState();
}

class _DealerLoginPageState extends State<DealerLoginPage> {
  final _emailController = TextEditingController(text: 'apex@cardealer.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final auth = context.read<AuthProvider>();
    final dataStore = AppDataStore();
    final email = _emailController.text.trim();

    // Check if matches any dealer email or demo dealer
    final dealer = dataStore.dealers.firstWhere(
      (d) => d.email.toLowerCase() == email.toLowerCase(),
      orElse: () => dataStore.dealers.first,
    );

    auth.loginAsDealer(dealer.id);
    context.go('/dealer/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final dataStore = AppDataStore();
    final demoDealers = dataStore.dealers.take(4).toList();

    return Scaffold(
      appBar: const Navbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dealer SaaS Portal',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Log in to access your CRM leads, manage cars, and view acquisition performance.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 24),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Registered Dealer Email',
                              prefixIcon: Icon(Icons.email_outlined, size: 20),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              child: const Text('Log In to Dealer Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Register CTA
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text('New car dealership? ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                TextButton(
                                  onPressed: () => context.go('/register'),
                                  child: const Text('Start 7-Day Free Trial', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 32),

                          // Quick Demo Dealer Switcher
                          const Text(
                            'Quick Demo Logins:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: demoDealers.map((d) {
                              return ActionChip(
                                label: Text(d.businessName, style: const TextStyle(fontSize: 11)),
                                onPressed: () {
                                  _emailController.text = d.email;
                                  _handleLogin();
                                },
                              );
                            }).toList(),
                          ),
                        ],
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
