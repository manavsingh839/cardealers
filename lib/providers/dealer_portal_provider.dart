import 'package:flutter/foundation.dart';
import '../data/app_data_store.dart';
import '../models/dealer_model.dart';
import '../models/car_model.dart';
import '../models/enquiry_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/analytics_model.dart';
import '../services/car_service.dart';
import '../services/enquiry_service.dart';
import '../services/dealer_service.dart';
import '../services/payment_service.dart';

class DealerPortalProvider extends ChangeNotifier {
  final AppDataStore _dataStore = AppDataStore();
  final CarService _carService = CarService();
  final EnquiryService _enquiryService = EnquiryService();
  final DealerService _dealerService = DealerService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  DealerPortalProvider() {
    _dataStore.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _dataStore.removeListener(notifyListeners);
    super.dispose();
  }

  DealerModel? get dealer => _dataStore.currentDealer;
  String get dealerId => dealer?.id ?? 'dealer_1';

  // Subscription Plan
  SubscriptionPlanModel? get currentPlan {
    final planId = dealer?.subscriptionPlanId ?? 'starter';
    try {
      return _dataStore.plans.firstWhere((p) => p.id == planId);
    } catch (_) {
      return _dataStore.plans.first;
    }
  }

  // Cars of this dealer
  List<CarModel> get dealerCars => _carService.getCarsByDealer(dealerId);
  List<CarModel> get activeCars => dealerCars.where((c) => c.status == 'available').toList();
  List<CarModel> get soldCars => dealerCars.where((c) => c.status == 'sold').toList();

  // Enquiries of this dealer
  List<EnquiryModel> get dealerEnquiries => _enquiryService.getEnquiriesForDealer(dealerId);

  // Performance & Lead Overview Stats (computed safely from stored data)
  DealerPerformanceStats get stats => _dataStore.getDealerStats(dealerId);

  // Listing Limit check
  bool get canAddCar {
    if (dealer == null) return false;
    return _subscriptionService.canDealerAddCar(dealer!, dealerCars.length, currentPlan);
  }

  int get carLimit {
    if (dealer?.isInTrial == true && dealer?.isExpired == false) {
      return 10;
    }
    return currentPlan?.carLimit ?? 10;
  }

  // Add or update car
  bool saveCar(CarModel car) {
    if (car.id.isEmpty) {
      // Adding new car: check limit
      if (!canAddCar) {
        return false;
      }
      final newCar = car.copyWith(
        id: 'car_${DateTime.now().millisecondsSinceEpoch}',
        dealerId: dealerId,
        dealerName: dealer?.businessName ?? 'Dealer',
        dealerCity: dealer?.city ?? 'Muktsar',
        createdAt: DateTime.now(),
      );
      _carService.saveCar(newCar);
    } else {
      _carService.saveCar(car);
    }
    notifyListeners();
    return true;
  }

  void deleteCar(String carId) {
    _carService.deleteCar(carId);
    notifyListeners();
  }

  void markCarSold(String carId) {
    _carService.markAsSold(carId);
    notifyListeners();
  }

  // CRM status change
  void updateEnquiryStatus(String enquiryId, String status) {
    _enquiryService.updateStatus(enquiryId, status);
    notifyListeners();
  }

  // Customer actions
  void callCustomer(String phone) {
    _enquiryService.callCustomer(phone);
  }

  void whatsappCustomer(String phone, String name, String carTitle) {
    _enquiryService.whatsappCustomer(phone, name, carTitle);
  }

  // Profile update
  void updateProfile(DealerModel updated) {
    _dealerService.updateProfile(updated);
    notifyListeners();
  }
}
