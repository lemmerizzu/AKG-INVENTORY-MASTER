class AuditLog {
  final String id;
  final String documentId;
  final String action; // CREATE, EDIT, PRINT, VOID
  final String? note;   // Detailed changes like "Address changed from A to B"
  final String? userId; // For future auth integration
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    required this.documentId,
    required this.action,
    this.note,
    this.userId,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
        id: json['id'] as String,
        documentId: json['document_id'] as String,
        action: json['action'] as String,
        note: json['note'] as String?,
        userId: json['user_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'document_id': documentId,
        'action': action,
        'note': note,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
      };
}
