import 'package:url_launcher/url_launcher.dart';
import '../data/app_data_store.dart';
import '../models/enquiry_model.dart';

class EnquiryService {
  final AppDataStore _dataStore = AppDataStore();

  List<EnquiryModel> getEnquiriesForDealer(String dealerId) {
    return _dataStore.enquiries.where((e) => e.dealerId == dealerId).toList();
  }

  List<EnquiryModel> getAllEnquiries() {
    return _dataStore.enquiries;
  }

  EnquiryModel submitEnquiry({
    required String carId,
    required String carTitle,
    required String dealerId,
    required String customerName,
    required String customerPhone,
    String customerEmail = '',
    required String message,
    String source = 'Car Detail Page',
  }) {
    final enquiry = EnquiryModel(
      id: 'enq_${DateTime.now().millisecondsSinceEpoch}',
      carId: carId,
      carTitle: carTitle,
      dealerId: dealerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      message: message,
      source: source,
      status: 'New',
      createdAt: DateTime.now(),
    );

    _dataStore.addEnquiry(enquiry);
    return enquiry;
  }

  void updateStatus(String enquiryId, String status) {
    _dataStore.updateEnquiryStatus(enquiryId, status);
  }

  Future<void> callCustomer(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> whatsappCustomer(String phoneNumber, String customerName, String carTitle) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final text = 'Hello $customerName, thank you for your enquiry regarding "$carTitle". I am contacting you from the dealership.';
    final uri = Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
