import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akg_inventory_master/features/transaction/domain/transaction_document.dart';
import 'package:akg_inventory_master/features/transaction/domain/audit_log.dart';
import 'package:akg_inventory_master/features/transaction/data/transaction_repository.dart';

// ── Phase 2: Filter State ─────────────────────────────────────────────────────

class TransactionFilter {
  final MutationCode? mutation;
  final DateTimeRange? dateRange;
  final String searchQuery;

  const TransactionFilter({
    this.mutation,
    this.dateRange,
    this.searchQuery = '',
  });

  TransactionFilter copyWith({
    Object? mutation = _sentinel,
    Object? dateRange = _sentinel,
    String? searchQuery,
  }) =>
      TransactionFilter(
        mutation: mutation == _sentinel ? this.mutation : mutation as MutationCode?,
        dateRange: dateRange == _sentinel ? this.dateRange : dateRange as DateTimeRange?,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  static const _sentinel = Object();

  bool get hasActiveFilter =>
      mutation != null || dateRange != null || searchQuery.isNotEmpty;
}

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void setMutation(MutationCode? code) =>
      state = state.copyWith(mutation: code);

  void setDateRange(DateTimeRange? range) =>
      state = state.copyWith(dateRange: range);

  void setSearch(String query) =>
      state = state.copyWith(searchQuery: query);

  void clearAll() => state = const TransactionFilter();
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
        TransactionFilterNotifier.new);

// ── Selection State ───────────────────────────────────────────────────────────

/// Provides the ID of the currently selected document in the Log.
final selectedTransactionIdProvider =
    NotifierProvider<SelectedTransactionIdNotifier, String?>(
        SelectedTransactionIdNotifier.new);

class SelectedTransactionIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
  void clear() => state = null;

  /// Navigate to the next document in the filtered list
  void next(List<TransactionDocument> documents) {
    if (documents.isEmpty || state == null) return;
    final index = documents.indexWhere((d) => d.id == state);
    if (index == -1) return;
    
    // Cycle to first if at end, or just go to next
    final nextIndex = (index + 1) % documents.length;
    state = documents[nextIndex].id;
  }

  /// Navigate to the previous document in the filtered list
  void previous(List<TransactionDocument> documents) {
    if (documents.isEmpty || state == null) return;
    final index = documents.indexWhere((d) => d.id == state);
    if (index == -1) return;
    
    // Cycle to last if at start, or just go to previous
    final prevIndex = (index - 1 + documents.length) % documents.length;
    state = documents[prevIndex].id;
  }
}

// ── Document List Provider ────────────────────────────────────────────────────

class TransactionHistoryNotifier
    extends AsyncNotifier<List<TransactionDocument>> {
  @override
  Future<List<TransactionDocument>> build() async {
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.fetchTransactions();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(transactionRepositoryProvider).fetchTransactions());
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

/// Phase 2: Derived provider applying filter on top of the full list
final filteredTransactionProvider =
    Provider<AsyncValue<List<TransactionDocument>>>((ref) {
  final allAsync = ref.watch(transactionHistoryProvider);
  final filter = ref.watch(transactionFilterProvider);

  return allAsync.whenData((all) {
    var result = all;

    // Filter by mutation
    if (filter.mutation != null) {
      result = result.where((d) => d.mutation == filter.mutation).toList();
    }

    // Filter by date range
    if (filter.dateRange != null) {
      final start = filter.dateRange!.start;
      final end = filter.dateRange!.end
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));
      result = result
          .where((d) =>
              d.transactionDate.isAfter(start) &&
              d.transactionDate.isBefore(end))
          .toList();
    }

    // Filter by search (on sys_doc_number or customer name — customer name
    // resolution done in UI layer since we don't have customer names here)
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      result = result
          .where((d) => d.sysDocNumber.toLowerCase().contains(q))
          .toList();
    }

    return result;
  });
});

// ── Document Detail Provider ──────────────────────────────────────────────────

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

final transactionDetailProvider =
    FutureProvider.family<TransactionDetailState, String>((ref, docId) async {
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
final docHasEditedIconProvider =
    FutureProvider.family<bool, String>((ref, docId) async {
  return ref.watch(transactionRepositoryProvider).hasBeenEdited(docId);
});
