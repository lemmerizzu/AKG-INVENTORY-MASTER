import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/transaction_document.dart';

// ── Mock Initial Data ──────────────────────────────────────────────────
final mockHistory = [
  TransactionDocument(
    id: 'doc-1',
    sysDocNumber: '1261553',
    customerId: 'Bengkel Las Bpk. Ari',
    mutation: MutationCode.other,
    transactionDate: DateTime.now().subtract(const Duration(days: 1)),
  ),
  TransactionDocument(
    id: 'doc-2',
    sysDocNumber: '1261552',
    customerId: 'Bpk. David',
    mutation: MutationCode.inbound,
    transactionDate: DateTime.now().subtract(const Duration(days: 1)),
  ),
  TransactionDocument(
    id: 'doc-3',
    sysDocNumber: '0426153103',
    customerId: 'Flashtech Machinery',
    mutation: MutationCode.outbound,
    transactionDate: DateTime.now().subtract(const Duration(days: 2)),
  ),
  TransactionDocument(
    id: 'doc-4',
    sysDocNumber: '0426293102',
    customerId: 'Bpk. Alvin (LB Group)',
    mutation: MutationCode.outbound,
    transactionDate: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

// ── Notifier ──────────────────────────────────────────────────────────

class TransactionHistoryNotifier extends Notifier<List<TransactionDocument>> {
  @override
  List<TransactionDocument> build() {
    return mockHistory; // Replace with Supabase fetch later
  }

  void addTransaction(TransactionDocument doc) {
    state = [doc, ...state];
  }
}

final transactionHistoryProvider =
    NotifierProvider<TransactionHistoryNotifier, List<TransactionDocument>>(
  TransactionHistoryNotifier.new,
);
