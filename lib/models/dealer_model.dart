class DealerModel {
  final String id;
  final String userId;
  final String businessName;
  final String slug;
  final String logoUrl;
  final String phone;
  final String whatsapp;
  final String email;
  final String address;
  final String city;
  final String state;
  final String description;
  final String gstNumber;
  final String workingHours;
  final bool isDemo;

  // Verification Pipeline: pending -> submitted -> approved -> verified
  final String verificationStatus; // 'pending' | 'submitted' | 'approved' | 'verified'
  final DateTime? verifiedAt;
  final String? verifiedBy;

  // General Status: pending | submitted | approved | suspended
  final String status;

  // Subscription & 7-Day Free Trial
  final String subscriptionPlanId; // 'starter' | 'business' | 'pro'
  final String subscriptionStatus; // 'trial' | 'active' | 'expiring' | 'expired' | 'suspended'
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionStartDate;
  final DateTime? renewalDate;
  final DateTime? expiryDate;

  // Analytics counters
  final int viewsCount;
  final DateTime createdAt;

  DealerModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.slug,
    required this.logoUrl,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.address,
    required this.city,
    this.state = 'India',
    required this.description,
    this.gstNumber = '',
    this.workingHours = 'Mon - Sat: 9:30 AM - 7:30 PM',
    this.isDemo = false,
    this.verificationStatus = 'pending',
    this.verifiedAt,
    this.verifiedBy,
    this.status = 'approved',
    this.subscriptionPlanId = 'starter',
    this.subscriptionStatus = 'trial',
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionStartDate,
    this.renewalDate,
    this.expiryDate,
    this.viewsCount = 0,
    required this.createdAt,
  });

  // Public Verified Badge should ONLY display when verificationStatus == 'verified'
  bool get isVerified => verificationStatus.toLowerCase() == 'verified';

  // Check if dealer is in free trial
  bool get isInTrial {
    if (subscriptionStatus == 'trial') return true;
    if (trialEndDate != null && DateTime.now().isBefore(trialEndDate!)) return true;
    return false;
  }

  // Calculate remaining trial days
  int get remainingTrialDays {
    if (trialEndDate == null) return 0;
    final diff = trialEndDate!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff + 1; // inclusive of today
  }

  // Is subscription currently active (either active plan or active trial)
  bool get isSubscriptionActive {
    if (subscriptionStatus == 'active') return true;
    if (isInTrial && remainingTrialDays > 0) return true;
    return false;
  }

  // Is subscription expired
  bool get isExpired {
    if (subscriptionStatus == 'expired') return true;
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) return true;
    if (subscriptionStatus == 'trial' && remainingTrialDays <= 0) return true;
    return false;
  }

  DealerModel copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? slug,
    String? logoUrl,
    String? phone,
    String? whatsapp,
    String? email,
    String? address,
    String? city,
    String? state,
    String? description,
    String? gstNumber,
    String? workingHours,
    bool? isDemo,
    String? verificationStatus,
    DateTime? verifiedAt,
    String? verifiedBy,
    String? status,
    String? subscriptionPlanId,
    String? subscriptionStatus,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    DateTime? subscriptionStartDate,
    DateTime? renewalDate,
    DateTime? expiryDate,
    int? viewsCount,
    DateTime? createdAt,
  }) {
    return DealerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      slug: slug ?? this.slug,
      logoUrl: logoUrl ?? this.logoUrl,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      description: description ?? this.description,
      gstNumber: gstNumber ?? this.gstNumber,
      workingHours: workingHours ?? this.workingHours,
      isDemo: isDemo ?? this.isDemo,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      status: status ?? this.status,
      subscriptionPlanId: subscriptionPlanId ?? this.subscriptionPlanId,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      renewalDate: renewalDate ?? this.renewalDate,
      expiryDate: expiryDate ?? this.expiryDate,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'businessName': businessName,
      'slug': slug,
      'logoUrl': logoUrl,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'description': description,
      'gstNumber': gstNumber,
      'workingHours': workingHours,
      'isDemo': isDemo,
      'verificationStatus': verificationStatus,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
      'status': status,
      'subscriptionPlanId': subscriptionPlanId,
      'subscriptionStatus': subscriptionStatus,
      'trialStartDate': trialStartDate?.toIso8601String(),
      'trialEndDate': trialEndDate?.toIso8601String(),
      'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
      'renewalDate': renewalDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'viewsCount': viewsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DealerModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return DealerModel(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      businessName: map['businessName'] ?? '',
      slug: map['slug'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      phone: map['phone'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? 'India',
      description: map['description'] ?? '',
      gstNumber: map['gstNumber'] ?? '',
      workingHours: map['workingHours'] ?? 'Mon - Sat: 9:30 AM - 7:30 PM',
      isDemo: map['isDemo'] ?? false,
      verificationStatus: map['verificationStatus'] ?? 'pending',
      verifiedAt: map['verifiedAt'] != null ? DateTime.tryParse(map['verifiedAt']) : null,
      verifiedBy: map['verifiedBy'],
      status: map['status'] ?? 'approved',
      subscriptionPlanId: map['subscriptionPlanId'] ?? 'starter',
      subscriptionStatus: map['subscriptionStatus'] ?? 'trial',
      trialStartDate: map['trialStartDate'] != null ? DateTime.tryParse(map['trialStartDate']) : null,
      trialEndDate: map['trialEndDate'] != null ? DateTime.tryParse(map['trialEndDate']) : null,
      subscriptionStartDate: map['subscriptionStartDate'] != null ? DateTime.tryParse(map['subscriptionStartDate']) : null,
      renewalDate: map['renewalDate'] != null ? DateTime.tryParse(map['renewalDate']) : null,
      expiryDate: map['expiryDate'] != null ? DateTime.tryParse(map['expiryDate']) : null,
      viewsCount: map['viewsCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
