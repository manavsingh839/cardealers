class SubscriptionPlanModel {
  final String id;
  final String name;
  final double priceMonthly;
  final int carLimit;
  final bool isRecommended;
  final bool hasFeaturedListing;
  final bool hasPriorityPlacement;
  final bool hasAdvancedAnalytics;
  final List<String> features;
  final bool isActive;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.priceMonthly,
    required this.carLimit,
    this.isRecommended = false,
    this.hasFeaturedListing = false,
    this.hasPriorityPlacement = false,
    this.hasAdvancedAnalytics = false,
    required this.features,
    this.isActive = true,
  });

  SubscriptionPlanModel copyWith({
    String? id,
    String? name,
    double? priceMonthly,
    int? carLimit,
    bool? isRecommended,
    bool? hasFeaturedListing,
    bool? hasPriorityPlacement,
    bool? hasAdvancedAnalytics,
    List<String>? features,
    bool? isActive,
  }) {
    return SubscriptionPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      priceMonthly: priceMonthly ?? this.priceMonthly,
      carLimit: carLimit ?? this.carLimit,
      isRecommended: isRecommended ?? this.isRecommended,
      hasFeaturedListing: hasFeaturedListing ?? this.hasFeaturedListing,
      hasPriorityPlacement: hasPriorityPlacement ?? this.hasPriorityPlacement,
      hasAdvancedAnalytics: hasAdvancedAnalytics ?? this.hasAdvancedAnalytics,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'priceMonthly': priceMonthly,
      'carLimit': carLimit,
      'isRecommended': isRecommended,
      'hasFeaturedListing': hasFeaturedListing,
      'hasPriorityPlacement': hasPriorityPlacement,
      'hasAdvancedAnalytics': hasAdvancedAnalytics,
      'features': features,
      'isActive': isActive,
    };
  }

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return SubscriptionPlanModel(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      priceMonthly: (map['priceMonthly'] as num?)?.toDouble() ?? 0.0,
      carLimit: (map['carLimit'] as num?)?.toInt() ?? 10,
      isRecommended: map['isRecommended'] ?? false,
      hasFeaturedListing: map['hasFeaturedListing'] ?? false,
      hasPriorityPlacement: map['hasPriorityPlacement'] ?? false,
      hasAdvancedAnalytics: map['hasAdvancedAnalytics'] ?? false,
      features: List<String>.from(map['features'] ?? []),
      isActive: map['isActive'] ?? true,
    );
  }
}
