import 'site.dart';

class TroubleTicket {
  final int id;
  final String ticketNumber;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final Site? site;
  final Engineer? engineer;
  final BudgetRequest? budgetRequest;
  final String? fotoBefore;
  final String? fotoAfter;
  final String? catatanEngineer;
  final String? assignedAt;
  final String? startedAt;
  final String? completedAt;
  final String? workStartTime;
  final String? workEndTime;
  final String? createdAt;
  final String? updatedAt;

  TroubleTicket({
    required this.id,
    required this.ticketNumber,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.site,
    this.engineer,
    this.budgetRequest,
    this.fotoBefore,
    this.fotoAfter,
    this.catatanEngineer,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.workStartTime,
    this.workEndTime,
    this.createdAt,
    this.updatedAt,
  });

  factory TroubleTicket.fromJson(Map<String, dynamic> json) {
    return TroubleTicket(
      id: json['id'],
      ticketNumber: json['ticket_number'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      site: json['site'] != null ? Site.fromJson(json['site']) : null,
      engineer: json['engineer'] != null ? Engineer.fromJson(json['engineer']) : null,
      budgetRequest: json['budget_request'] != null ? BudgetRequest.fromJson(json['budget_request']) : null,
      fotoBefore: json['foto_before'],
      fotoAfter: json['foto_after'],
      catatanEngineer: json['catatan_engineer'],
      assignedAt: json['assigned_at'],
      startedAt: json['started_at'],
      completedAt: json['completed_at'],
      workStartTime: json['work_start_time'],
      workEndTime: json['work_end_time'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Helper method untuk status badge color
  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'critical':
        return 'red';
      case 'high':
        return 'orange';
      case 'medium':
        return 'yellow';
      case 'low':
        return 'green';
      default:
        return 'gray';
    }
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'green';
      case 'in_progress':
        return 'blue';
      case 'assigned':
        return 'orange';
      case 'pending':
        return 'yellow';
      case 'cancelled':
        return 'red';
      default:
        return 'gray';
    }
  }
}

class BudgetRequest {
  final int id;
  final String requestNumber;
  final double? estimatedCost;
  final String status;

  BudgetRequest({
    required this.id,
    required this.requestNumber,
    this.estimatedCost,
    required this.status,
  });

  factory BudgetRequest.fromJson(Map<String, dynamic> json) {
    return BudgetRequest(
      id: json['id'],
      requestNumber: json['request_number'],
      estimatedCost: json['estimated_cost'] != null ? double.tryParse(json['estimated_cost'].toString()) : null,
      status: json['status'],
    );
  }
}
