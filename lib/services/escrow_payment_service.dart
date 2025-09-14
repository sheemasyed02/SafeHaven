import 'package:flutter/foundation.dart';
import '../models/service_models.dart';

/// Escrow payment service for secure transactions
class EscrowPaymentService {
  static const double _escrowFeePercentage = 0.02; // 2% fee

  /// Calculate escrow fee
  static double calculateEscrowFee(double amount) {
    return amount * _escrowFeePercentage;
  }

  /// Calculate total with escrow fee
  static double calculateTotalWithFee(double amount) {
    return amount + calculateEscrowFee(amount);
  }

  /// Create escrow transaction (mock implementation)
  static Future<EscrowTransaction> createEscrowTransaction({
    required String bookingId,
    required String customerId,
    required String providerId,
    required double amount,
    required PaymentMethod paymentMethod,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    final now = DateTime.now();
    final transactionId = 'ESC_${now.millisecondsSinceEpoch}';

    return EscrowTransaction(
      id: transactionId,
      bookingId: bookingId,
      customerId: customerId,
      providerId: providerId,
      amount: amount,
      escrowFee: paymentMethod == PaymentMethod.escrow ? calculateEscrowFee(amount) : 0.0,
      totalAmount: paymentMethod == PaymentMethod.escrow ? calculateTotalWithFee(amount) : amount,
      paymentMethod: paymentMethod,
      status: EscrowStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Process payment (mock implementation)
  static Future<bool> processPayment({
    required String transactionId,
    required PaymentMethod paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 3));

    // Mock payment success (90% success rate)
    final random = DateTime.now().millisecond;
    final success = random % 10 != 0; // 90% success rate

    if (kDebugMode) {
      print('Processing payment for transaction: $transactionId');
      print('Payment method: ${paymentMethod.value}');
      print('Payment result: ${success ? 'SUCCESS' : 'FAILED'}');
    }

    return success;
  }

  /// Release escrow funds to provider
  static Future<bool> releaseEscrowFunds({
    required String transactionId,
    required String providerId,
  }) async {
    // Simulate fund release delay
    await Future.delayed(const Duration(seconds: 2));

    if (kDebugMode) {
      print('Releasing escrow funds for transaction: $transactionId to provider: $providerId');
    }

    return true; // Mock success
  }

  /// Refund customer (in case of cancellation)
  static Future<bool> refundCustomer({
    required String transactionId,
    required String customerId,
    required double amount,
    required String reason,
  }) async {
    // Simulate refund delay
    await Future.delayed(const Duration(seconds: 2));

    if (kDebugMode) {
      print('Refunding ₹$amount to customer: $customerId for transaction: $transactionId');
      print('Reason: $reason');
    }

    return true; // Mock success
  }

  /// Get transaction status
  static Future<EscrowTransaction?> getTransactionStatus(String transactionId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock response - in real app, this would fetch from backend
    return null;
  }
}

/// Escrow transaction model
class EscrowTransaction {
  final String id;
  final String bookingId;
  final String customerId;
  final String providerId;
  final double amount;
  final double escrowFee;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final EscrowStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;
  final DateTime? releasedAt;
  final String? failureReason;

  EscrowTransaction({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.amount,
    required this.escrowFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.releasedAt,
    this.failureReason,
  });

  factory EscrowTransaction.fromJson(Map<String, dynamic> json) {
    return EscrowTransaction(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      escrowFee: (json['escrow_fee'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentMethod: PaymentMethod.fromString(json['payment_method'] as String),
      status: EscrowStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      releasedAt: json['released_at'] != null ? DateTime.parse(json['released_at'] as String) : null,
      failureReason: json['failure_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'customer_id': customerId,
      'provider_id': providerId,
      'amount': amount,
      'escrow_fee': escrowFee,
      'total_amount': totalAmount,
      'payment_method': paymentMethod.value,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'released_at': releasedAt?.toIso8601String(),
      'failure_reason': failureReason,
    };
  }

  EscrowTransaction copyWith({
    String? id,
    String? bookingId,
    String? customerId,
    String? providerId,
    double? amount,
    double? escrowFee,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    EscrowStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    DateTime? releasedAt,
    String? failureReason,
  }) {
    return EscrowTransaction(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      amount: amount ?? this.amount,
      escrowFee: escrowFee ?? this.escrowFee,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
      releasedAt: releasedAt ?? this.releasedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}

/// Escrow transaction status
enum EscrowStatus {
  pending('pending'),           // Payment initiated, waiting for confirmation
  paid('paid'),                 // Payment received, funds in escrow
  released('released'),         // Funds released to provider
  refunded('refunded'),         // Funds refunded to customer
  failed('failed'),             // Payment failed
  disputed('disputed');         // Transaction under dispute

  const EscrowStatus(this.value);
  final String value;

  static EscrowStatus fromString(String value) {
    for (EscrowStatus status in EscrowStatus.values) {
      if (status.value == value) return status;
    }
    return EscrowStatus.pending;
  }
}