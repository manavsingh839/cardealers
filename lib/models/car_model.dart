class CarModel {
  final String id;
  final String dealerId;
  final String dealerName;
  final String dealerCity;
  final String title;
  final String slug;
  final String brand;
  final String model;
  final String variant;
  final String condition; // 'Used' | 'New'
  final double price; // in INR (e.g. 850000)
  final int year;
  final int kilometers;
  final String fuelType; // 'Petrol' | 'Diesel' | 'CNG' | 'Electric' | 'Hybrid'
  final String transmission; // 'Manual' | 'Automatic'
  final String bodyType; // 'SUV' | 'Sedan' | 'Hatchback' | 'MUV'
  final String ownersCount; // '1st Owner' | '2nd Owner' | etc.
  final String city;
  final String insuranceValidTill;
  final String color;
  final String engine;
  final String description;
  final List<String> features;
  final List<String> images;
  final String coverImage;

  // Featured listing fields (for monetization & visibility boost)
  final bool isFeatured;
  final DateTime? featuredStartDate;
  final DateTime? featuredEndDate;
  final String? featuredSource; // 'admin_granted' | 'subscription_included' | 'paid_add_on'
  final String? featuredPaymentId;

  // Moderation & Status
  final bool isApproved;
  final String status; // 'available' | 'sold' | 'inactive'

  // Lead Generation Counters
  final int viewsCount;
  final int phoneClicks;
  final int whatsappClicks;
  final DateTime createdAt;

  CarModel({
    required this.id,
    required this.dealerId,
    required this.dealerName,
    required this.dealerCity,
    required this.title,
    required this.slug,
    required this.brand,
    required this.model,
    required this.variant,
    this.condition = 'Used',
    required this.price,
    required this.year,
    required this.kilometers,
    required this.fuelType,
    required this.transmission,
    required this.bodyType,
    this.ownersCount = '1st Owner',
    required this.city,
    this.insuranceValidTill = 'Comprehensive (1 Year)',
    this.color = 'White',
    this.engine = '1197 cc',
    required this.description,
    this.features = const [],
    this.images = const [],
    required this.coverImage,
    this.isFeatured = false,
    this.featuredStartDate,
    this.featuredEndDate,
    this.featuredSource,
    this.featuredPaymentId,
    this.isApproved = true,
    this.status = 'available',
    this.viewsCount = 0,
    this.phoneClicks = 0,
    this.whatsappClicks = 0,
    required this.createdAt,
  });

  bool get isAvailable => status == 'available';
  bool get isSold => status == 'sold';

  CarModel copyWith({
    String? id,
    String? dealerId,
    String? dealerName,
    String? dealerCity,
    String? title,
    String? slug,
    String? brand,
    String? model,
    String? variant,
    String? condition,
    double? price,
    int? year,
    int? kilometers,
    String? fuelType,
    String? transmission,
    String? bodyType,
    String? ownersCount,
    String? city,
    String? insuranceValidTill,
    String? color,
    String? engine,
    String? description,
    List<String>? features,
    List<String>? images,
    String? coverImage,
    bool? isFeatured,
    DateTime? featuredStartDate,
    DateTime? featuredEndDate,
    String? featuredSource,
    String? featuredPaymentId,
    bool? isApproved,
    String? status,
    int? viewsCount,
    int? phoneClicks,
    int? whatsappClicks,
    DateTime? createdAt,
  }) {
    return CarModel(
      id: id ?? this.id,
      dealerId: dealerId ?? this.dealerId,
      dealerName: dealerName ?? this.dealerName,
      dealerCity: dealerCity ?? this.dealerCity,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      variant: variant ?? this.variant,
      condition: condition ?? this.condition,
      price: price ?? this.price,
      year: year ?? this.year,
      kilometers: kilometers ?? this.kilometers,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      bodyType: bodyType ?? this.bodyType,
      ownersCount: ownersCount ?? this.ownersCount,
      city: city ?? this.city,
      insuranceValidTill: insuranceValidTill ?? this.insuranceValidTill,
      color: color ?? this.color,
      engine: engine ?? this.engine,
      description: description ?? this.description,
      features: features ?? this.features,
      images: images ?? this.images,
      coverImage: coverImage ?? this.coverImage,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredStartDate: featuredStartDate ?? this.featuredStartDate,
      featuredEndDate: featuredEndDate ?? this.featuredEndDate,
      featuredSource: featuredSource ?? this.featuredSource,
      featuredPaymentId: featuredPaymentId ?? this.featuredPaymentId,
      isApproved: isApproved ?? this.isApproved,
      status: status ?? this.status,
      viewsCount: viewsCount ?? this.viewsCount,
      phoneClicks: phoneClicks ?? this.phoneClicks,
      whatsappClicks: whatsappClicks ?? this.whatsappClicks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dealerId': dealerId,
      'dealerName': dealerName,
      'dealerCity': dealerCity,
      'title': title,
      'slug': slug,
      'brand': brand,
      'model': model,
      'variant': variant,
      'condition': condition,
      'price': price,
      'year': year,
      'kilometers': kilometers,
      'fuelType': fuelType,
      'transmission': transmission,
      'bodyType': bodyType,
      'ownersCount': ownersCount,
      'city': city,
      'insuranceValidTill': insuranceValidTill,
      'color': color,
      'engine': engine,
      'description': description,
      'features': features,
      'images': images,
      'coverImage': coverImage,
      'isFeatured': isFeatured,
      'featuredStartDate': featuredStartDate?.toIso8601String(),
      'featuredEndDate': featuredEndDate?.toIso8601String(),
      'featuredSource': featuredSource,
      'featuredPaymentId': featuredPaymentId,
      'isApproved': isApproved,
      'status': status,
      'viewsCount': viewsCount,
      'phoneClicks': phoneClicks,
      'whatsappClicks': whatsappClicks,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CarModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return CarModel(
      id: id ?? map['id'] ?? '',
      dealerId: map['dealerId'] ?? '',
      dealerName: map['dealerName'] ?? '',
      dealerCity: map['dealerCity'] ?? '',
      title: map['title'] ?? '',
      slug: map['slug'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      variant: map['variant'] ?? '',
      condition: map['condition'] ?? 'Used',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      year: (map['year'] as num?)?.toInt() ?? 2022,
      kilometers: (map['kilometers'] as num?)?.toInt() ?? 0,
      fuelType: map['fuelType'] ?? 'Petrol',
      transmission: map['transmission'] ?? 'Manual',
      bodyType: map['bodyType'] ?? 'Sedan',
      ownersCount: map['ownersCount'] ?? '1st Owner',
      city: map['city'] ?? '',
      insuranceValidTill: map['insuranceValidTill'] ?? 'Comprehensive',
      color: map['color'] ?? 'White',
      engine: map['engine'] ?? '',
      description: map['description'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      coverImage: map['coverImage'] ?? (map['images'] != null && (map['images'] as List).isNotEmpty ? map['images'][0] : ''),
      isFeatured: map['isFeatured'] ?? false,
      featuredStartDate: map['featuredStartDate'] != null ? DateTime.tryParse(map['featuredStartDate']) : null,
      featuredEndDate: map['featuredEndDate'] != null ? DateTime.tryParse(map['featuredEndDate']) : null,
      featuredSource: map['featuredSource'],
      featuredPaymentId: map['featuredPaymentId'],
      isApproved: map['isApproved'] ?? true,
      status: map['status'] ?? 'available',
      viewsCount: (map['viewsCount'] as num?)?.toInt() ?? 0,
      phoneClicks: (map['phoneClicks'] as num?)?.toInt() ?? 0,
      whatsappClicks: (map['whatsappClicks'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
