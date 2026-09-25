import 'package:url_launcher/url_launcher.dart';
import '../data/app_data_store.dart';
import '../models/analytics_model.dart';
import '../models/car_model.dart';
import '../models/dealer_model.dart';

class AnalyticsService {
  final AppDataStore _dataStore = AppDataStore();

  void trackCarView(CarModel car) {
    _dataStore.recordAnalyticsEvent(AnalyticsEvent(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      type: 'car_view',
      dealerId: car.dealerId,
      carId: car.id,
      source: 'Car Detail Page',
      timestamp: DateTime.now(),
    ));
  }

  void trackDealerProfileView(DealerModel dealer) {
    _dataStore.recordAnalyticsEvent(AnalyticsEvent(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      type: 'profile_view',
      dealerId: dealer.id,
      source: 'Dealer Profile Page',
      timestamp: DateTime.now(),
    ));
  }

  Future<void> triggerPhoneCall({
    required String phoneNumber,
    required String dealerId,
    String? carId,
    String source = 'Phone CTA',
  }) async {
    _dataStore.recordAnalyticsEvent(AnalyticsEvent(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      type: 'phone_click',
      dealerId: dealerId,
      carId: carId,
      source: source,
      timestamp: DateTime.now(),
    ));

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  Future<void> triggerWhatsAppChat({
    required String whatsappNumber,
    required String dealerId,
    String? carId,
    String? carTitle,
    String source = 'WhatsApp CTA',
  }) async {
    _dataStore.recordAnalyticsEvent(AnalyticsEvent(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      type: 'whatsapp_click',
      dealerId: dealerId,
      carId: carId,
      source: source,
      timestamp: DateTime.now(),
    ));

    final cleanNumber = whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final text = carTitle != null
        ? 'Hi, I saw your listing for "$carTitle" on AutoDealers India. Is this car still available? Please share details.'
        : 'Hi, I found your dealership on AutoDealers India and would like to enquire about your available cars.';

    final uri = Uri.parse('https://wa.me/$cleanNumber?text=${Uri.encodeComponent(text)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }
}
