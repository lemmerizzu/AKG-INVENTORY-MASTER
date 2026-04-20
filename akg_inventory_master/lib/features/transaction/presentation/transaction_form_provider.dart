import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akg_inventory_master/features/transaction/domain/transaction_document.dart';
import 'package:akg_inventory_master/features/transaction/presentation/transaction_history_provider.dart';
import 'package:akg_inventory_master/features/customer/domain/customer.dart';
import 'package:akg_inventory_master/features/inventory/domain/item.dart';
import 'package:akg_inventory_master/features/inventory/presentation/item_master_provider.dart';
import 'package:akg_inventory_master/features/inventory/presentation/asset_provider.dart';
import 'package:akg_inventory_master/features/transaction/data/transaction_repository.dart';

// ── Mock Data (will be replaced by Supabase/SQLite later) ─────────────────

// Mock data for customers → customer_provider.dart
// Mock data for items → item_master_provider.dart (itemListProvider)


// ── Transaction Form State ────────────────────────────────────────────────

/// Represents a selected SKU and its scanned serial numbers (cylinders).
class TransactionLineState {
  final Item? selectedSku;
  final List<String> serialNumbers;
  final int manualQty;
  final int reservedQty;
  final String adminNote;

  const TransactionLineState({
    this.selectedSku,
    this.serialNumbers = const [],
    this.manualQty = 0,
    this.reservedQty = 0,
    this.adminNote = '',
  });

  int get qty => serialNumbers.isNotEmpty ? serialNumbers.length : manualQty;

  TransactionLineState copyWith({
    Item? selectedSku,
    List<String>? serialNumbers,
    int? manualQty,
    int? reservedQty,
    String? adminNote,
  }) {
    return TransactionLineState(
      selectedSku: selectedSku ?? this.selectedSku,
      serialNumbers: serialNumbers ?? this.serialNumbers,
      manualQty: manualQty ?? this.manualQty,
      reservedQty: reservedQty ?? this.reservedQty,
      adminNote: adminNote ?? this.adminNote,
    );
  }
}

class TransactionFormState {
  static const int maxRevisions = 3;

  final Customer? selectedCustomer;
  final MutationCode mutationCode;
  final InputMode inputMode;
  final DateTime transactionDate;
  final String sysDocNumber;
  final String shippingAddress;
  final List<TransactionLineState> lines;
  final int activeLineIndex;
  final bool isSidebarOpen;
  final bool isSaving;
  final bool isScannerEnabled;
  final String? savedMessage;
  final String? originalDocumentId;
  final bool isEditMode;
  final DocStatus originalStatus; // Added to track if we're editing a COMPLETED doc
  final String revisionNote; // Required for edits

  // Driver & Vehicle Info
  final String? driverName;
  final String? policeNumber;

  const TransactionFormState({
    this.selectedCustomer,
    this.mutationCode = MutationCode.outbound,
    this.inputMode = InputMode.bulk,
    required this.transactionDate,
    this.sysDocNumber = '',
    this.shippingAddress = '',
    this.lines = const [],
    this.activeLineIndex = -1,
    this.isSidebarOpen = false,
    this.isSaving = false,
    this.isScannerEnabled = false,
    this.savedMessage,
    this.originalDocumentId,
    this.isEditMode = false,
    this.originalStatus = DocStatus.draft,
    this.revisionNote = '',
    this.driverName,
    this.policeNumber,
  });

  TransactionFormState copyWith({
    Customer? selectedCustomer,
    MutationCode? mutationCode,
    InputMode? inputMode,
    DateTime? transactionDate,
    String? sysDocNumber,
    String? shippingAddress,
    List<TransactionLineState>? lines,
    int? activeLineIndex,
    bool? isSidebarOpen,
    bool? isSaving,
    bool? isScannerEnabled,
    String? savedMessage,
    String? originalDocumentId,
    bool? isEditMode,
    DocStatus? originalStatus,
    String? revisionNote,
    String? driverName,
    String? policeNumber,
  }) {
    return TransactionFormState(
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      mutationCode: mutationCode ?? this.mutationCode,
      inputMode: inputMode ?? this.inputMode,
      transactionDate: transactionDate ?? this.transactionDate,
      sysDocNumber: sysDocNumber ?? this.sysDocNumber,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      lines: lines ?? this.lines,
      activeLineIndex: activeLineIndex ?? this.activeLineIndex,
      isSidebarOpen: isSidebarOpen ?? this.isSidebarOpen,
      isSaving: isSaving ?? this.isSaving,
      isScannerEnabled: isScannerEnabled ?? this.isScannerEnabled,
      savedMessage: savedMessage,
      originalDocumentId: originalDocumentId ?? this.originalDocumentId,
      isEditMode: isEditMode ?? this.isEditMode,
      originalStatus: originalStatus ?? this.originalStatus,
      revisionNote: revisionNote ?? this.revisionNote,
      driverName: driverName ?? this.driverName,
      policeNumber: policeNumber ?? this.policeNumber,
    );
  }
}

/// Riverpod v3: Use Notifier.family for multi-window support
class TransactionFormNotifier extends FamilyNotifier<TransactionFormState, String> {
  @override
  TransactionFormState build(String arg) {
    return TransactionFormState(
      transactionDate: DateTime.now(),
      lines: const [],
      originalDocumentId: arg.startsWith('new-') ? null : arg,
      isEditMode: !arg.startsWith('new-'),
    );
  }

  void setRevisionNote(String note) {
    state = state.copyWith(revisionNote: note);
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

  void setDriverInfo(String name, String plate) {
    state = state.copyWith(driverName: name, policeNumber: plate);
  }

  void toggleScanner() {
    state = state.copyWith(isScannerEnabled: !state.isScannerEnabled);
    if (state.isScannerEnabled && !state.isSidebarOpen) {
      openSidebar();
    }
  }

  void openSidebar() {
    if (state.lines.isEmpty) {
      addLine();
    } else if (state.activeLineIndex == -1) {
      state = state.copyWith(activeLineIndex: state.lines.length - 1, isSidebarOpen: true);
    } else {
      state = state.copyWith(isSidebarOpen: true);
    }
  }

  void closeSidebar() {
    state = state.copyWith(isSidebarOpen: false);
  }

  // ── Barcode Scanner Logic ──

  void processBarcode(String barcode) {
    if (!state.isScannerEnabled) return;

    // 1. Lookup from real Asset Provider
    final assetNotifier = ref.read(assetListProvider.notifier);
    final asset = assetNotifier.getByBarcode(barcode);


    if (asset == null) {
      state = state.copyWith(savedMessage: '! Barcode [ $barcode ] tidak terdaftar');
      return;
    }

    final targetSkuId = asset.itemId;
    final targetSn = asset.serialNumber;

    // 2. Find or Add SKU Line
    final lines = [...state.lines];
    int lineIndex = lines.indexWhere((l) => l.selectedSku?.id == targetSkuId);

    if (lineIndex == -1) {
      // Auto-add new line for this SKU
      final items = ref.read(itemListProvider).value ?? [];
      final sku = items.firstWhere((i) => i.id == targetSkuId, orElse: () => Item(id: targetSkuId, itemCode: targetSkuId, name: targetSkuId, unit: 'Btl', basePrice: 0));
      
      final newLine = TransactionLineState(selectedSku: sku, serialNumbers: [targetSn]);
      state = state.copyWith(
        lines: [...state.lines, newLine], 
        activeLineIndex: state.lines.length,
        isSidebarOpen: true,
        savedMessage: '✓ New SKU & SN Added: $targetSn'
      );
      return;
    }

    // 3. Add Serial Number to the existing line
    toggleSerialNumber(lineIndex, targetSn);
    state = state.copyWith(
      activeLineIndex: lineIndex,
      isSidebarOpen: true,
      savedMessage: '✓ Scan Success: $targetSn ditambahkan'
    );
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

    newLines[lineIndex] = currentLine.copyWith(serialNumbers: updatedSerials, manualQty: updatedSerials.length);
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
    state = state.copyWith(
      lines: [...state.lines, const TransactionLineState()],
      activeLineIndex: state.lines.length,
      isSidebarOpen: true,
    );
  }

  void editLine(int index) {
    state = state.copyWith(
      activeLineIndex: index,
      isSidebarOpen: true,
    );
  }

  void removeLine(int index) {
    final newLines = [...state.lines];
    newLines.removeAt(index);
    int newActive = state.activeLineIndex;
    if (newActive >= newLines.length) {
      newActive = newLines.length - 1;
    }
    state = state.copyWith(lines: newLines, activeLineIndex: newActive);
  }

  void updateLineSku(int index, Item sku) {
    final newLines = [...state.lines];
    newLines[index] = newLines[index].copyWith(selectedSku: sku);
    state = state.copyWith(lines: newLines);
  }

  void updateManualQty(int index, int qty) {
    if (qty < 0) return;
    final newLines = [...state.lines];
    newLines[index] = newLines[index].copyWith(manualQty: qty);
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
      final updatedSerials = [...currentLine.serialNumbers, sn];
      newLines[lineIndex] = currentLine.copyWith(
        serialNumbers: updatedSerials,
        manualQty: updatedSerials.length,
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
    
    final validLines = state.lines.where((l) => l.selectedSku != null && (l.serialNumbers.isNotEmpty || l.manualQty > 0)).toList();
    if (validLines.isEmpty) {
      state = state.copyWith(savedMessage: 'Tambahkan minimal 1 Item SKU');
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

    final repo = ref.read(transactionRepositoryProvider);
    final isEdit = state.isEditMode && state.originalDocumentId != null;
    final docId = isEdit ? state.originalDocumentId! : DateTime.now().millisecondsSinceEpoch.toString();
    
    // Check Revision Limit if it's an edit of a completed document
    if (isEdit && state.originalStatus == DocStatus.completed) {
      final revCount = await repo.getRevisionCount(docId);
      if (revCount >= TransactionFormState.maxRevisions) {
        state = state.copyWith(
          isSaving: false,
          savedMessage: '! Limit revisi tercapai (${TransactionFormState.maxRevisions}/ ${TransactionFormState.maxRevisions}). Tidak bisa diedit lagi.',
        );
        return;
      }

      if (state.revisionNote.trim().isEmpty) {
        state = state.copyWith(
          isSaving: false,
          savedMessage: '! Catatan revisi wajib diisi untuk dokumen yang sudah COMPLETED',
        );
        return;
      }
    }

    final docNumber = state.sysDocNumber.trim().isEmpty
        ? _generateDocumentNumber()
        : state.sysDocNumber;

    String? auditNote;
    if (isEdit) {
      auditNote = state.originalStatus == DocStatus.completed 
        ? state.revisionNote 
        : 'Document updated (Draft)';
    }

    final newDoc = TransactionDocument(
      id: docId,
      sysDocNumber: docNumber,
      mutation: state.mutationCode,
      inputMode: state.inputMode,
      customerId: state.selectedCustomer!.id,
      transactionDate: state.transactionDate,
      shippingAddress: state.shippingAddress,
      status: actionStatus,
    );

    final List<InventoryLedgerEntry> ledgerLines = [];
    for (final line in validLines) {
      ledgerLines.add(InventoryLedgerEntry(
        id: '${docId}_${validLines.indexOf(line)}',
        documentId: docId,
        itemId: line.selectedSku?.id,
        cylinderBarcode: line.serialNumbers.isNotEmpty ? line.serialNumbers.join(',') : null,
        qty: line.qty,
      ));
    }

    try {
      await repo.saveTransaction(newDoc, ledgerLines, editNote: auditNote);
      
      // Refresh history list
      ref.read(transactionHistoryProvider.notifier).refresh();

      final totalQty = validLines.fold<int>(0, (sum, line) => sum + line.qty);
      state = state.copyWith(
        isSaving: false,
        savedMessage: 'Transaksi berhasil disimpan! ($totalQty tabung dari ${validLines.length} SKU)',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        savedMessage: 'Error saat menyimpan: $e',
      );
    }
  }

  void loadFromDocument(TransactionDocument doc, List<InventoryLedgerEntry> items, Customer customer) {
    // Map ledger items back to TransactionLineState
    // This requires looking up the Item domain model for each itemId.
    final allItems = ref.read(itemListProvider).value ?? [];
    
    final lines = items.map((line) {
      final sku = allItems.where((i) => i.id == line.itemId).firstOrNull;
      final sns = line.cylinderBarcode?.split(',') ?? [];
      return TransactionLineState(
        selectedSku: sku,
        serialNumbers: sns,
        manualQty: sns.isEmpty ? line.qty : sns.length,
      );
    }).toList();

    state = TransactionFormState(
      selectedCustomer: customer,
      mutationCode: doc.mutation,
      inputMode: doc.inputMode,
      transactionDate: doc.transactionDate,
      sysDocNumber: doc.sysDocNumber,
      shippingAddress: doc.shippingAddress,
      lines: lines,
      originalDocumentId: doc.id,
      isEditMode: true,
      originalStatus: doc.status,
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
    NotifierProvider.family<TransactionFormNotifier, TransactionFormState, String>(
  TransactionFormNotifier.new,
);
