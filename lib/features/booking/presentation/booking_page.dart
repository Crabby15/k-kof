import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/application/service_providers.dart';
import '../../services/domain/service_item.dart';
import '../application/booking_submit_provider.dart';
import '../domain/booking_request.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({super.key, this.initialService});
  final ServiceItem? initialService;

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _noteController = TextEditingController();
  ServiceItem? _selectedService;

  @override
  void initState() {
    super.initState();
    _selectedService = widget.initialService;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final service = _selectedService!;
    final date = DateTime.parse(_dateController.text);
    await ref.read(bookingSubmitProvider.notifier).submit(
          BookingRequest(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            serviceId: service.id,
            customerName: 'Demo customer',
            scheduledAt: date,
            note: _noteController.text.trim(),
            status: 'pending',
            createdAt: DateTime.now(),
          ),
        );
    if (!mounted) return;
    final result = ref.read(bookingSubmitProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan gagal dikirim. Coba lagi.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permintaan booking berhasil dikirim.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(serviceSearchProvider);
    final submitState = ref.watch(bookingSubmitProvider);
    final isSubmitting = submitState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat pesanan')),
      body: services.when(
        loading: () => const Center(
          key: Key('booking-loading'),
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _BookingError(
          onRetry: () => ref.read(serviceSearchProvider.notifier).retry(),
        ),
        data: (items) {
          if (items.isEmpty) return const _BookingEmpty();
          final selectedIsAvailable =
              items.any((item) => item.id == _selectedService?.id);
          final selected = selectedIsAvailable ? _selectedService : null;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                const Text(
                  'Ceritakan kebutuhanmu',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text('Pilih layanan dan waktu yang kamu inginkan.'),
                const SizedBox(height: 24),
                DropdownButtonFormField<ServiceItem>(
                  key: const Key('booking-service-field'),
                  initialValue: selected,
                  decoration: const InputDecoration(
                    labelText: 'Layanan',
                    prefixIcon: Icon(Icons.handyman_outlined),
                  ),
                  items: items
                      .map((service) => DropdownMenuItem(
                            value: service,
                            child: Text(service.title),
                          ))
                      .toList(),
                  onChanged: isSubmitting
                      ? null
                      : (service) => setState(() => _selectedService = service),
                  validator: (value) => value == null ? 'Pilih layanan' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('booking-date-field'),
                  controller: _dateController,
                  enabled: !isSubmitting,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal pengerjaan',
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal wajib diisi';
                    }
                    if (DateTime.tryParse(value) == null) {
                      return 'Gunakan format tanggal YYYY-MM-DD';
                    }
                    final selectedDate = DateTime.parse(value);
                    final today = DateTime.now();
                    final todayStart =
                        DateTime(today.year, today.month, today.day);
                    if (selectedDate.isBefore(todayStart)) {
                      return 'Tanggal tidak boleh di masa lalu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('booking-note-field'),
                  controller: _noteController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 300,
                  enabled: !isSubmitting,
                  decoration: const InputDecoration(
                    labelText: 'Catatan kebutuhan',
                    hintText:
                        'Jelaskan detail yang perlu diketahui penyedia jasa',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value != null && value.length > 300
                      ? 'Maksimal 300 karakter'
                      : null,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('booking-submit-button'),
                  onPressed: isSubmitting ? null : _submit,
                  icon: isSubmitting
                      ? const SizedBox(
                          key: Key('booking-submit-loading'),
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(isSubmitting
                      ? 'Mengirim pesanan...'
                      : 'Kirim permintaan'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookingEmpty extends StatelessWidget {
  const _BookingEmpty();
  @override
  Widget build(BuildContext context) => const Center(
        key: Key('booking-empty'),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.inbox_outlined, size: 48),
            SizedBox(height: 12),
            Text('Belum ada layanan yang bisa dipesan.'),
          ]),
        ),
      );
}

class _BookingError extends StatelessWidget {
  const _BookingError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        key: const Key('booking-error'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('Layanan gagal dimuat. Coba muat ulang.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('booking-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ]),
        ),
      );
}
