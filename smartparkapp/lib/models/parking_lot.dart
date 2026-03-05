class ParkingLot {
  final String id;
  final String name;
  final String? address;
  final int totalSlots;
  final int availableSlots;
  final double pricePerHour;
  final double latitude;
  final double longitude;

  ParkingLot({
    required this.id,
    required this.name,
    this.address,
    required this.totalSlots,
    required this.availableSlots,
    required this.pricePerHour,
    required this.latitude,
    required this.longitude,
  });

  factory ParkingLot.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final coordinates = location['coordinates'] as List<dynamic>? ?? [0.0, 0.0];

    return ParkingLot(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      totalSlots: json['total_slots'] as int? ?? 0,
      availableSlots: json['available_slots'] as int? ?? 0,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0.0,
      longitude: (coordinates[0] as num).toDouble(),
      latitude: (coordinates[1] as num).toDouble(),
    );
  }
}

