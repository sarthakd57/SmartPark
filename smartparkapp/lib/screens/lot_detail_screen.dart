import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/parking_lot.dart';
import '../services/booking_service.dart';

class LotDetailScreen extends StatefulWidget {
  const LotDetailScreen({
    super.key,
    required this.lot,
    required this.bookingService,
  });

  final ParkingLot lot;
  final BookingService bookingService;

  @override
  State<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends State<LotDetailScreen> {
  late Razorpay _razorpay;
  int _durationHours = 1;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  String? _pendingBookingId;

  Future<void> _startBooking() async {
    setState(() => _loading = true);
    try {
      final booking = await widget.bookingService.createBooking(
        lotId: widget.lot.id,
        durationHours: _durationHours,
      );
      _pendingBookingId = booking.id;
      final order = await widget.bookingService.createOrder(
        booking.id,
      ); // Razorpay order
      print(order);

      final options = {
        'key': 'rzp_test_SMqalSL7nmLKYX', // test key, replace with env/config
        'amount': order['amount'], // in paise
        'currency': order['currency'],
        'name': 'Park Smart',
        'description': 'Parking booking',
        'order_id': order['id'],
        'prefill': {'contact': '9999999999', 'email': 'test@parksmart.com'},
        'theme': {'color': '#3399cc'},
      };

      _razorpay.open(options);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start booking: $e')));
      setState(() => _loading = false);
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_pendingBookingId == null) return;
    try {
      await widget.bookingService.verifyPayment(
        bookingId: _pendingBookingId!,
        response: response,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment successful')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
    } finally {
      setState(() => _loading = false);
      _pendingBookingId = null;
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Wallet: ${response.walletName}")));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
    setState(() => _loading = false);
    _pendingBookingId = null;
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.lot.pricePerHour * _durationHours;

    return Scaffold(
      appBar: AppBar(title: Text(widget.lot.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lot.address ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Available: ${widget.lot.availableSlots}/${widget.lot.totalSlots}',
            ),
            const SizedBox(height: 8),
            Text('₹${widget.lot.pricePerHour}/hr'),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Duration (hours):'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _durationHours,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1')),
                    DropdownMenuItem(value: 2, child: Text('2')),
                    DropdownMenuItem(value: 3, child: Text('3')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _durationHours = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Total: ₹$totalPrice'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _startBooking,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Book & Pay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
