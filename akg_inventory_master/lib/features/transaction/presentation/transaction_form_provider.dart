import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/transaction_document.dart';
import 'transaction_history_provider.dart';
import '../../customer/domain/customer.dart';
import '../../customer/presentation/customer_provider.dart';
import '../../inventory/domain/item.dart';

// ── Mock Data (will be replaced by Supabase/SQLite later) ─────────────────

// Mock data for customers has been moved to customer_provider.dart

final mockItems = [
  const Item(id: 'item-001', itemCode: 'OXY6M3', name: 'Oksigen 6m3', basePrice: 50000),
  const Item(id: 'item-002', itemCode: 'OXY7M3', name: 'Oksigen 7m3', basePrice: 50000),
  const Item(id: 'item-003', itemCode: 'CO2', name: 'Karbondioksida', basePrice: 165000),
  const Item(id: 'item-004', itemCode: 'N2', name: 'Nitrogen', basePrice: 80000),
  const Item(id: 'item-005', itemCode: 'AR', name: 'Argon', basePrice: 120000),
];

// ── Providers (Riverpod v3 API) ───────────────────────────────────────────

// Using customerListProvider from customer_provider.dart

/// Available items list
final itemListProvider = Provider<List<Item>>((ref) => mockItems);

// ── Transaction Form State ────────────────────────────────────────────────

/// Represents a selected SKU and its scanned serial numbers (cylinders).
class TransactionLineState {
  final Item? selectedSku;
  final List<String> serialNumbers;

  const TransactionLineState({
    this.selectedSku,
    this.serialNumbers = const [],
  });

  int get qty => serialNumbers.length;

  TransactionLineState copyWith({
    Item? selectedSku,
    List<String>? serialNumbers,
  }) {
    return TransactionLineState(
      selectedSku: selectedSku ?? this.selectedSku,
      serialNumbers: serialNumbers ?? this.serialNumbers,
    );
  }
}

class TransactionFormState {
  final Customer? selectedCustomer;
  final MutationCode mutationCode;
  final InputMode inputMode;
  final DateTime transactionDate;
  final String sysDocNumber;
  final String shippingAddress;
  final List<TransactionLineState> lines;
  final bool isSaving;
  final String? savedMessage;

  const TransactionFormState({
    this.selectedCustomer,
    this.mutationCode = MutationCode.outbound,
    this.inputMode = InputMode.bulk,
    required this.transactionDate,
    this.sysDocNumber = '',
    this.shippingAddress = '',
    this.lines = const [],
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
    List<TransactionLineState>? lines,
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
        lines: lines ?? this.lines,
        isSaving: isSaving ?? this.isSaving,
        savedMessage: savedMessage,
      );
}

/// Riverpod v3: Use Notifier instead of StateNotifier
class TransactionFormNotifier extends Notifier<TransactionFormState> {
  @override
  TransactionFormState build() {
    return TransactionFormState(
      transactionDate: DateTime.now(),
      lines: const [TransactionLineState()], // Start with 1 empty line
    );
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

  // ── Line Items Management ──

  void addLine() {
    state = state.copyWith(lines: [...state.lines, const TransactionLineState()]);
  }

  void removeLine(int index) {
    final newLines = [...state.lines];
    newLines.removeAt(index);
    state = state.copyWith(lines: newLines);
  }

  void updateLineSku(int index, Item sku) {
    final newLines = [...state.lines];
    newLines[index] = newLines[index].copyWith(selectedSku: sku);
    state = state.copyWith(lines: newLines);
  }

  void addLineSerialNumber(int lineIndex, String serialNumber) {
    final sn = serialNumber.trim();
    if (sn.isEmpty) return;

    final newLines = [...state.lines];
    final currentLine = newLines[lineIndex];
    
    if (!currentLine.serialNumbers.contains(sn)) {
      newLines[lineIndex] = currentLine.copyWith(
        serialNumbers: [...currentLine.serialNumbers, sn],
      );
      state = state.copyWith(lines: newLines);
    }
  }

  void removeLineSerialNumber(int lineIndex, String serialNumber) {
    final newLines = [...state.lines];
    final currentLine = newLines[lineIndex];
    
    final updatedSerials = currentLine.serialNumbers.where((sn) => sn != serialNumber).toList();
    newLines[lineIndex] = currentLine.copyWith(serialNumbers: updatedSerials);
    state = state.copyWith(lines: newLines);
  }

  String _generateDocumentNumber() {
    // Prefix logic: [Type][Month][Year][Sequence]
    // IN = 1, OUT = 2
    final mutationPrefix = state.mutationCode == MutationCode.outbound ? '2' : '1';
    final monthPadding = state.transactionDate.month.toString().padLeft(2, '0');
    final yearPadding = (state.transactionDate.year % 100).toString().padLeft(2, '0');
    const sequence = '0001'; // Mock sequence

    return '$mutationPrefix$monthPadding$yearPadding$sequence';
  }

  Future<void> saveTransaction() async {
    if (state.selectedCustomer == null) {
      state = state.copyWith(savedMessage: 'Pilih customer terlebih dahulu');
      return;
    }
    
    final validLines = state.lines.where((l) => l.selectedSku != null && l.serialNumbers.isNotEmpty).toList();
    if (validLines.isEmpty) {
      state = state.copyWith(savedMessage: 'Tambahkan minimal 1 Item SKU beserta Serial Number tabung');
      return;
    }

    state = state.copyWith(isSaving: true);

    await Future.delayed(const Duration(seconds: 1)); // Simulate latency

    final docNumber = state.sysDocNumber.trim().isEmpty
        ? _generateDocumentNumber()
        : state.sysDocNumber;

    // Add to history
    final newDoc = TransactionDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sysDocNumber: docNumber,
      mutation: state.mutationCode,
      inputMode: state.inputMode,
      customerId: state.selectedCustomer!.id,
      transactionDate: state.transactionDate,
      status: DocStatus.completed,
    );
    ref.read(transactionHistoryProvider.notifier).addTransaction(newDoc);

    final totalQty = validLines.fold<int>(0, (sum, line) => sum + line.qty);
    state = state.copyWith(
      isSaving: false,
      savedMessage: 'Transaksi berhasil disimpan! ($totalQty tabung dari ${validLines.length} SKU)',
    );
  }

  void clearMessage() {
    state = state.copyWith(savedMessage: null);
  }

  void resetForm() {
    state = TransactionFormState(
      transactionDate: DateTime.now(),
      lines: const [TransactionLineState()],
    );
  }
}

final transactionFormProvider =
    NotifierProvider<TransactionFormNotifier, TransactionFormState>(
  TransactionFormNotifier.new,
);
