import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jasa_dekat/features/booking/domain/booking_request.dart';
import 'package:jasa_dekat/features/booking/presentation/booking_page.dart';
import 'package:jasa_dekat/features/services/application/service_providers.dart';
import 'package:jasa_dekat/features/services/data/service_repository.dart'
    show ServiceRepository, demoServices;
import 'package:jasa_dekat/features/services/domain/service_item.dart';

import '../feature_test_repository.dart';

Widget _app(ServiceRepository repository) => ProviderScope(
      overrides: [serviceRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: BookingPage()),
    );

void main() {
  testWidgets('shows initial loading before services arrive', (tester) async {
    final response = Completer<List<ServiceItem>>();
    final repository = _DelayedRepository(response);
    await tester.pumpWidget(_app(repository));

    expect(find.byKey(const Key('booking-loading')), findsOneWidget);
    response.complete(demoServices);
    await tester.pumpAndSettle();
    expect(find.text('Ceritakan kebutuhanmu'), findsOneWidget);
  });

  testWidgets('shows loaded services and booking form', (tester) async {
    await tester
        .pumpWidget(_app(FeatureTestRepository(services: demoServices)));
    await tester.pumpAndSettle();

    expect(find.text('Ceritakan kebutuhanmu'), findsOneWidget);
    expect(find.byKey(const Key('booking-service-field')), findsOneWidget);
    expect(find.byKey(const Key('booking-submit-button')), findsOneWidget);
  });

  testWidgets('shows empty state when repository has no services',
      (tester) async {
    await tester.pumpWidget(_app(FeatureTestRepository(services: [])));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('booking-empty')), findsOneWidget);
    expect(find.text('Belum ada layanan yang bisa dipesan.'), findsOneWidget);
  });

  testWidgets('shows error and retry loads services', (tester) async {
    final repository = FeatureTestRepository(
      services: demoServices,
      failFirstFetch: true,
    );
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('booking-error')), findsOneWidget);
    await tester.tap(find.byKey(const Key('booking-retry')));
    await tester.pumpAndSettle();

    expect(repository.fetchCount, 2);
    expect(find.text('Ceritakan kebutuhanmu'), findsOneWidget);
  });

  testWidgets('form validation blocks an incomplete booking', (tester) async {
    await tester
        .pumpWidget(_app(FeatureTestRepository(services: demoServices)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('booking-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Pilih layanan'), findsOneWidget);
    expect(find.text('Tanggal wajib diisi'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('booking-date-field')),
      'tanggal salah',
    );
    await tester.tap(find.byKey(const Key('booking-submit-button')));
    await tester.pumpAndSettle();
    expect(find.text('Gunakan format tanggal YYYY-MM-DD'), findsOneWidget);
  });

  testWidgets('submit shows loading and ignores a second tap', (tester) async {
    final submitResponse = Completer<void>();
    final repository = FeatureTestRepository(
      services: demoServices,
      submit: (_) => submitResponse.future,
    );
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('booking-service-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Servis laptop').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('booking-date-field')),
      _tomorrowIsoDate(),
    );
    await tester.tap(find.byKey(const Key('booking-submit-button')));
    await tester.pump();

    expect(find.byKey(const Key('booking-submit-loading')), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(
                find.byKey(const Key('booking-submit-button')))
            .onPressed,
        isNull);
    await tester.tap(find.byKey(const Key('booking-submit-button')));
    expect(repository.bookings, hasLength(1));

    submitResponse.complete();
    await tester.pumpAndSettle();
    expect(find.text('Permintaan booking berhasil dikirim.'), findsOneWidget);
  });
}

String _tomorrowIsoDate() {
  final date = DateTime.now().add(const Duration(days: 1));
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _DelayedRepository implements ServiceRepository {
  _DelayedRepository(this.response);
  final Completer<List<ServiceItem>> response;

  @override
  Future<List<ServiceItem>> fetchServices() => response.future;

  @override
  Future<void> createBooking(BookingRequest request) async {}

  @override
  Future<List<BookingRequest>> fetchBookings() async => [];

  @override
  Future<void> updateBooking(BookingRequest request) async {}

  @override
  Future<void> deleteBooking(String id) async {}
}
