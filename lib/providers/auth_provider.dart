import 'package:flutter/foundation.dart';
import '../data/app_data_store.dart';
import '../models/user_model.dart';
import '../models/dealer_model.dart';
import '../services/dealer_service.dart';

class AuthProvider extends ChangeNotifier {
  final AppDataStore _dataStore = AppDataStore();
  final DealerService _dealerService = DealerService();

  UserModel? get currentUser => _dataStore.currentUser;
  DealerModel? get currentDealer => _dataStore.currentDealer;

  bool get isAuthenticated => currentUser != null;
  bool get isAdmin => currentUser?.isAdmin ?? false;
  bool get isDealer => currentUser?.isDealer ?? false;

  AuthProvider() {
    _dataStore.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _dataStore.removeListener(notifyListeners);
    super.dispose();
  }

  // Demo Login as Super Admin
  void loginAsAdmin() {
    _dataStore.loginAsAdmin();
  }

  // Login as a specific dealer (e.g. Apex Motors)
  void loginAsDealer(String dealerId) {
    _dataStore.loginAsDealer(dealerId);
  }

  // Dealer Registration with 7-Day Free Trial
  DealerModel registerDealer({
    required String businessName,
    required String ownerName,
    required String email,
    required String phone,
    required String whatsapp,
    required String city,
    required String address,
  }) {
    final dealer = _dealerService.registerDealer(
      businessName: businessName,
      ownerName: ownerName,
      email: email,
      phone: phone,
      whatsapp: whatsapp,
      city: city,
      address: address,
    );

    // Auto login as the registered dealer
    _dataStore.loginAsDealer(dealer.id);
    return dealer;
  }

  void logout() {
    _dataStore.logout();
  }
}
