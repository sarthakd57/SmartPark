class Booking {
  final String id;
  final String lotId;
  final String slotId;
  final String paymentStatus;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalPrice;

  Booking({
    required this.id,
    required this.lotId,
    required this.slotId,
    required this.paymentStatus,
    required this.startTime,
    this.endTime,
    required this.totalPrice,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] as String,

      lotId: json['lot_id'] is Map
          ? json['lot_id']['_id'] as String
          : json['lot_id'] as String,

      slotId: json['slot_id'] is Map
          ? json['slot_id']['_id'] as String
          : json['slot_id'] as String,

      paymentStatus: json['payment_status'] as String? ?? 'pending',

      startTime: DateTime.parse(json['start_time'] as String),

      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,

      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
