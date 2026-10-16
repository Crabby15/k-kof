import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/application/service_providers.dart';
import '../domain/booking_request.dart';

final bookingSubmitProvider =
    NotifierProvider<BookingSubmitNotifier, AsyncValue<void>>(
  BookingSubmitNotifier.new,
);

class BookingSubmitNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit(BookingRequest request) async {
    // Guard protects against repeated calls even if a caller bypasses the UI.
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(serviceRepositoryProvider).createBooking(request),
    );
  }
}
