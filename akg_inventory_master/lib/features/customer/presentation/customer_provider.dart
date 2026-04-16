import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/customer.dart';
// uuid import removed - unused here

// ── Mock Initial Data ──────────────────────────────────────────────────
final initialMockCustomers = [
  const Customer(
    id: '9e66ced9',
    customerCode: 'AKG-001',
    name: 'Bpk. Sukirno (Bejo)',
    address: 'Krajan I, Wringinanom, Gresik, Jawa Timur 61176',
    isPpnEnabled: false,
    termDays: 30,
  ),
  const Customer(
    id: 'b4f21a3c',
    customerCode: 'AKG-002',
    name: 'PT Gemilang Jaya',
    address:
        'Jl. Bypass Krian No.2, Tundungan, Sidomojo, Kec. Krian, Kabupaten Sidoarjo, Jawa Timur 61262',
    isPpnEnabled: true,
    termDays: 14,
  ),
  const Customer(
    id: 'c7ea9b10',
    customerCode: 'AKG-003',
    name: 'Bapak Angga',
    address:
        'Jl. Bypass Krian No.2, Tundungan, Sidomojo, Kec. Krian, Kabupaten Sidoarjo, Jawa Timur 61262',
    isPpnEnabled: false,
    termDays: 14,
  ),
];

// ── Notifier ──────────────────────────────────────────────────────────

class CustomerListNotifier extends Notifier<List<Customer>> {
  @override
  List<Customer> build() {
    return [...initialMockCustomers]; // Initialize with mock data
  }

  void addCustomer(Customer customer) {
    state = [...state, customer];
  }

  void updateCustomer(Customer updatedCustomer) {
    state = [
      for (final cust in state)
        if (cust.id == updatedCustomer.id) updatedCustomer else cust,
    ];
  }

  // Generate automated customer code for new entries
  String generateNextCustomerCode() {
    final count = state.length;
    return 'AKG-${(count + 1).toString().padLeft(3, '0')}';
  }
}

final customerListProvider =
    NotifierProvider<CustomerListNotifier, List<Customer>>(
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
