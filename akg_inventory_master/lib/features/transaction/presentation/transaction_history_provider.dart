import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akg_inventory_master/features/transaction/domain/transaction_document.dart';
import 'package:akg_inventory_master/features/transaction/domain/audit_log.dart';
import 'package:akg_inventory_master/features/transaction/data/transaction_repository.dart';

// ── Selection State ──────────────────────────────────────────────────

/// Provides the ID of the currently selected document in the Log.
final selectedTransactionIdProvider = NotifierProvider<SelectedTransactionIdNotifier, String?>(SelectedTransactionIdNotifier.new);

class SelectedTransactionIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

// ── Document List Provider ───────────────────────────────────────────

class TransactionHistoryNotifier extends AsyncNotifier<List<TransactionDocument>> {
  @override
  Future<List<TransactionDocument>> build() async {
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.fetchTransactions();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(transactionRepositoryProvider).fetchTransactions());
  }

  void addLocal(TransactionDocument doc) {
    state.whenData((list) {
      state = AsyncValue.data([doc, ...list]);
    });
  }
}

final transactionHistoryProvider =
    AsyncNotifierProvider<TransactionHistoryNotifier, List<TransactionDocument>>(
  TransactionHistoryNotifier.new,
);

// ── Document Detail Provider ──────────────────────────────────────────

class TransactionDetailState {
  final List<InventoryLedgerEntry> items;
  final List<AuditLog> auditLogs;
  final bool hasEditedIcon;

  TransactionDetailState({
    required this.items,
    required this.auditLogs,
    this.hasEditedIcon = false,
  });
}

final transactionDetailProvider = FutureProvider.family<TransactionDetailState, String>((ref, docId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  
  final results = await Future.wait([
    repo.fetchLedgerEntries(docId),
    repo.fetchAuditLogs(docId),
    repo.hasBeenEdited(docId),
  ]);

  return TransactionDetailState(
    items: results[0] as List<InventoryLedgerEntry>,
    auditLogs: results[1] as List<AuditLog>,
    hasEditedIcon: results[2] as bool,
  );
});

/// Helper to check "Edited" status efficiently for the list view
final docHasEditedIconProvider = FutureProvider.family<bool, String>((ref, docId) async {
  return ref.watch(transactionRepositoryProvider).hasBeenEdited(docId);
});
