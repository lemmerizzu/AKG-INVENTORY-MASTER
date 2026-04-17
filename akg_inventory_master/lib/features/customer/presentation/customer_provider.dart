import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/customer.dart';
import '../data/customer_repository.dart';
// uuid import removed - unused here

// ── Repository singleton ───────────────────────────────────────────────
final customerRepositoryProvider = Provider((ref) => CustomerRepository());

// ── Customer List (SQLite-backed) ──────────────────────────────────────

class CustomerListNotifier extends AsyncNotifier<List<Customer>> {
  @override
  Future<List<Customer>> build() async {
    final repo = ref.read(customerRepositoryProvider);
    return repo.getAll();
  }

  Future<void> addCustomer(Customer customer) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.insert(customer);
    state = AsyncData(await repo.getAll());
  }

  Future<void> updateCustomer(Customer updatedCustomer) async {
    final repo = ref.read(customerRepositoryProvider);
    await repo.update(updatedCustomer);
    state = AsyncData(await repo.getAll());
  }

  /// Generate automated customer code for new entries.
  String generateNextCustomerCode() {
    final current = state.value ?? [];
    final count = current.length;
    return 'AKG-C${(count + 1).toString().padLeft(3, '0')}';
  }

  void refresh() => ref.invalidateSelf();
}

final customerListProvider =
    AsyncNotifierProvider<CustomerListNotifier, List<Customer>>(
  CustomerListNotifier.new,
);

/// State management for the Customer form interaction
class SelectedCustomerNotifier extends Notifier<Customer?> {
  @override
  Customer? build() => null;

  void select(Customer? customer) => state = customer;
}

final selectedCustomerProvider =
    NotifierProvider<SelectedCustomerNotifier, Customer?>(
  SelectedCustomerNotifier.new,
);

// ══════════════════════════════════════════════════════════════════════
// Related List Providers (FutureProvider.family)
// ══════════════════════════════════════════════════════════════════════

/// Pricelist entries that reference this customer.
final customerPricelistProvider =
    FutureProvider.family<List<CustomerPricelistView>, String>(
  (ref, customerId) async {
    final repo = ref.read(customerRepositoryProvider);
    return repo.getPricelistByCustomerId(customerId);
  },
);

/// Assets currently held by this customer.
final customerAssetsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, customerId) async {
    final repo = ref.read(customerRepositoryProvider);
    return repo.getAssetsByCustomerId(customerId);
  },
);

/// Recent transactions for this customer.
final customerTransactionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, customerId) async {
    final repo = ref.read(customerRepositoryProvider);
    return repo.getTransactionsByCustomerId(customerId);
  },
);
