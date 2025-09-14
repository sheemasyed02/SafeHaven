import 'package:flutter/foundation.dart';
import '../models/service_models.dart';
import '../models/user_profile.dart';
import 'escrow_payment_service.dart';

/// Booking management service
class BookingService {
  // In-memory storage for demo (in real app, this would be a database)
  static final List<ServiceBooking> _bookings = [];
  static final List<EscrowTransaction> _escrowTransactions = [];

  /// Create a new booking
  static Future<ServiceBooking> createBooking({
    required String customerId,
    required UserProfile provider,
    required ServiceCategory serviceCategory,
    required String title,
    required String description,
    required double amount,
    required DateTime scheduledDate,
    required String location,
    required PaymentMethod paymentMethod,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    final bookingId = 'BK_${now.millisecondsSinceEpoch}';

    // Create escrow transaction if using escrow payment
    EscrowTransaction? escrowTransaction;
    if (paymentMethod == PaymentMethod.escrow) {
      escrowTransaction = await EscrowPaymentService.createEscrowTransaction(
        bookingId: bookingId,
        customerId: customerId,
        providerId: provider.id,
        amount: amount,
        paymentMethod: paymentMethod,
      );
      _escrowTransactions.add(escrowTransaction);
    }

    final booking = ServiceBooking(
      id: bookingId,
      customerId: customerId,
      providerId: provider.id,
      serviceCategory: serviceCategory,
      title: title,
      description: description,
      amount: amount,
      status: BookingStatus.pending,
      scheduledDate: scheduledDate,
      location: location,
      createdAt: now,
      updatedAt: now,
      escrowTransactionId: escrowTransaction?.id,
      paymentStatus: paymentMethod == PaymentMethod.escrow 
          ? PaymentStatus.pending 
          : PaymentStatus.pending,
    );

    _bookings.add(booking);

    if (kDebugMode) {
      print('Created booking: ${booking.id}');
      print('Provider: ${provider.name}');
      print('Service: ${serviceCategory.displayName}');
      print('Amount: ₹$amount');
      print('Payment method: ${paymentMethod.value}');
    }

    return booking;
  }

  /// Get bookings for a customer
  static Future<List<ServiceBooking>> getCustomerBookings(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookings.where((booking) => booking.customerId == customerId).toList();
  }

  /// Get bookings for a provider
  static Future<List<ServiceBooking>> getProviderBookings(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookings.where((booking) => booking.providerId == providerId).toList();
  }

  /// Update booking status
  static Future<ServiceBooking> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
    if (bookingIndex == -1) {
      throw Exception('Booking not found');
    }

    final booking = _bookings[bookingIndex];
    final updatedBooking = booking.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    _bookings[bookingIndex] = updatedBooking;

    // Handle escrow release when service is completed
    if (newStatus == BookingStatus.completed && booking.escrowTransactionId != null) {
      await EscrowPaymentService.releaseEscrowFunds(
        transactionId: booking.escrowTransactionId!,
        providerId: booking.providerId,
      );
    }

    if (kDebugMode) {
      print('Updated booking ${booking.id} status to ${newStatus.value}');
    }

    return updatedBooking;
  }

  /// Get booking by ID
  static Future<ServiceBooking?> getBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _bookings.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  /// Cancel booking
  static Future<bool> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final booking = await getBookingById(bookingId);
    if (booking == null) {
      throw Exception('Booking not found');
    }

    // Update booking status
    await updateBookingStatus(
      bookingId: bookingId,
      newStatus: BookingStatus.cancelled,
    );

    // Handle escrow refund if applicable
    if (booking.escrowTransactionId != null) {
      await EscrowPaymentService.refundCustomer(
        transactionId: booking.escrowTransactionId!,
        customerId: booking.customerId,
        amount: booking.amount,
        reason: reason,
      );
    }

    if (kDebugMode) {
      print('Cancelled booking ${booking.id}: $reason');
    }

    return true;
  }

  /// Get escrow transaction for booking
  static Future<EscrowTransaction?> getEscrowTransaction(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _escrowTransactions.firstWhere((tx) => tx.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  /// Get booking statistics for provider
  static Future<Map<String, dynamic>> getProviderStats(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final providerBookings = await getProviderBookings(providerId);
    
    final totalBookings = providerBookings.length;
    final completedBookings = providerBookings.where((b) => b.status == BookingStatus.completed).length;
    final activeBookings = providerBookings.where((b) => 
        b.status == BookingStatus.accepted || b.status == BookingStatus.inProgress).length;
    final totalEarnings = providerBookings
        .where((b) => b.status == BookingStatus.completed)
        .fold<double>(0.0, (sum, booking) => sum + booking.amount);

    return {
      'total_bookings': totalBookings,
      'completed_bookings': completedBookings,
      'active_bookings': activeBookings,
      'total_earnings': totalEarnings,
      'completion_rate': totalBookings > 0 ? (completedBookings / totalBookings) * 100 : 0.0,
    };
  }

  /// Get booking statistics for customer
  static Future<Map<String, dynamic>> getCustomerStats(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final customerBookings = await getCustomerBookings(customerId);
    
    final totalBookings = customerBookings.length;
    final completedBookings = customerBookings.where((b) => b.status == BookingStatus.completed).length;
    final activeBookings = customerBookings.where((b) => 
        b.status == BookingStatus.accepted || b.status == BookingStatus.inProgress).length;
    final totalSpent = customerBookings
        .where((b) => b.status == BookingStatus.completed)
        .fold<double>(0.0, (sum, booking) => sum + booking.amount);

    return {
      'total_bookings': totalBookings,
      'completed_bookings': completedBookings,
      'active_bookings': activeBookings,
      'total_spent': totalSpent,
    };
  }

  /// Clear all bookings (for demo purposes)
  static void clearAllBookings() {
    _bookings.clear();
    _escrowTransactions.clear();
    if (kDebugMode) {
      print('Cleared all bookings and transactions');
    }
  }
}