import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/application/service_providers.dart';
import '../../services/data/service_repository.dart';
import '../domain/booking_request.dart';

class BookingListPage extends ConsumerStatefulWidget {
  const BookingListPage({super.key});

  @override
  ConsumerState<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends ConsumerState<BookingListPage> {
  late Future<List<BookingRequest>> _bookings;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() =>
      _bookings = ref.read(serviceRepositoryProvider).fetchBookings();

  Future<void> _update(BookingRequest booking) async {
    final next = booking.copyWith(
      status: booking.status == 'pending' ? 'confirmed' : 'pending',
    );
    await ref.read(serviceRepositoryProvider).updateBooking(next);
    setState(_refresh);
  }

  Future<void> _delete(BookingRequest booking) async {
    await ref.read(serviceRepositoryProvider).deleteBooking(booking.id);
    setState(_refresh);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan tersimpan'),
          actions: [
            IconButton(
              key: const Key('booking-refresh'),
              tooltip: 'Muat ulang dari penyimpanan lokal',
              onPressed: () => setState(_refresh),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: FutureBuilder<List<BookingRequest>>(
          future: _bookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Gagal membaca pesanan lokal.'));
            }
            final bookings = snapshot.data ?? [];
            if (bookings.isEmpty) {
              return const Center(
                key: Key('booking-list-empty'),
                child: Text('Belum ada pesanan. Buat pesanan untuk memulai.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final service = demoServices.firstWhere(
                  (item) => item.id == booking.serviceId,
                  orElse: () => demoServices.first,
                );
                return Card(
                  child: ListTile(
                    title: Text(service.title),
                    subtitle: Text(
                      '${booking.scheduledAt.toLocal().toString().split(' ').first} · ${booking.status}\n${booking.note.isEmpty ? 'Tanpa catatan' : booking.note}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) => action == 'delete'
                          ? _delete(booking)
                          : _update(booking),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'update',
                          child: Text(booking.status == 'pending'
                              ? 'Tandai dikonfirmasi'
                              : 'Kembalikan ke pending'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Hapus pesanan'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
}
