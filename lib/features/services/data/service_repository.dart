import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../booking/domain/booking_request.dart';
import '../domain/service_item.dart';

abstract interface class ServiceRepository {
  Future<List<ServiceItem>> fetchServices();
  Future<void> createBooking(BookingRequest request);
  Future<List<BookingRequest>> fetchBookings();
  Future<void> updateBooking(BookingRequest request);
  Future<void> deleteBooking(String id);
}

/// Local demo repository. Replace with Supabase implementation when configured.
class DemoServiceRepository implements ServiceRepository {
  DemoServiceRepository(
      {List<ServiceItem>? services, SharedPreferences? preferences})
      : _services = services ?? demoServices,
        _preferences = preferences;

  final List<ServiceItem> _services;
  final SharedPreferences? _preferences;
  static const _bookingsKey = 'jasa_dekat.bookings.v1';

  Future<SharedPreferences> get _store async =>
      _preferences ?? await SharedPreferences.getInstance();

  @override
  Future<List<BookingRequest>> fetchBookings() async {
    final raw = (await _store).getString(_bookingsKey);
    if (raw == null) return [];
    final rows = jsonDecode(raw) as List<dynamic>;
    return rows
        .map((row) => BookingRequest.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(List<BookingRequest> rows) async =>
      (await _store).setString(_bookingsKey, encodeBookings(rows));

  @override
  Future<List<ServiceItem>> fetchServices() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_services);
  }

  @override
  Future<void> createBooking(BookingRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final rows = await fetchBookings();
    await _save([...rows, request]);
  }

  @override
  Future<void> updateBooking(BookingRequest request) async {
    final rows = await fetchBookings();
    final index = rows.indexWhere((row) => row.id == request.id);
    if (index < 0) throw StateError('Booking tidak ditemukan');
    rows[index] = request;
    await _save(rows);
  }

  @override
  Future<void> deleteBooking(String id) async {
    final rows = await fetchBookings();
    await _save(rows.where((row) => row.id != id).toList());
  }
}

const demoServices = <ServiceItem>[
  ServiceItem(
    id: 'service-laptop',
    category: 'Teknologi',
    title: 'Servis laptop',
    priceLabel: 'Mulai Rp50.000',
    rating: 4.9,
    distance: '2.1 km',
  ),
  ServiceItem(
    id: 'service-tutor',
    category: 'Pendidikan',
    title: 'Guru les privat',
    priceLabel: 'Mulai Rp75.000',
    rating: 4.8,
    distance: '1.4 km',
  ),
  ServiceItem(
    id: 'service-design',
    category: 'Desain',
    title: 'Desain grafis',
    priceLabel: 'Mulai Rp100.000',
    rating: 5.0,
    distance: '3.0 km',
  ),
];
