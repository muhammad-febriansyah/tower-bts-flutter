class BudgetRequestDetail {
  final int id;
  final String requestNumber;
  final TroubleTicketInfo? troubleTicket;
  final String? specification;
  final List<String>? photos;
  final double? estimatedCost;
  final String status;
  final String? notes;
  final Requester? requester;
  final Reviewer? reviewer;
  final BudgetTransfer? budgetTransfer;
  final String? createdAt;
  final String? updatedAt;
  final String? reviewedAt;

  BudgetRequestDetail({
    required this.id,
    required this.requestNumber,
    this.troubleTicket,
    this.specification,
    this.photos,
    this.estimatedCost,
    required this.status,
    this.notes,
    this.requester,
    this.reviewer,
    this.budgetTransfer,
    this.createdAt,
    this.updatedAt,
    this.reviewedAt,
  });

  factory BudgetRequestDetail.fromJson(Map<String, dynamic> json) {
    return BudgetRequestDetail(
      id: json['id'],
      requestNumber: json['request_number'],
      troubleTicket: json['trouble_ticket'] != null ? TroubleTicketInfo.fromJson(json['trouble_ticket']) : null,
      specification: json['specification'] ?? json['detil_spesifikasi'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      estimatedCost: json['estimated_cost'] != null ? double.tryParse(json['estimated_cost'].toString()) : null,
      status: json['status'],
      notes: json['notes'],
      requester: json['requester'] != null ? Requester.fromJson(json['requester']) : null,
      reviewer: json['reviewer'] != null ? Reviewer.fromJson(json['reviewer']) : null,
      budgetTransfer: json['budget_transfer'] != null ? BudgetTransfer.fromJson(json['budget_transfer']) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      reviewedAt: json['reviewed_at'],
    );
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'green';
      case 'transferred':
        return 'blue';
      case 'pending':
        return 'orange';
      case 'rejected':
        return 'red';
      default:
        return 'gray';
    }
  }
}

class TroubleTicketInfo {
  final int id;
  final String ticketNumber;
  final String title;
  final SiteInfo? site;

  TroubleTicketInfo({
    required this.id,
    required this.ticketNumber,
    required this.title,
    this.site,
  });

  factory TroubleTicketInfo.fromJson(Map<String, dynamic> json) {
    return TroubleTicketInfo(
      id: json['id'],
      ticketNumber: json['ticket_number'],
      title: json['title'],
      site: json['site'] != null ? SiteInfo.fromJson(json['site']) : null,
    );
  }
}

class SiteInfo {
  final int id;
  final String siteId;
  final String name;
  final String? area;

  SiteInfo({
    required this.id,
    required this.siteId,
    required this.name,
    this.area,
  });

  factory SiteInfo.fromJson(Map<String, dynamic> json) {
    return SiteInfo(
      id: json['id'],
      siteId: json['site_id'],
      name: json['name'] ?? json['site_name'],
      area: json['area'],
    );
  }
}

class Requester {
  final int id;
  final String name;

  Requester({
    required this.id,
    required this.name,
  });

  factory Requester.fromJson(Map<String, dynamic> json) {
    return Requester(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Reviewer {
  final int id;
  final String name;
  final String? reviewedAt;

  Reviewer({
    required this.id,
    required this.name,
    this.reviewedAt,
  });

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(
      id: json['id'],
      name: json['name'],
      reviewedAt: json['reviewed_at'],
    );
  }
}

class BudgetTransfer {
  final int id;
  final double? amount;
  final String? transferredAt;

  BudgetTransfer({
    required this.id,
    this.amount,
    this.transferredAt,
  });

  factory BudgetTransfer.fromJson(Map<String, dynamic> json) {
    return BudgetTransfer(
      id: json['id'],
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
      transferredAt: json['transferred_at'],
    );
  }
}
