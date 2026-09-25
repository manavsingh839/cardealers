class AnalyticsEvent {
  final String id;
  final String type; // 'car_view' | 'profile_view' | 'whatsapp_click' | 'phone_click' | 'enquiry_submit' | 'enquiry_status_change'
  final String dealerId;
  final String? carId;
  final String source;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.id,
    required this.type,
    required this.dealerId,
    this.carId,
    required this.source,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'dealerId': dealerId,
      'carId': carId,
      'source': source,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AnalyticsEvent.fromMap(Map<String, dynamic> map, [String? id]) {
    return AnalyticsEvent(
      id: id ?? map['id'] ?? '',
      type: map['type'] ?? '',
      dealerId: map['dealerId'] ?? '',
      carId: map['carId'],
      source: map['source'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class DealerPerformanceStats {
  final int carViews;
  final int profileViews;
  final int whatsappClicks;
  final int phoneClicks;
  final int totalEnquiries;
  final int newEnquiries;
  final int contactedEnquiries;
  final int interestedEnquiries;
  final int convertedLeads;
  final int closedEnquiries;

  const DealerPerformanceStats({
    this.carViews = 0,
    this.profileViews = 0,
    this.whatsappClicks = 0,
    this.phoneClicks = 0,
    this.totalEnquiries = 0,
    this.newEnquiries = 0,
    this.contactedEnquiries = 0,
    this.interestedEnquiries = 0,
    this.convertedLeads = 0,
    this.closedEnquiries = 0,
  });

  /// Total direct interaction leads (Enquiries + WhatsApp clicks + Phone calls)
  int get totalCustomerInteractions => whatsappClicks + phoneClicks + totalEnquiries;

  /// Enquiry Conversion Rate: (totalEnquiries / carViews) * 100
  /// Handled safely with 0 protection
  double get enquiryConversionRate {
    if (carViews <= 0) return 0.0;
    final rate = (totalEnquiries / carViews) * 100;
    return double.parse(rate.toStringAsFixed(1));
  }

  /// Lead Conversion Rate: (convertedLeads / totalEnquiries) * 100
  /// Handled safely with 0 protection
  double get leadConversionRate {
    if (totalEnquiries <= 0) return 0.0;
    final rate = (convertedLeads / totalEnquiries) * 100;
    return double.parse(rate.toStringAsFixed(1));
  }
}
