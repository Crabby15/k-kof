import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../booking/presentation/booking_page.dart';
import '../application/service_providers.dart';
import '../domain/service_item.dart';
import 'service_visuals.dart';

class ServiceSearchPage extends ConsumerWidget {
  const ServiceSearchPage({super.key});

  static const categories = ['Semua', 'Teknologi', 'Pendidikan', 'Desain'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(serviceSearchProvider);
    final query = ref.watch(serviceSearchQueryProvider).trim().toLowerCase();
    final category = ref.watch(serviceCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cari jasa')),
      body: services.when(
        loading: () => const Center(
          key: Key('search-loading'),
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _SearchError(
          onRetry: () => ref.read(serviceSearchProvider.notifier).retry(),
        ),
        data: (items) {
          final filtered = items.where((service) {
            final matchesQuery = query.isEmpty ||
                service.title.toLowerCase().contains(query) ||
                service.category.toLowerCase().contains(query);
            final matchesCategory =
                category == null || service.category == category;
            return matchesQuery && matchesCategory;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                key: const Key('search-input'),
                onChanged: (value) =>
                    ref.read(serviceSearchQueryProvider.notifier).state = value,
                decoration: const InputDecoration(
                  hintText: 'Cari layanan atau kategori',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: categories.map((label) {
                  final selected =
                      label == 'Semua' ? category == null : category == label;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) {
                      ref.read(serviceCategoryProvider.notifier).state =
                          label == 'Semua' ? null : label;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              if (filtered.isEmpty)
                const _SearchEmpty()
              else
                for (final service in filtered)
                  _SearchServiceCard(service: service),
            ],
          );
        },
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('Layanan gagal dimuat. Periksa koneksi lalu coba lagi.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('search-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ]),
        ),
      );
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(children: [
          Icon(Icons.search_off_rounded, size: 44, color: Color(0xFF718096)),
          SizedBox(height: 12),
          Text('Tidak ada jasa yang cocok.'),
        ]),
      );
}

class _SearchServiceCard extends StatelessWidget {
  const _SearchServiceCard({required this.service});
  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    final visuals = serviceVisuals(service);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: visuals.color,
            child: Icon(visuals.icon, color: const Color(0xFF182B49)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(service.category,
                  style: Theme.of(context).textTheme.bodySmall),
              Text(service.title,
                  style: Theme.of(context).textTheme.titleMedium),
              Text(
                  '${service.priceLabel} · ★ ${service.rating} · ${service.distance}'),
            ]),
          ),
          IconButton(
            tooltip: 'Pesan layanan',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BookingPage(initialService: service),
              ),
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ]),
      ),
    );
  }
}
