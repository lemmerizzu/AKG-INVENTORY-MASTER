import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/transaction_document.dart';
import 'transaction_history_provider.dart';
import '../../customer/domain/customer.dart';
import '../../inventory/domain/item.dart';

// ── Mock Data (will be replaced by Supabase/SQLite later) ─────────────────

final mockCustomers = [
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

final mockItems = [
  const Item(id: 'item-001', itemCode: 'OXY6M3', name: 'Oksigen 6m3', basePrice: 50000),
  const Item(id: 'item-002', itemCode: 'OXY7M3', name: 'Oksigen 7m3', basePrice: 50000),
  const Item(id: 'item-003', itemCode: 'CO2', name: 'Karbondioksida', basePrice: 165000),
  const Item(id: 'item-004', itemCode: 'N2', name: 'Nitrogen', basePrice: 80000),
  const Item(id: 'item-005', itemCode: 'AR', name: 'Argon', basePrice: 120000),
];

// ── Providers (Riverpod v3 API) ───────────────────────────────────────────

/// Available customers list
final customerListProvider = Provider<List<Customer>>((ref) => mockCustomers);

/// Available items list
final itemListProvider = Provider<List<Item>>((ref) => mockItems);

// ── Transaction Form State ────────────────────────────────────────────────

class TransactionFormState {
  final Customer? selectedCustomer;
  final MutationCode mutationCode;
  final InputMode inputMode;
  final DateTime transactionDate;
  final String sysDocNumber;
  final String shippingAddress;
  final List<ScannedItem> scannedItems;
  final bool isSaving;
  final String? savedMessage;

  const TransactionFormState({
    this.selectedCustomer,
    this.mutationCode = MutationCode.outbound,
    this.inputMode = InputMode.bulk,
    required this.transactionDate,
    this.sysDocNumber = '',
    this.shippingAddress = '',
    this.scannedItems = const [],
    this.isSaving = false,
    this.savedMessage,
  });

  TransactionFormState copyWith({
    Customer? selectedCustomer,
    MutationCode? mutationCode,
    InputMode? inputMode,
    DateTime? transactionDate,
    String? sysDocNumber,
    String? shippingAddress,
    List<ScannedItem>? scannedItems,
    bool? isSaving,
    String? savedMessage,
  }) =>
      TransactionFormState(
        selectedCustomer: selectedCustomer ?? this.selectedCustomer,
        mutationCode: mutationCode ?? this.mutationCode,
        inputMode: inputMode ?? this.inputMode,
        transactionDate: transactionDate ?? this.transactionDate,
        sysDocNumber: sysDocNumber ?? this.sysDocNumber,
        shippingAddress: shippingAddress ?? this.shippingAddress,
        scannedItems: scannedItems ?? this.scannedItems,
        isSaving: isSaving ?? this.isSaving,
        savedMessage: savedMessage,
      );
}

/// Represents a scanned or manually entered item in the form
class ScannedItem {
  final String barcode;
  final String itemName;
  final bool isBarcodeAudited;

  const ScannedItem({
    required this.barcode,
    required this.itemName,
    this.isBarcodeAudited = true,
  });
}

/// Riverpod v3: Use Notifier instead of StateNotifier
class TransactionFormNotifier extends Notifier<TransactionFormState> {
  @override
  TransactionFormState build() {
    return TransactionFormState(transactionDate: DateTime.now());
  }

  void selectCustomer(Customer customer) {
    state = state.copyWith(
      selectedCustomer: customer,
      shippingAddress: customer.address,
    );
  }

  void setMutationCode(MutationCode code) {
    state = state.copyWith(mutationCode: code);
  }

  void setInputMode(InputMode mode) {
    state = state.copyWith(inputMode: mode);
  }

  void setTransactionDate(DateTime date) {
    state = state.copyWith(transactionDate: date);
  }

  void setDocNumber(String number) {
    state = state.copyWith(sysDocNumber: number);
  }

  void setShippingAddress(String address) {
    state = state.copyWith(shippingAddress: address);
  }

  void addScannedItem(ScannedItem item) {
    state = state.copyWith(scannedItems: [...state.scannedItems, item]);
  }

  void removeScannedItem(int index) {
    final items = [...state.scannedItems];
    items.removeAt(index);
    state = state.copyWith(scannedItems: items);
  }

  void addManualBarcode(String barcode) {
    addScannedItem(ScannedItem(barcode: barcode, itemName: 'Manual: $barcode'));
  }

  void addUnauditedItem(String description) {
    addScannedItem(ScannedItem(
      barcode: 'UNAUDITED-${DateTime.now().millisecondsSinceEpoch}',
      itemName: description,
      isBarcodeAudited: false,
    ));
  }

  Future<void> saveTransaction() async {
    if (state.selectedCustomer == null) {
      state = state.copyWith(savedMessage: 'Pilih customer terlebih dahulu');
      return;
    }
    if (state.scannedItems.isEmpty) {
      state = state.copyWith(savedMessage: 'Tambahkan minimal 1 item');
      return;
    }

    state = state.copyWith(isSaving: true);

    // Simulate save (will connect to SQLite/Supabase later)
    await Future.delayed(const Duration(seconds: 1));

    // Add to history
    final newDoc = TransactionDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sysDocNumber: state.sysDocNumber.isEmpty
          ? 'DOC-${DateTime.now().millisecondsSinceEpoch}'
          : state.sysDocNumber,
      mutation: state.mutationCode,
      inputMode: state.inputMode,
      customerId: state.selectedCustomer!.id,
      transactionDate: state.transactionDate,
      status: DocStatus.completed,
    );
    ref.read(transactionHistoryProvider.notifier).addTransaction(newDoc);

    final count = state.scannedItems.length;
    state = state.copyWith(
      isSaving: false,
      savedMessage: 'Transaksi berhasil disimpan! ($count item)',
    );
  }

  void clearMessage() {
    state = state.copyWith(savedMessage: null);
  }

  void resetForm() {
    state = TransactionFormState(transactionDate: DateTime.now());
  }
}

final transactionFormProvider =
    NotifierProvider<TransactionFormNotifier, TransactionFormState>(
  TransactionFormNotifier.new,
);
