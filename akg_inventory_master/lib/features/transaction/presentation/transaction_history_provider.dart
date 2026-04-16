import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/transaction_document.dart';

/// Provider to store the history of transactions input in the current session.
class TransactionHistoryNotifier extends Notifier<List<TransactionDocument>> {
  @override
  List<TransactionDocument> build() {
    // Initial empty list of logs
    return [];
  }

  /// Adds a new transaction to the history.
  void addTransaction(TransactionDocument doc) {
    // Insert at front so latest is on top
    state = [doc, ...state];
  }
}

final transactionHistoryProvider =
    NotifierProvider<TransactionHistoryNotifier, List<TransactionDocument>>(
  TransactionHistoryNotifier.new,
);
