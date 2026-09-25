import 'package:flutter_test/flutter_test.dart';
import 'package:cardealers/data/app_data_store.dart';
import 'package:cardealers/models/analytics_model.dart';
import 'package:cardealers/services/car_service.dart';
import 'package:cardealers/services/dealer_service.dart';
import 'package:cardealers/services/payment_service.dart';

void main() {
  group('Car Dealer Lead Generation SaaS Unit Tests', () {
    late AppDataStore dataStore;
    late DealerService dealerService;
    late CarService carService;
    late SubscriptionService subscriptionService;

    setUp(() {
      dataStore = AppDataStore();
      dealerService = DealerService();
      carService = CarService();
      subscriptionService = SubscriptionService();
    });

    test('1. Seed Data Loaded: 10 Dealers & Realistic Indian Cars', () {
      expect(dataStore.dealers.length, greaterThanOrEqualTo(10));
      expect(dataStore.cars.length, greaterThanOrEqualTo(15));
      expect(dataStore.plans.length, equals(3));

      // Verify Muktsar dealer exists
      final muktsarDealer = dataStore.dealers.firstWhere((d) => d.city == 'Muktsar');
      expect(muktsarDealer.businessName, equals('Apex Motors'));
      expect(muktsarDealer.isVerified, isTrue);
      expect(muktsarDealer.isDemo, isTrue);
    });

    test('2. 7-Day Free Trial Auto-Assignment upon Dealer Registration', () {
      final newDealer = dealerService.registerDealer(
        businessName: 'Ludhiana Auto Hub',
        ownerName: 'Manpreet Singh',
        email: 'manpreet@ludhianaauto.com',
        phone: '+91 98765 12345',
        whatsapp: '+919876512345',
        city: 'Ludhiana',
        address: 'Ferozepur Road',
      );

      expect(newDealer.isInTrial, isTrue);
      expect(newDealer.remainingTrialDays, inInclusiveRange(6, 7));
      expect(newDealer.subscriptionStatus, equals('trial'));
      expect(newDealer.verificationStatus, equals('submitted'));
    });

    test('3. Verification Pipeline: Pending -> Submitted -> Approved -> Verified', () {
      final testDealerId = 'dealer_10'; // Skyline Motors (initially pending)
      expect(dataStore.dealers.firstWhere((d) => d.id == testDealerId).isVerified, isFalse);

      // Super Admin verifies dealer
      dealerService.verifyDealer(testDealerId);
      final verifiedDealer = dataStore.dealers.firstWhere((d) => d.id == testDealerId);

      expect(verifiedDealer.isVerified, isTrue);
      expect(verifiedDealer.verificationStatus, equals('verified'));
      expect(verifiedDealer.verifiedBy, equals('Super Admin'));
      expect(verifiedDealer.verifiedAt, isNotNull);
    });

    test('4. Conversion Analytics: Safe Division and Accurate Calculation', () {
      // Zero test
      const zeroStats = DealerPerformanceStats(carViews: 0, totalEnquiries: 0, convertedLeads: 0);
      expect(zeroStats.enquiryConversionRate, equals(0.0));
      expect(zeroStats.leadConversionRate, equals(0.0));

      // Realistic numbers
      const stats = DealerPerformanceStats(
        carViews: 342,
        whatsappClicks: 48,
        phoneClicks: 21,
        totalEnquiries: 13,
        convertedLeads: 3,
      );

      // Total direct interactions
      expect(stats.totalCustomerInteractions, equals(48 + 21 + 13)); // 82

      // Enquiry conversion: (13 / 342) * 100 = 3.8%
      expect(stats.enquiryConversionRate, equals(3.8));

      // Lead conversion: (3 / 13) * 100 = 23.1%
      expect(stats.leadConversionRate, equals(23.1));
    });

    test('5. Multi-Criteria Car Search and Dynamic Filtering', () {
      // Search by brand
      final marutiCars = carService.searchCars(CarFilterParams(brand: 'Maruti Suzuki'));
      expect(marutiCars.every((c) => c.brand == 'Maruti Suzuki'), isTrue);

      // Search by city
      final muktsarCars = carService.searchCars(CarFilterParams(city: 'Muktsar'));
      expect(muktsarCars.every((c) => c.city == 'Muktsar'), isTrue);

      // Search by price range
      final budgetCars = carService.searchCars(CarFilterParams(maxPrice: 1000000));
      expect(budgetCars.every((c) => c.price <= 1000000), isTrue);
    });

    test('6. Subscription Listing Limit Enforcement', () {
      final starterPlan = dataStore.plans.firstWhere((p) => p.id == 'starter');
      final activeDealer = dataStore.dealers.first.copyWith(
        subscriptionStatus: 'active',
        subscriptionPlanId: 'starter',
      );

      // Under limit
      expect(subscriptionService.canDealerAddCar(activeDealer, 5, starterPlan), isTrue);

      // At limit
      expect(subscriptionService.canDealerAddCar(activeDealer, 10, starterPlan), isFalse);

      // Suspended dealer cannot add
      final suspended = activeDealer.copyWith(status: 'suspended');
      expect(subscriptionService.canDealerAddCar(suspended, 2, starterPlan), isFalse);
    });

    test('7. Super Admin Pricing Plans Configuration', () {
      final businessPlan = dataStore.plans.firstWhere((p) => p.id == 'business');
      expect(businessPlan.priceMonthly, equals(999.0));
      expect(businessPlan.carLimit, equals(30));
      expect(businessPlan.isRecommended, isTrue);

      // Update plan price & limit dynamically
      final updatedPlan = businessPlan.copyWith(priceMonthly: 1099, carLimit: 35);
      dataStore.updatePlan(updatedPlan);

      final fetched = dataStore.plans.firstWhere((p) => p.id == 'business');
      expect(fetched.priceMonthly, equals(1099.0));
      expect(fetched.carLimit, equals(35));
    });
  });
}
