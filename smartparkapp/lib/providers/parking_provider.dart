import 'package:flutter/material.dart';

import '../models/parking_lot.dart';
import '../services/api_client.dart';

class ParkingProvider extends ChangeNotifier {
  ParkingProvider(this._apiClient);

  final ApiClient _apiClient;

  List<ParkingLot> _lots = [];
  bool _loading = false;

  List<ParkingLot> get lots => _lots;
  bool get isLoading => _loading;

  Future<void> fetchLots() async {
    _setLoading(true);
    try {
      final list = await _apiClient.getList('/api/parking/lots');
      _lots = list
          .map((e) => ParkingLot.fromJson(e as Map<String, dynamic>))
          .toList();
    } finally {
      _setLoading(false);
    }
  }

  void updateAvailability(String lotId, int availableSlots) {
    final index = _lots.indexWhere((l) => l.id == lotId);
    if (index != -1) {
      final lot = _lots[index];
      _lots[index] = ParkingLot(
        id: lot.id,
        name: lot.name,
        address: lot.address,
        totalSlots: lot.totalSlots,
        availableSlots: availableSlots,
        pricePerHour: lot.pricePerHour,
        latitude: lot.latitude,
        longitude: lot.longitude,
      );
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}

