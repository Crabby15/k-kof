import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/service_repository.dart';
import '../domain/service_item.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => DemoServiceRepository(),
);

final serviceSearchQueryProvider = StateProvider<String>((ref) => '');
final serviceCategoryProvider = StateProvider<String?>((ref) => null);

final serviceSearchProvider =
    AsyncNotifierProvider<ServiceSearchNotifier, List<ServiceItem>>(
  ServiceSearchNotifier.new,
);

class ServiceSearchNotifier extends AsyncNotifier<List<ServiceItem>> {
  @override
  Future<List<ServiceItem>> build() =>
      ref.read(serviceRepositoryProvider).fetchServices();

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(serviceRepositoryProvider).fetchServices(),
    );
  }
}
