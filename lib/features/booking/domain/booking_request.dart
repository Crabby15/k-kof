import 'dart:convert';

class BookingRequest {
  const BookingRequest({
    required this.id,
    required this.serviceId,
    required this.customerName,
    required this.scheduledAt,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String serviceId;
  final String customerName;
  final DateTime scheduledAt;
  final String note;
  final String status;
  final DateTime createdAt;

  BookingRequest copyWith({String? status}) => BookingRequest(
        id: id,
        serviceId: serviceId,
        customerName: customerName,
        scheduledAt: scheduledAt,
        note: note,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'customerName': customerName,
        'scheduledAt': scheduledAt.toIso8601String(),
        'note': note,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BookingRequest.fromJson(Map<String, dynamic> json) => BookingRequest(
        id: json['id'] as String,
        serviceId: json['serviceId'] as String,
        customerName: json['customerName'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        note: json['note'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

String encodeBookings(List<BookingRequest> bookings) =>
    jsonEncode(bookings.map((booking) => booking.toJson()).toList());
