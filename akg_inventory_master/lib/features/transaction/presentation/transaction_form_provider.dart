import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/transaction_document.dart';
import 'transaction_history_provider.dart';
import '../../customer/domain/customer.dart';
import '../../inventory/domain/item.dart';
import '../../inventory/presentation/item_master_provider.dart';

// ── Mock Data (will be replaced by Supabase/SQLite later) ─────────────────

// Mock data for customers → customer_provider.dart
// Mock data for items → item_master_provider.dart (itemListProvider)


// ── Transaction Form State ────────────────────────────────────────────────

/// Represents a selected SKU and its scanned serial numbers (cylinders).
class TransactionLineState {
  final Item? selectedSku;
  final List<String> serialNumbers;
  final int reservedQty;
  final String adminNote;

  const TransactionLineState({
    this.selectedSku,
    this.serialNumbers = const [],
    this.reservedQty = 0,
    this.adminNote = '',
  });

  int get qty => serialNumbers.length;

  TransactionLineState copyWith({
    Item? selectedSku,
    List<String>? serialNumbers,
    int? reservedQty,
    String? adminNote,
  }) {
    return TransactionLineState(
      selectedSku: selectedSku ?? this.selectedSku,
      serialNumbers: serialNumbers ?? this.serialNumbers,
      reservedQty: reservedQty ?? this.reservedQty,
      adminNote: adminNote ?? this.adminNote,
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
  final bool isScannerEnabled;
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
    this.isScannerEnabled = false,
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
    bool? isScannerEnabled,
    String? savedMessage,
  }) {
    return TransactionFormState(
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      mutationCode: mutationCode ?? this.mutationCode,
      inputMode: inputMode ?? this.inputMode,
      transactionDate: transactionDate ?? this.transactionDate,
      sysDocNumber: sysDocNumber ?? this.sysDocNumber,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      lines: lines ?? this.lines,
      isSaving: isSaving ?? this.isSaving,
      isScannerEnabled: isScannerEnabled ?? this.isScannerEnabled,
      savedMessage: savedMessage,
    );
  }
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

  void toggleScanner() {
    state = state.copyWith(isScannerEnabled: !state.isScannerEnabled);
  }

  // ── Barcode Scanner Logic ──

  void processBarcode(String barcode) {
    if (!state.isScannerEnabled) return;

    // 1. Mock Asset Database Lookup (Barcode -> Item SKU ID + Serial)
    final assetDb = {
      'BAR-101': {'sku': 'item-001', 'sn': 'OXY-101', 'name': 'OXYGEN 6m3'},
      'BAR-102': {'sku': 'item-001', 'sn': 'OXY-102', 'name': 'OXYGEN 6m3'},
      'BAR-201': {'sku': 'item-002', 'sn': 'OXY7-201', 'name': 'OXYGEN 7m3'},
      'BAR-301': {'sku': 'item-003', 'sn': 'CO2-301', 'name': 'CO2 25kg'},
    };

    final asset = assetDb[barcode];
    if (asset == null) {
      state = state.copyWith(savedMessage: '! Barcode [ $barcode ] tidak terdaftar');
      return;
    }

    final targetSkuId = asset['sku']!;
    final targetSn = asset['sn']!;

    // 2. Find or Add SKU Line
    final lines = [...state.lines];
    int lineIndex = lines.indexWhere((l) => l.selectedSku?.id == targetSkuId);

    if (lineIndex == -1) {
      // Auto-add new line for this SKU
      // We'll use the name from asset mock for simplicity
      final items = ref.read(itemListProvider);
      final sku = items.firstWhere((i) => i.id == targetSkuId, orElse: () => Item(id: targetSkuId, itemCode: targetSkuId, name: asset['name']!, unit: 'Btl', basePrice: 0));
      
      final newLine = TransactionLineState(selectedSku: sku, serialNumbers: [targetSn]);
      state = state.copyWith(lines: [...state.lines, newLine], savedMessage: '✓ New SKU & SN Added: $targetSn');
      return;
    }

    // 3. Add Serial Number to the existing line
    toggleSerialNumber(lineIndex, targetSn);
    state = state.copyWith(savedMessage: '✓ Scan Success: $targetSn ditambahkan');
  }

  // ── Line Items Management ──

  void updateLineAdminNote(int index, String note) {
    final newLines = [...state.lines];
    newLines[index] = newLines[index].copyWith(adminNote: note);
    state = state.copyWith(lines: newLines);
  }

  /// Toggle serial number selection (Enumlist style)
  void toggleSerialNumber(int lineIndex, String sn) {
    final newLines = [...state.lines];
    final currentLine = newLines[lineIndex];
    
    final updatedSerials = [...currentLine.serialNumbers];
    if (updatedSerials.contains(sn)) {
      updatedSerials.remove(sn);
    } else {
      // RESERVE limitation check
      if (state.inputMode == InputMode.reserve && currentLine.reservedQty > 0) {
        if (updatedSerials.length >= currentLine.reservedQty) {
          state = state.copyWith(savedMessage: '! Kuantitas melebihi batas reservasi (${currentLine.reservedQty})');
          return;
        }
      }
      updatedSerials.add(sn);
    }

    newLines[lineIndex] = currentLine.copyWith(serialNumbers: updatedSerials);
    state = state.copyWith(lines: newLines);
  }

  List<String> getAvailableSerials(String? itemId) {
    if (itemId == null) return [];
    // Mock Serial Numbers database based on SKU
    final mockMap = {
      'item-001': ['OXY-101', 'OXY-102', 'OXY-103', 'OXY-104', 'OXY-105'],
      'item-002': ['OXY7-201', 'OXY7-202', 'OXY7-203'],
      'item-003': ['CO2-301', 'CO2-302', 'CO2-303', 'CO2-304'],
      'item-004': ['N2-401', 'N2-402'],
      'item-005': ['AR-501', 'AR-502', 'AR-503'],
    };
    return mockMap[itemId] ?? [];
  }

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

  void updateReservedQty(int index, int qty) {
    if (qty < 0) return;
    final newLines = [...state.lines];
    newLines[index] = newLines[index].copyWith(reservedQty: qty);
    state = state.copyWith(lines: newLines);
  }

  void addLineSerialNumber(int lineIndex, String serialNumber) {
    final sn = serialNumber.trim();
    if (sn.isEmpty) return;

    final newLines = [...state.lines];
    final currentLine = newLines[lineIndex];
    
    // RESERVE limitation check
    if (state.inputMode == InputMode.reserve && currentLine.reservedQty > 0) {
      if (currentLine.serialNumbers.length >= currentLine.reservedQty) {
        state = state.copyWith(savedMessage: '! Kuantitas melebihi batas reservasi (${currentLine.reservedQty})');
        return;
      }
    }

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

  Future<void> saveTransaction({DocStatus actionStatus = DocStatus.draft}) async {
    if (state.selectedCustomer == null) {
      state = state.copyWith(savedMessage: 'Pilih customer terlebih dahulu');
      return;
    }
    
    final validLines = state.lines.where((l) => l.selectedSku != null && l.serialNumbers.isNotEmpty).toList();
    if (validLines.isEmpty) {
      state = state.copyWith(savedMessage: 'Tambahkan minimal 1 Item SKU beserta Serial Number tabung');
      return;
    }

    // If trying to close under RESERVE mode, ensure lines hit their reservedQty exactly.
    if (state.inputMode == InputMode.reserve && actionStatus == DocStatus.completed) {
      for (final line in validLines) {
        if (line.serialNumbers.length < line.reservedQty) {
          state = state.copyWith(savedMessage: '! Tidak bisa Close: Kuantitas Serial Number (${line.serialNumbers.length}) belum memenuhi target reservasi (${line.reservedQty}) untuk SKU ${line.selectedSku?.itemCode}');
          return;
        }
      }
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
      status: actionStatus,
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
