import 'package:flutter/foundation.dart';
import '../models/dealer_model.dart';
import '../models/car_model.dart';
import '../models/enquiry_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/admin_settings_model.dart';
import '../models/analytics_model.dart';
import '../models/user_model.dart';
import 'seed_data.dart';

class AppDataStore extends ChangeNotifier {
  static final AppDataStore _instance = AppDataStore._internal();
  factory AppDataStore() => _instance;

  AppDataStore._internal() {
    _initData();
  }

  // State
  List<DealerModel> _dealers = [];
  List<CarModel> _cars = [];
  List<EnquiryModel> _enquiries = [];
  List<SubscriptionPlanModel> _plans = [];
  final List<AnalyticsEvent> _analyticsEvents = [];
  AdminSettingsModel _adminSettings = AdminSettingsModel();

  // Current session
  UserModel? _currentUser;
  DealerModel? _currentDealer;

  // Getters
  List<DealerModel> get dealers => List.unmodifiable(_dealers);
  List<CarModel> get cars => List.unmodifiable(_cars);
  List<EnquiryModel> get enquiries => List.unmodifiable(_enquiries);
  List<SubscriptionPlanModel> get plans => List.unmodifiable(_plans);
  List<AnalyticsEvent> get analyticsEvents => List.unmodifiable(_analyticsEvents);
  AdminSettingsModel get adminSettings => _adminSettings;
  UserModel? get currentUser => _currentUser;
  DealerModel? get currentDealer => _currentDealer;

  void _initData() {
    _plans = SeedData.getPlans();
    _dealers = SeedData.getDealers();
    _cars = SeedData.getCars();
    _enquiries = SeedData.getEnquiries();

    // Default session: Unauthenticated visitor (guest)
    _currentDealer = null;
    _currentUser = null;
  }

  // Auth operations
  void setSession(UserModel? user, [DealerModel? dealer]) {
    _currentUser = user;
    _currentDealer = dealer;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _currentDealer = null;
    notifyListeners();
  }

  // Switch to Super Admin demo mode
  void loginAsAdmin() {
    _currentUser = UserModel(
      id: 'super_admin_1',
      email: 'admin@cardealer.com',
      role: 'admin',
      name: 'Super Admin',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    );
    _currentDealer = null;
    notifyListeners();
  }

  // Switch to Dealer demo mode
  void loginAsDealer(String dealerId) {
    final dealer = _dealers.firstWhere((d) => d.id == dealerId, orElse: () => _dealers.first);
    _currentDealer = dealer;
    _currentUser = UserModel(
      id: dealer.userId,
      email: dealer.email,
      role: 'dealer',
      name: dealer.businessName,
      createdAt: dealer.createdAt,
    );
    notifyListeners();
  }

  // Dealer operations
  void addDealer(DealerModel dealer) {
    _dealers.insert(0, dealer);
    notifyListeners();
  }

  void updateDealer(DealerModel updated) {
    final index = _dealers.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      _dealers[index] = updated;
      if (_currentDealer?.id == updated.id) {
        _currentDealer = updated;
      }
      notifyListeners();
    }
  }

  // Dealer Verification Lifecycle: Pending -> Submitted -> Approved -> Verified
  void updateDealerVerification(String dealerId, String verificationStatus, {String verifiedBy = 'Super Admin'}) {
    final index = _dealers.indexWhere((d) => d.id == dealerId);
    if (index != -1) {
      final existing = _dealers[index];
      final isVerified = verificationStatus.toLowerCase() == 'verified';
      final updated = existing.copyWith(
        verificationStatus: verificationStatus,
        verifiedAt: isVerified ? DateTime.now() : null,
        verifiedBy: isVerified ? verifiedBy : null,
        status: verificationStatus == 'rejected' ? 'suspended' : 'approved',
      );
      _dealers[index] = updated;
      if (_currentDealer?.id == dealerId) {
        _currentDealer = updated;
      }
      notifyListeners();
    }
  }

  // Dealer Subscription & Trial Controls
  void updateDealerSubscription(
    String dealerId, {
    String? planId,
    String? status,
    DateTime? trialEndDate,
    DateTime? renewalDate,
    DateTime? expiryDate,
  }) {
    final index = _dealers.indexWhere((d) => d.id == dealerId);
    if (index != -1) {
      final existing = _dealers[index];
      final updated = existing.copyWith(
        subscriptionPlanId: planId ?? existing.subscriptionPlanId,
        subscriptionStatus: status ?? existing.subscriptionStatus,
        trialEndDate: trialEndDate ?? existing.trialEndDate,
        renewalDate: renewalDate ?? existing.renewalDate,
        expiryDate: expiryDate ?? existing.expiryDate,
      );
      _dealers[index] = updated;
      if (_currentDealer?.id == dealerId) {
        _currentDealer = updated;
      }
      notifyListeners();
    }
  }

  // Car operations
  void addCar(CarModel car) {
    _cars.insert(0, car);
    notifyListeners();
  }

  void updateCar(CarModel updated) {
    final index = _cars.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _cars[index] = updated;
      notifyListeners();
    }
  }

  void deleteCar(String carId) {
    _cars.removeWhere((c) => c.id == carId);
    notifyListeners();
  }

  void toggleCarFeatured(String carId, bool isFeatured) {
    final index = _cars.indexWhere((c) => c.id == carId);
    if (index != -1) {
      final car = _cars[index];
      final updated = car.copyWith(
        isFeatured: isFeatured,
        featuredStartDate: isFeatured ? DateTime.now() : null,
        featuredEndDate: isFeatured ? DateTime.now().add(const Duration(days: 30)) : null,
        featuredSource: isFeatured ? 'admin_granted' : null,
      );
      _cars[index] = updated;
      notifyListeners();
    }
  }

  // Enquiry operations
  void addEnquiry(EnquiryModel enquiry) {
    _enquiries.insert(0, enquiry);
    // Also track analytics event
    recordAnalyticsEvent(AnalyticsEvent(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      type: 'enquiry_submit',
      dealerId: enquiry.dealerId,
      carId: enquiry.carId,
      source: enquiry.source,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void updateEnquiryStatus(String enquiryId, String newStatus) {
    final index = _enquiries.indexWhere((e) => e.id == enquiryId);
    if (index != -1) {
      final existing = _enquiries[index];
      final updated = existing.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      _enquiries[index] = updated;

      recordAnalyticsEvent(AnalyticsEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        type: 'enquiry_status_change',
        dealerId: existing.dealerId,
        carId: existing.carId,
        source: newStatus,
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    }
  }

  // Subscription Plan operations (Super Admin)
  void updatePlan(SubscriptionPlanModel updated) {
    final index = _plans.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _plans[index] = updated;
      notifyListeners();
    }
  }

  void addPlan(SubscriptionPlanModel plan) {
    _plans.add(plan);
    notifyListeners();
  }

  // Settings
  void updateSettings(AdminSettingsModel settings) {
    _adminSettings = settings;
    notifyListeners();
  }

  // Analytics event recording
  void recordAnalyticsEvent(AnalyticsEvent event) {
    _analyticsEvents.insert(0, event);

    // Increment corresponding car counters if carId is present
    if (event.carId != null && event.carId!.isNotEmpty) {
      final index = _cars.indexWhere((c) => c.id == event.carId);
      if (index != -1) {
        final car = _cars[index];
        if (event.type == 'car_view') {
          _cars[index] = car.copyWith(viewsCount: car.viewsCount + 1);
        } else if (event.type == 'whatsapp_click') {
          _cars[index] = car.copyWith(whatsappClicks: car.whatsappClicks + 1);
        } else if (event.type == 'phone_click') {
          _cars[index] = car.copyWith(phoneClicks: car.phoneClicks + 1);
        }
      }
    }

    // Increment dealer views count if profile_view
    if (event.type == 'profile_view') {
      final index = _dealers.indexWhere((d) => d.id == event.dealerId);
      if (index != -1) {
        final d = _dealers[index];
        _dealers[index] = d.copyWith(viewsCount: d.viewsCount + 1);
      }
    }

    notifyListeners();
  }

  // Calculate real performance stats for a dealer
  DealerPerformanceStats getDealerStats(String dealerId) {
    final dealerCars = _cars.where((c) => c.dealerId == dealerId).toList();
    final dealerEnquiries = _enquiries.where((e) => e.dealerId == dealerId).toList();

    int carViews = 0;
    int whatsappClicks = 0;
    int phoneClicks = 0;

    for (var car in dealerCars) {
      carViews += car.viewsCount;
      whatsappClicks += car.whatsappClicks;
      phoneClicks += car.phoneClicks;
    }

    final dealer = _dealers.firstWhere((d) => d.id == dealerId, orElse: () => _dealers.first);
    final profileViews = dealer.viewsCount;

    final newCount = dealerEnquiries.where((e) => e.status.toLowerCase() == 'new').length;
    final contactedCount = dealerEnquiries.where((e) => e.status.toLowerCase() == 'contacted').length;
    final interestedCount = dealerEnquiries.where((e) => e.status.toLowerCase() == 'interested').length;
    final convertedCount = dealerEnquiries.where((e) => e.status.toLowerCase() == 'converted').length;
    final closedCount = dealerEnquiries.where((e) => e.status.toLowerCase() == 'closed').length;

    return DealerPerformanceStats(
      carViews: carViews,
      profileViews: profileViews,
      whatsappClicks: whatsappClicks,
      phoneClicks: phoneClicks,
      totalEnquiries: dealerEnquiries.length,
      newEnquiries: newCount,
      contactedEnquiries: contactedCount,
      interestedEnquiries: interestedCount,
      convertedLeads: convertedCount,
      closedEnquiries: closedCount,
    );
  }
}
