import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({
    super.key,
    required this.bookingService,
  });

  final BookingService bookingService;

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<List<Booking>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.bookingService.getMyBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: FutureBuilder<List<Booking>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings yet.'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return ListTile(
                title: Text('Booking ${b.id.substring(0, 6)}'),
                subtitle: Text(
                  'Status: ${b.paymentStatus}\n'
                  'From: ${b.startTime}\n'
                  'To: ${b.endTime ?? '-'}',
                ),
                trailing: Text('₹${b.totalPrice.toStringAsFixed(0)}'),
              );
            },
          );
        },
      ),
    );
  }
}

