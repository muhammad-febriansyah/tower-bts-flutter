class RequestCorrMo {
  final int id;
  final String requestNumber;
  final int troubleTicketId;
  final String category;
  final String ticketType;
  final String? description;
  final String? photoUrl;
  final String status;
  final TroubleTicketInfo? troubleTicket;
  final Creator? creator;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime createdAt;

  RequestCorrMo({
    required this.id,
    required this.requestNumber,
    required this.troubleTicketId,
    required this.category,
    required this.ticketType,
    this.description,
    this.photoUrl,
    required this.status,
    this.troubleTicket,
    this.creator,
    this.approvedAt,
    this.rejectedAt,
    required this.createdAt,
  });

  factory RequestCorrMo.fromJson(Map<String, dynamic> json) {
    return RequestCorrMo(
      id: json['id'],
      requestNumber: json['request_number'],
      troubleTicketId: json['trouble_ticket_id'] ?? json['trouble_ticket']?['id'] ?? 0,
      category: json['category'],
      ticketType: json['ticket_type'],
      description: json['description'],
      photoUrl: json['photo_url'],
      status: json['status'],
      troubleTicket: json['trouble_ticket'] != null
          ? TroubleTicketInfo.fromJson(json['trouble_ticket'])
          : null,
      creator: json['creator'] != null
          ? Creator.fromJson(json['creator'])
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_number': requestNumber,
      'trouble_ticket_id': troubleTicketId,
      'category': category,
      'ticket_type': ticketType,
      'description': description,
      'photo_url': photoUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper methods
  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isCompleted => status.toLowerCase() == 'completed';
}

class TroubleTicketInfo {
  final int id;
  final String ticketNumber;
  final String title;
  final String? description;
  final SiteInfo? site;

  TroubleTicketInfo({
    required this.id,
    required this.ticketNumber,
    required this.title,
    this.description,
    this.site,
  });

  factory TroubleTicketInfo.fromJson(Map<String, dynamic> json) {
    return TroubleTicketInfo(
      id: json['id'],
      ticketNumber: json['ticket_number'],
      title: json['title'] ?? json['judul_masalah'] ?? '',
      description: json['description'] ?? json['deskripsi_masalah'],
      site: json['site'] != null ? SiteInfo.fromJson(json['site']) : null,
    );
  }
}

class SiteInfo {
  final int id;
  final String siteId;
  final String siteName;

  SiteInfo({
    required this.id,
    required this.siteId,
    required this.siteName,
  });

  factory SiteInfo.fromJson(Map<String, dynamic> json) {
    return SiteInfo(
      id: json['id'],
      siteId: json['site_id'],
      siteName: json['site_name'],
    );
  }
}

class Creator {
  final int id;
  final String name;
  final String? email;
  final String? phone;

  Creator({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

// Categories for Request Corr MO
class RequestCorrMoCategory {
  static const String csr = 'CSR';
  static const String corrective = 'Corrective';
  static const String peneranganProblem = 'Penerangan Problem';

  static List<String> get all => [csr, corrective, peneranganProblem];
}

// Ticket Types for Request Corr MO
class RequestCorrMoTicketType {
  static const String csrLebihDari40Jt = 'CSR Lebih dari 40 Jt';
  static const String halaman = 'Halaman';

  static List<String> get all => [csrLebihDari40Jt, halaman];
}
