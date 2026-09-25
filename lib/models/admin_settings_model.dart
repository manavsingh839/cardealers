class AdminSettingsModel {
  final int defaultTrialDays;
  final bool dealerApprovalRequired;
  final bool carApprovalRequired;
  final int maxImagesPerCar;
  final String bannerMessage;
  final String platformContactEmail;
  final String platformContactPhone;
  final bool isRazorpayEnabled;

  AdminSettingsModel({
    this.defaultTrialDays = 7,
    this.dealerApprovalRequired = false,
    this.carApprovalRequired = false,
    this.maxImagesPerCar = 10,
    this.bannerMessage = '🚀 Special Offer: Join today and get 7 Days Free Trial with full lead capture features!',
    this.platformContactEmail = 'support@autodealersindia.com',
    this.platformContactPhone = '+91 98765 43210',
    this.isRazorpayEnabled = false,
  });

  AdminSettingsModel copyWith({
    int? defaultTrialDays,
    bool? dealerApprovalRequired,
    bool? carApprovalRequired,
    int? maxImagesPerCar,
    String? bannerMessage,
    String? platformContactEmail,
    String? platformContactPhone,
    bool? isRazorpayEnabled,
  }) {
    return AdminSettingsModel(
      defaultTrialDays: defaultTrialDays ?? this.defaultTrialDays,
      dealerApprovalRequired: dealerApprovalRequired ?? this.dealerApprovalRequired,
      carApprovalRequired: carApprovalRequired ?? this.carApprovalRequired,
      maxImagesPerCar: maxImagesPerCar ?? this.maxImagesPerCar,
      bannerMessage: bannerMessage ?? this.bannerMessage,
      platformContactEmail: platformContactEmail ?? this.platformContactEmail,
      platformContactPhone: platformContactPhone ?? this.platformContactPhone,
      isRazorpayEnabled: isRazorpayEnabled ?? this.isRazorpayEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultTrialDays': defaultTrialDays,
      'dealerApprovalRequired': dealerApprovalRequired,
      'carApprovalRequired': carApprovalRequired,
      'maxImagesPerCar': maxImagesPerCar,
      'bannerMessage': bannerMessage,
      'platformContactEmail': platformContactEmail,
      'platformContactPhone': platformContactPhone,
      'isRazorpayEnabled': isRazorpayEnabled,
    };
  }

  factory AdminSettingsModel.fromMap(Map<String, dynamic> map) {
    return AdminSettingsModel(
      defaultTrialDays: (map['defaultTrialDays'] as num?)?.toInt() ?? 7,
      dealerApprovalRequired: map['dealerApprovalRequired'] ?? false,
      carApprovalRequired: map['carApprovalRequired'] ?? false,
      maxImagesPerCar: (map['maxImagesPerCar'] as num?)?.toInt() ?? 10,
      bannerMessage: map['bannerMessage'] ?? '🚀 Special Offer: Join today and get 7 Days Free Trial with full lead capture features!',
      platformContactEmail: map['platformContactEmail'] ?? 'support@autodealersindia.com',
      platformContactPhone: map['platformContactPhone'] ?? '+91 98765 43210',
      isRazorpayEnabled: map['isRazorpayEnabled'] ?? false,
    );
  }
}
