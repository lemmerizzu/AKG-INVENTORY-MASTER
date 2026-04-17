enum PrintStatus {
  pending('PENDING'),
  printing('PRINTING'),
  completed('COMPLETED'),
  failed('FAILED');

  final String value;
  const PrintStatus(this.value);

  factory PrintStatus.fromValue(String value) {
    return PrintStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => PrintStatus.pending,
    );
  }
}

class PrintJob {
  final String id;
  final String documentType;
  final String? referenceId;
  final String filePath;
  final PrintStatus status;
  final String? targetPrinter;
  final String? requestedBy;
  final String? errorMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PrintJob({
    required this.id,
    required this.documentType,
    this.referenceId,
    required this.filePath,
    this.status = PrintStatus.pending,
    this.targetPrinter,
    this.requestedBy,
    this.errorMessage,
    this.createdAt,
    this.updatedAt,
  });

  PrintJob copyWith({
    String? id,
    String? documentType,
    String? referenceId,
    String? filePath,
    PrintStatus? status,
    String? targetPrinter,
    String? requestedBy,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrintJob(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      referenceId: referenceId ?? this.referenceId,
      filePath: filePath ?? this.filePath,
      status: status ?? this.status,
      targetPrinter: targetPrinter ?? this.targetPrinter,
      requestedBy: requestedBy ?? this.requestedBy,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_type': documentType,
      if (referenceId != null) 'reference_id': referenceId,
      'file_path': filePath,
      'status': status.value,
      if (targetPrinter != null) 'target_printer': targetPrinter,
      if (requestedBy != null) 'requested_by': requestedBy,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory PrintJob.fromJson(Map<String, dynamic> json) {
    return PrintJob(
      id: json['id'] as String,
      documentType: json['document_type'] as String,
      referenceId: json['reference_id'] as String?,
      filePath: json['file_path'] as String,
      status: PrintStatus.fromValue(json['status'] as String? ?? 'PENDING'),
      targetPrinter: json['target_printer'] as String?,
      requestedBy: json['requested_by'] as String?,
      errorMessage: json['error_message'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PrintJob &&
        other.id == id &&
        other.documentType == documentType &&
        other.referenceId == referenceId &&
        other.filePath == filePath &&
        other.status == status &&
        other.targetPrinter == targetPrinter &&
        other.requestedBy == requestedBy &&
        other.errorMessage == errorMessage &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        documentType.hashCode ^
        referenceId.hashCode ^
        filePath.hashCode ^
        status.hashCode ^
        targetPrinter.hashCode ^
        requestedBy.hashCode ^
        errorMessage.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
