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
    try {
      final next = booking.copyWith(
        status: booking.status == 'pending' ? 'confirmed' : 'pending',
      );
      await ref.read(serviceRepositoryProvider).updateBooking(next);
      if (!mounted) return;
      setState(_refresh);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Status pesanan berhasil diperbarui.'),
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Status gagal diperbarui. Coba lagi.'),
        ));
      }
    }
  }

  Future<void> _delete(BookingRequest booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus pesanan?'),
        content: const Text('Pesanan ini akan dihapus dari perangkat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(serviceRepositoryProvider).deleteBooking(booking.id);
      if (!mounted) return;
      setState(_refresh);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pesanan berhasil dihapus.'),
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pesanan gagal dihapus. Coba lagi.'),
        ));
      }
    }
  }

  void _reload() {
    setState(_refresh);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Memuat ulang daftar pesanan...'),
      duration: Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan tersimpan'),
          actions: [
            IconButton(
              key: const Key('booking-refresh'),
              tooltip: 'Muat ulang dari penyimpanan lokal',
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: FutureBuilder<List<BookingRequest>>(
              future: _bookings,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Memuat pesanan...'),
                    ]),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.error_outline, size: 40),
                        const SizedBox(height: 12),
                        const Text('Gagal membaca pesanan lokal.'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba lagi'),
                        ),
                      ]),
                    ),
                  );
                }
                final bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return const Center(
                    key: Key('booking-list-empty'),
                    child:
                        Text('Belum ada pesanan. Buat pesanan untuk memulai.'),
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
                          tooltip: 'Tindakan untuk ${service.title}',
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
          ),
        ),
      );
}
