import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/inventory_audit.dart';
import '../data/inventory_audit_repository.dart';

final inventoryAuditRepositoryProvider = Provider((ref) => InventoryAuditRepository());

// --- State Class for Detail Notifier ---
class InventoryAuditDetailState {
  final InventoryAudit? audit;
  final List<InventoryAuditLine> lines;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const InventoryAuditDetailState({
    this.audit,
    this.lines = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  InventoryAuditDetailState copyWith({
    InventoryAudit? audit,
    List<InventoryAuditLine>? lines,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) =>
      InventoryAuditDetailState(
        audit: audit ?? this.audit,
        lines: lines ?? this.lines,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: error,
      );
}

// --- List Provider ---
class InventoryAuditListNotifier extends AsyncNotifier<List<InventoryAudit>> {
  @override
  Future<List<InventoryAudit>> build() async {
    return ref.read(inventoryAuditRepositoryProvider).fetchAudits();
  }

  void refresh() {
    state = const AsyncValue.loading();
    state = AsyncValue.data([]); // Trigger reload
    ref.invalidateSelf();
  }
}

final inventoryAuditListProvider =
    AsyncNotifierProvider<InventoryAuditListNotifier, List<InventoryAudit>>(
  InventoryAuditListNotifier.new,
);

// --- Detail Provider (Family) ---
class InventoryAuditDetailNotifier
    extends FamilyNotifier<InventoryAuditDetailState, String> {
  @override
  InventoryAuditDetailState build(String arg) {
    _loadAudit();
    return const InventoryAuditDetailState(isLoading: true);
  }

  Future<void> _loadAudit() async {
    final repo = ref.read(inventoryAuditRepositoryProvider);
    
    if (arg.startsWith('new-')) {
      // Initialize new audit session
      final auditId = DateTime.now().millisecondsSinceEpoch.toString();
      final auditNumber = 'AUD-${DateTime.now().year}${(DateTime.now().month).toString().padLeft(2, '0')}${(DateTime.now().day).toString().padLeft(2, '0')}-${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}';
      
      final audit = InventoryAudit(
        id: auditId,
        auditNumber: auditNumber,
        auditDate: DateTime.now(),
        status: AuditStatus.draft,
      );

      // We don't save to DB immediately, but wait for user interaction or snapshot trigger
      // Actually, snapshotting should happen at start.
      try {
        await repo.createAudit(audit);
        final lines = await repo.fetchAuditLines(auditId);
        state = InventoryAuditDetailState(audit: audit, lines: lines, isLoading: false);
      } catch (e) {
        state = InventoryAuditDetailState(isLoading: false, error: e.toString());
      }
    } else {
      // Load existing audit
      try {
        final audits = await repo.fetchAudits();
        final audit = audits.firstWhere((a) => a.id == arg);
        final lines = await repo.fetchAuditLines(arg);
        state = InventoryAuditDetailState(audit: audit, lines: lines, isLoading: false);
      } catch (e) {
        state = InventoryAuditDetailState(isLoading: false, error: e.toString());
      }
    }
  }

  void updatePhysicalQty(int lineIndex, int qty) {
    if (state.audit?.status == AuditStatus.completed) return;
    
    final newLines = [...state.lines];
    newLines[lineIndex] = newLines[lineIndex].copyWith(physicalQty: qty);
    state = state.copyWith(lines: newLines);
  }

  void updateLineNote(int lineIndex, String note) {
    if (state.audit?.status == AuditStatus.completed) return;

    final newLines = [...state.lines];
    newLines[lineIndex] = newLines[lineIndex].copyWith(note: note);
    state = state.copyWith(lines: newLines);
  }

  Future<void> saveDraft() async {
    if (state.audit == null || state.isSaving) return;
    state = state.copyWith(isSaving: true);
    
    try {
      final repo = ref.read(inventoryAuditRepositoryProvider);
      await repo.saveAudit(state.audit!);
      for (var line in state.lines) {
        await repo.updateAuditLine(line);
      }
      state = state.copyWith(isSaving: false);
      ref.read(inventoryAuditListProvider.notifier).refresh();
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> completeAudit() async {
    if (state.audit == null || state.isSaving) return;
    state = state.copyWith(isSaving: true);

    try {
      final repo = ref.read(inventoryAuditRepositoryProvider);
      await repo.completeAudit(state.audit!.id, state.lines);
      
      final updatedAudit = state.audit!.copyWith(status: AuditStatus.completed);
      state = state.copyWith(audit: updatedAudit, isSaving: false);
      
      ref.read(inventoryAuditListProvider.notifier).refresh();
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }
}

final inventoryAuditDetailProvider =
    NotifierProvider.family<InventoryAuditDetailNotifier, InventoryAuditDetailState, String>(
  InventoryAuditDetailNotifier.new,
);
