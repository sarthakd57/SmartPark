import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/parking_lot.dart';
import '../providers/auth_provider.dart';
import '../providers/parking_provider.dart';
import '../services/api_client.dart';
import '../services/booking_service.dart';
import 'admin_lots_screen.dart';
import 'map_screen.dart';
import 'lot_detail_screen.dart';
import 'my_bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ParkingProvider>().fetchLots());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final parking = context.watch<ParkingProvider>();

    final apiClient = context.read<ApiClient>();
    final bookingService = BookingService(apiClient);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Park Smart'),
        actions: [
          if (auth.user?.role == 'admin')
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminLotsScreen(),
                  ),
                );
              },
              child: const Text('Admin'),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MyBookingsScreen(
                    bookingService: bookingService,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => parking.fetchLots(),
        child: parking.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Nearby parking lots',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MapScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Map'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: parking.lots.length,
                      itemBuilder: (context, index) {
                        final lot = parking.lots[index];
                        return _ParkingLotCard(
                          lot: lot,
                          bookingService: bookingService,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ParkingLotCard extends StatelessWidget {
  const _ParkingLotCard({
    required this.lot,
    required this.bookingService,
  });

  final ParkingLot lot;
  final BookingService bookingService;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(lot.name),
        subtitle: Text(
          '${lot.address ?? ''}\nAvailable: ${lot.availableSlots}/${lot.totalSlots}',
        ),
        isThreeLine: true,
        trailing: Text('₹${lot.pricePerHour}/hr'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LotDetailScreen(
                lot: lot,
                bookingService: bookingService,
              ),
            ),
          );
        },
      ),
    );
  }
}

