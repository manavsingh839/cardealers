import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/car_model.dart';
import '../../services/enquiry_service.dart';

class EnquiryDialog extends StatefulWidget {
  final CarModel? car;
  final String dealerId;
  final String dealerName;
  final String source;

  const EnquiryDialog({
    super.key,
    this.car,
    required this.dealerId,
    required this.dealerName,
    this.source = 'Car Detail Page',
  });

  static Future<void> show(
    BuildContext context, {
    CarModel? car,
    required String dealerId,
    required String dealerName,
    String source = 'Car Detail Page',
  }) {
    return showDialog(
      context: context,
      builder: (context) => EnquiryDialog(
        car: car,
        dealerId: dealerId,
        dealerName: dealerName,
        source: source,
      ),
    );
  }

  @override
  State<EnquiryDialog> createState() => _EnquiryDialogState();
}

class _EnquiryDialogState extends State<EnquiryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  late final TextEditingController _messageController;
  final _enquiryService = EnquiryService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final carTitle = widget.car?.title;
    _messageController = TextEditingController(
      text: carTitle != null
          ? 'Hi, I am interested in this $carTitle. Please contact me with more information, best price, and inspection details.'
          : 'Hi, I would like to enquire about your available verified cars. Please contact me.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      _enquiryService.submitEnquiry(
        carId: widget.car?.id ?? '',
        carTitle: widget.car?.title ?? 'General Dealership Enquiry',
        dealerId: widget.dealerId,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        customerEmail: _emailController.text.trim(),
        message: _messageController.text.trim(),
        source: widget.source,
      );

      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.emerald,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Enquiry sent directly to ${widget.dealerName}! They will contact you shortly.'),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Enquire About This Car',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Direct lead sent to ${widget.dealerName}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  if (widget.car != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              widget.car!.coverImage,
                              width: 60,
                              height: 45,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 60,
                                height: 45,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.directions_car, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.car!.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${(widget.car!.price / 100000).toStringAsFixed(2)} Lakh • ${widget.car!.city}',
                                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Full Name *',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (Calling / WhatsApp) *',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      hintText: '+91 98765 43210',
                    ),
                    validator: (v) => (v == null || v.trim().length < 10) ? 'Enter a valid 10-digit phone number' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address (Optional)',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Your Message',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(_isSubmitting ? 'Sending Enquiry...' : 'Submit Enquiry to Dealer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
