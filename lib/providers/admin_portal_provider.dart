import 'package:flutter/foundation.dart';
import '../data/app_data_store.dart';
import '../models/dealer_model.dart';
import '../models/car_model.dart';
import '../models/enquiry_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/admin_settings_model.dart';
import '../services/dealer_service.dart';
import '../services/car_service.dart';

class AdminPortalProvider extends ChangeNotifier {
  final AppDataStore _dataStore = AppDataStore();
  final DealerService _dealerService = DealerService();
  final CarService _carService = CarService();

  AdminPortalProvider() {
    _dataStore.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _dataStore.removeListener(notifyListeners);
    super.dispose();
  }

  List<DealerModel> get dealers => _dataStore.dealers;
  List<CarModel> get cars => _dataStore.cars;
  List<EnquiryModel> get enquiries => _dataStore.enquiries;
  List<SubscriptionPlanModel> get plans => _dataStore.plans;
  AdminSettingsModel get settings => _dataStore.adminSettings;

  // Platform KPIs
  int get totalDealers => dealers.length;
  int get activeDealers => dealers.where((d) => d.status == 'approved').length;
  int get pendingDealers => dealers.where((d) => d.verificationStatus == 'pending' || d.verificationStatus == 'submitted').length;
  int get verifiedDealers => dealers.where((d) => d.isVerified).length;
  int get suspendedDealers => dealers.where((d) => d.status == 'suspended').length;

  int get totalCars => cars.length;
  int get activeCars => cars.where((c) => c.status == 'available').length;
  int get featuredCars => cars.where((c) => c.isFeatured).length;

  int get totalEnquiries => enquiries.length;
  int get convertedEnquiries => enquiries.where((e) => e.status.toLowerCase() == 'converted').length;

  double get monthlyRevenue {
    double total = 0.0;
    for (var dealer in dealers) {
      if (dealer.subscriptionStatus == 'active') {
        final plan = plans.firstWhere((p) => p.id == dealer.subscriptionPlanId, orElse: () => plans.first);
        total += plan.priceMonthly;
      }
    }
    return total;
  }

  // Dealer Verification Actions
  void approveDealer(String dealerId) {
    _dealerService.approveDealer(dealerId);
    notifyListeners();
  }

  void rejectDealer(String dealerId) {
    _dealerService.rejectDealer(dealerId);
    notifyListeners();
  }

  void verifyDealer(String dealerId) {
    _dealerService.verifyDealer(dealerId, verifiedBy: 'Super Admin');
    notifyListeners();
  }

  void suspendDealer(String dealerId) {
    _dealerService.suspendDealer(dealerId);
    notifyListeners();
  }

  void reactivateDealer(String dealerId) {
    _dealerService.reactivateDealer(dealerId);
    notifyListeners();
  }

  // Subscription Actions
  void activateSubscription(String dealerId, String planId, int months) {
    _dealerService.activateSubscription(dealerId, planId, months);
    notifyListeners();
  }

  void extendSubscription(String dealerId, int extraDays) {
    _dealerService.extendSubscription(dealerId, extraDays);
    notifyListeners();
  }

  void extendTrial(String dealerId, int extraDays) {
    _dealerService.extendTrial(dealerId, extraDays);
    notifyListeners();
  }

  void expireSubscription(String dealerId) {
    _dealerService.expireSubscription(dealerId);
    notifyListeners();
  }

  // Car Actions
  void toggleFeatured(String carId, bool isFeatured) {
    _carService.toggleFeatured(carId, isFeatured);
    notifyListeners();
  }

  void deleteCar(String carId) {
    _carService.deleteCar(carId);
    notifyListeners();
  }

  // Plan Actions
  void updatePlan(SubscriptionPlanModel plan) {
    _dataStore.updatePlan(plan);
    notifyListeners();
  }

  // Settings Actions
  void updateSettings(AdminSettingsModel updatedSettings) {
    _dataStore.updateSettings(updatedSettings);
    notifyListeners();
  }
}
