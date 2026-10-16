import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jasa_dekat/features/booking/domain/booking_request.dart';
import 'package:jasa_dekat/features/services/data/service_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('booking CRUD survives repository recreation', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final writer = DemoServiceRepository(preferences: preferences);
    final booking = BookingRequest(
      id: 'booking-1',
      serviceId: 'service-laptop',
      customerName: 'Demo customer',
      scheduledAt: DateTime(2030, 1, 2),
      note: 'Ganti keyboard',
      status: 'pending',
      createdAt: DateTime(2029, 12, 1),
    );

    await writer.createBooking(booking);
    final reopenedRepository = DemoServiceRepository(preferences: preferences);
    final restored = (await reopenedRepository.fetchBookings()).single;
    expect(restored.toJson(), booking.toJson());

    await reopenedRepository
        .updateBooking(booking.copyWith(status: 'confirmed'));
    expect((await writer.fetchBookings()).single.status, 'confirmed');

    await writer.deleteBooking(booking.id);
    expect(await reopenedRepository.fetchBookings(), isEmpty);
  });
}
