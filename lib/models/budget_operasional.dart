class BudgetOperasional {
  final int id;
  final String transferNumber;
  final int budgetRequestId;
  final String? requestNumber;
  final int engineerId;
  final String? engineerName;
  final int transferredBy;
  final String? transferredByName;
  final String amount;
  final String? notes;
  final String status; // received, realized, partial
  final String? createdAt;
  final String? updatedAt;
  final String? realizedAmount;
  final String? remainingAmount;

  BudgetOperasional({
    required this.id,
    required this.transferNumber,
    required this.budgetRequestId,
    this.requestNumber,
    required this.engineerId,
    this.engineerName,
    required this.transferredBy,
    this.transferredByName,
    required this.amount,
    this.notes,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.realizedAmount,
    this.remainingAmount,
  });

  factory BudgetOperasional.fromJson(Map<String, dynamic> json) {
    return BudgetOperasional(
      id: json['id'] ?? 0,
      transferNumber: json['transfer_number'] ?? '',
      budgetRequestId: json['budget_request_id'] ?? 0,
      requestNumber: json['request_number'] ?? json['budget_request']?['request_number'],
      engineerId: json['engineer_id'] ?? 0,
      engineerName: json['engineer_name'] ?? json['engineer']?['name'],
      transferredBy: json['transferred_by'] ?? 0,
      transferredByName: json['transferred_by_name'] ?? json['transferred_by_user']?['name'],
      amount: json['amount']?.toString() ?? '0',
      notes: json['notes'],
      status: json['status'] ?? 'received',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      realizedAmount: json['realized_amount']?.toString() ?? '0',
      remainingAmount: json['remaining_amount']?.toString() ?? json['amount']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transfer_number': transferNumber,
      'budget_request_id': budgetRequestId,
      'engineer_id': engineerId,
      'transferred_by': transferredBy,
      'amount': amount,
      'notes': notes,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'realized_amount': realizedAmount,
      'remaining_amount': remainingAmount,
    };
  }

  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'received':
        return 'Diterima';
      case 'realized':
        return 'Direalisasi';
      case 'partial':
        return 'Sebagian';
      default:
        return status;
    }
  }
}
