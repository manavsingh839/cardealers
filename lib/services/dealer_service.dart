import '../data/app_data_store.dart';
import '../models/dealer_model.dart';

class DealerService {
  final AppDataStore _dataStore = AppDataStore();

  List<DealerModel> getAllDealers() => _dataStore.dealers;

  DealerModel? getDealerById(String id) {
    try {
      return _dataStore.dealers.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  DealerModel? getDealerBySlug(String slug) {
    try {
      return _dataStore.dealers.firstWhere((d) => d.slug == slug);
    } catch (_) {
      return null;
    }
  }

  /// Registers a new dealer and assigns default 7-day free trial
  DealerModel registerDealer({
    required String businessName,
    required String ownerName,
    required String email,
    required String phone,
    required String whatsapp,
    required String city,
    required String address,
  }) {
    final now = DateTime.now();
    final trialDays = _dataStore.adminSettings.defaultTrialDays;
    final trialEnd = now.add(Duration(days: trialDays));

    final newId = 'dealer_${now.millisecondsSinceEpoch}';
    final slug = '${businessName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-')}-${city.toLowerCase()}';

    final dealer = DealerModel(
      id: newId,
      userId: 'user_$newId',
      businessName: businessName,
      slug: slug,
      logoUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=200&auto=format&fit=crop&q=80',
      phone: phone,
      whatsapp: whatsapp,
      email: email,
      address: address,
      city: city,
      description: 'Welcome to $businessName. We are a premier automotive dealer offering verified pre-owned vehicles in $city.',
      isDemo: false,
      verificationStatus: 'submitted',
      status: 'approved',
      subscriptionPlanId: 'starter',
      subscriptionStatus: 'trial',
      trialStartDate: now,
      trialEndDate: trialEnd,
      createdAt: now,
    );

    _dataStore.addDealer(dealer);
    return dealer;
  }

  void updateProfile(DealerModel dealer) {
    _dataStore.updateDealer(dealer);
  }

  // Admin Verification Actions
  void approveDealer(String dealerId) {
    _dataStore.updateDealerVerification(dealerId, 'approved');
  }

  void rejectDealer(String dealerId) {
    _dataStore.updateDealerVerification(dealerId, 'rejected');
  }

  void verifyDealer(String dealerId, {String verifiedBy = 'Super Admin'}) {
    _dataStore.updateDealerVerification(dealerId, 'verified', verifiedBy: verifiedBy);
  }

  void suspendDealer(String dealerId) {
    final dealer = getDealerById(dealerId);
    if (dealer != null) {
      _dataStore.updateDealer(dealer.copyWith(status: 'suspended'));
    }
  }

  void reactivateDealer(String dealerId) {
    final dealer = getDealerById(dealerId);
    if (dealer != null) {
      _dataStore.updateDealer(dealer.copyWith(status: 'approved'));
    }
  }

  // Admin Subscription & Trial Actions
  void activateSubscription(String dealerId, String planId, int months) {
    final now = DateTime.now();
    _dataStore.updateDealerSubscription(
      dealerId,
      planId: planId,
      status: 'active',
      renewalDate: now.add(Duration(days: months * 30)),
      expiryDate: now.add(Duration(days: months * 30 + 5)),
    );
  }

  void extendSubscription(String dealerId, int extraDays) {
    final dealer = getDealerById(dealerId);
    if (dealer != null) {
      final currentRenewal = dealer.renewalDate ?? DateTime.now();
      _dataStore.updateDealerSubscription(
        dealerId,
        status: 'active',
        renewalDate: currentRenewal.add(Duration(days: extraDays)),
        expiryDate: currentRenewal.add(Duration(days: extraDays + 5)),
      );
    }
  }

  void extendTrial(String dealerId, int extraDays) {
    final dealer = getDealerById(dealerId);
    if (dealer != null) {
      final currentTrialEnd = dealer.trialEndDate ?? DateTime.now();
      _dataStore.updateDealerSubscription(
        dealerId,
        status: 'trial',
        trialEndDate: currentTrialEnd.add(Duration(days: extraDays)),
      );
    }
  }

  void expireSubscription(String dealerId) {
    _dataStore.updateDealerSubscription(
      dealerId,
      status: 'expired',
      expiryDate: DateTime.now().subtract(const Duration(days: 1)),
    );
  }
}
