import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../providers/parking_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  io.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    final socket = io.io(
      'http://localhost:5000/availability',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    socket.connect();
    socket.onConnect((_) {
      final lots = context.read<ParkingProvider>().lots;
      for (final lot in lots) {
        socket.emit('joinLot', lot.id);
      }
    });
    socket.on(
      'availabilityUpdated',
      (data) {
        final lotId = data['lotId'] as String;
        final available = data['availableSlots'] as int;
        context.read<ParkingProvider>().updateAvailability(lotId, available);
        setState(() {});
      },
    );
    _socket = socket;
  }

  @override
  void dispose() {
    _socket?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lots = context.watch<ParkingProvider>().lots;

    final markers = lots
        .map(
          (lot) => Marker(
            markerId: MarkerId(lot.id),
            position: LatLng(lot.latitude, lot.longitude),
            infoWindow: InfoWindow(
              title: lot.name,
              snippet:
                  'Available: ${lot.availableSlots}/${lot.totalSlots} (₹${lot.pricePerHour}/hr)',
            ),
          ),
        )
        .toSet();

    final initialLat = lots.isNotEmpty ? lots.first.latitude : 12.9716;
    final initialLng = lots.isNotEmpty ? lots.first.longitude : 77.5946;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(initialLat, initialLng),
          zoom: 13,
        ),
        markers: markers,
        onMapCreated: (controller) => _controller = controller,
      ),
    );
  }
}

