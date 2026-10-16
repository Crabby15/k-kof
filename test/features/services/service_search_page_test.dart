import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jasa_dekat/features/booking/domain/booking_request.dart';
import 'package:jasa_dekat/features/services/application/service_providers.dart';
import 'package:jasa_dekat/features/services/data/service_repository.dart'
    show ServiceRepository, demoServices;
import 'package:jasa_dekat/features/services/domain/service_item.dart';
import 'package:jasa_dekat/features/services/presentation/service_search_page.dart';

import '../feature_test_repository.dart';

Widget _app(ServiceRepository repository) => ProviderScope(
      overrides: [serviceRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: ServiceSearchPage()),
    );

void main() {
  testWidgets('shows loading while search data is fetched', (tester) async {
    final response = Completer<List<ServiceItem>>();
    await tester.pumpWidget(_app(_DelayedSearchRepository(response)));
    expect(find.byKey(const Key('search-loading')), findsOneWidget);
    response.complete(demoServices);
    await tester.pumpAndSettle();
    expect(find.text('Servis laptop'), findsOneWidget);
  });

  testWidgets('filters loaded services by query', (tester) async {
    await tester
        .pumpWidget(_app(FeatureTestRepository(services: demoServices)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-input')), 'guru');
    await tester.pumpAndSettle();

    expect(find.text('Guru les privat'), findsOneWidget);
    expect(find.text('Servis laptop'), findsNothing);
  });

  testWidgets('shows empty result when query has no match', (tester) async {
    await tester
        .pumpWidget(_app(FeatureTestRepository(services: demoServices)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-input')), 'tidak ada');
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada jasa yang cocok.'), findsOneWidget);
  });

  testWidgets('shows error and retry reloads search data', (tester) async {
    final repository = FeatureTestRepository(
      services: demoServices,
      failFirstFetch: true,
    );
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search-retry')), findsOneWidget);
    await tester.tap(find.byKey(const Key('search-retry')));
    await tester.pumpAndSettle();
    expect(repository.fetchCount, 2);
    expect(find.text('Servis laptop'), findsOneWidget);
  });
}

class _DelayedSearchRepository implements ServiceRepository {
  _DelayedSearchRepository(this.response);
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
