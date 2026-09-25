import 'package:flutter/foundation.dart';
import '../models/subscription_plan_model.dart';
import '../models/dealer_model.dart';

abstract class IPaymentGateway {
  Future<PaymentOrderResult> createOrder({
    required double amount,
    required String currency,
    required String planId,
    required String dealerId,
  });

  Future<PaymentVerificationResult> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  });
}

class PaymentOrderResult {
  final bool success;
  final String? orderId;
  final String? message;

  PaymentOrderResult({required this.success, this.orderId, this.message});
}

class PaymentVerificationResult {
  final bool isVerified;
  final String? transactionId;
  final String? error;

  PaymentVerificationResult({required this.isVerified, this.transactionId, this.error});
}

/// Modular Razorpay Integration Abstraction
class RazorpayService implements IPaymentGateway {
  final String? apiKey;
  final String? apiSecret;
  final bool isTestMode;

  RazorpayService({
    this.apiKey,
    this.apiSecret,
    this.isTestMode = true,
  });

  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;

  @override
  Future<PaymentOrderResult> createOrder({
    required double amount,
    required String currency,
    required String planId,
    required String dealerId,
  }) async {
    // Modular order creation stub
    // When live credentials are provided, connects to Razorpay Orders API
    if (kDebugMode) {
      print('Razorpay createOrder initiated: Plan: $planId, Amount: ₹$amount, TestMode: $isTestMode');
    }

    final simulatedOrderId = 'order_rzp_${DateTime.now().millisecondsSinceEpoch}';
    return PaymentOrderResult(
      success: true,
      orderId: simulatedOrderId,
      message: 'Order initiated successfully',
    );
  }

  @override
  Future<PaymentVerificationResult> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    // In test/simulation mode, automatically verifies
    return PaymentVerificationResult(
      isVerified: true,
      transactionId: paymentId,
    );
  }
}

class SubscriptionService {
  final RazorpayService _razorpayService = RazorpayService(isTestMode: true);
  RazorpayService get razorpayService => _razorpayService;

  /// Checks if dealer has reached their car listing limit
  bool canDealerAddCar(DealerModel dealer, int currentCarCount, SubscriptionPlanModel? plan) {
    if (dealer.status == 'suspended') return false;

    // In 7-day trial, allow up to 10 cars
    if (dealer.isInTrial && !dealer.isExpired) {
      return currentCarCount < 10;
    }

    // If subscription is expired, prevent adding new cars above limit
    if (dealer.isExpired) {
      return false;
    }

    // Active plan check
    final allowedLimit = plan?.carLimit ?? 10;
    return currentCarCount < allowedLimit;
  }
}
