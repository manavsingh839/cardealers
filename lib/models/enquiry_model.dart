class EnquiryModel {
  final String id;
  final String carId;
  final String carTitle;
  final String dealerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String message;
  final String source; // 'Car Detail Page' | 'Dealer Profile' | 'WhatsApp' | 'Phone' | 'Enquiry Form'
  final String status; // 'New' | 'Contacted' | 'Interested' | 'Converted' | 'Closed'
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnquiryModel({
    required this.id,
    required this.carId,
    required this.carTitle,
    required this.dealerId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail = '',
    required this.message,
    this.source = 'Car Detail Page',
    this.status = 'New',
    required this.createdAt,
    this.updatedAt,
  });

  bool get isConverted => status.toLowerCase() == 'converted';
  bool get isNew => status.toLowerCase() == 'new';

  EnquiryModel copyWith({
    String? id,
    String? carId,
    String? carTitle,
    String? dealerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? message,
    String? source,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnquiryModel(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      carTitle: carTitle ?? this.carTitle,
      dealerId: dealerId ?? this.dealerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      message: message ?? this.message,
      source: source ?? this.source,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'carTitle': carTitle,
      'dealerId': dealerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'message': message,
      'source': source,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory EnquiryModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return EnquiryModel(
      id: id ?? map['id'] ?? '',
      carId: map['carId'] ?? '',
      carTitle: map['carTitle'] ?? '',
      dealerId: map['dealerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      message: map['message'] ?? '',
      source: map['source'] ?? 'Car Detail Page',
      status: map['status'] ?? 'New',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
    );
  }
}
