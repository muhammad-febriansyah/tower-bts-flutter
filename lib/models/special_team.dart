class SpecialTeam {
  final int id;
  final String teamName;
  final String teamType; // civil, electrical, etc.
  final String? description;
  final int memberCount;
  final String? teamLeader;
  final String? contactNumber;
  final String status; // active, inactive
  final String? createdAt;
  final String? updatedAt;

  SpecialTeam({
    required this.id,
    required this.teamName,
    required this.teamType,
    this.description,
    required this.memberCount,
    this.teamLeader,
    this.contactNumber,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory SpecialTeam.fromJson(Map<String, dynamic> json) {
    return SpecialTeam(
      id: json['id'] ?? 0,
      teamName: json['team_name'] ?? '',
      teamType: json['team_type'] ?? '',
      description: json['description'],
      memberCount: json['member_count'] ?? 0,
      teamLeader: json['team_leader'],
      contactNumber: json['contact_number'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_name': teamName,
      'team_type': teamType,
      'description': description,
      'member_count': memberCount,
      'team_leader': teamLeader,
      'contact_number': contactNumber,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String getTeamTypeLabel() {
    switch (teamType.toLowerCase()) {
      case 'civil':
        return 'Sipil';
      case 'electrical':
        return 'Listrik';
      case 'mechanical':
        return 'Mekanik';
      default:
        return teamType;
    }
  }

  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      default:
        return status;
    }
  }
}

class SpecialTeamAssignment {
  final int id;
  final String assignmentNumber;
  final int specialTeamId;
  final String? teamName;
  final int troubleTicketId;
  final String? ticketNumber;
  final int assignedBy;
  final String? assignedByName;
  final String scopeOfWork;
  final String? estimatedBudget;
  final String status; // assigned, in_progress, completed, cancelled
  final String? notes;
  final String? completionNotes;
  final String? createdAt;
  final String? updatedAt;
  final String? completedAt;

  SpecialTeamAssignment({
    required this.id,
    required this.assignmentNumber,
    required this.specialTeamId,
    this.teamName,
    required this.troubleTicketId,
    this.ticketNumber,
    required this.assignedBy,
    this.assignedByName,
    required this.scopeOfWork,
    this.estimatedBudget,
    required this.status,
    this.notes,
    this.completionNotes,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory SpecialTeamAssignment.fromJson(Map<String, dynamic> json) {
    return SpecialTeamAssignment(
      id: json['id'] ?? 0,
      assignmentNumber: json['assignment_number'] ?? '',
      specialTeamId: json['special_team_id'] ?? 0,
      teamName: json['team_name'] ?? json['special_team']?['team_name'],
      troubleTicketId: json['trouble_ticket_id'] ?? 0,
      ticketNumber: json['ticket_number'] ?? json['trouble_ticket']?['ticket_number'],
      assignedBy: json['assigned_by'] ?? 0,
      assignedByName: json['assigned_by_name'] ?? json['assigned_by_user']?['name'],
      scopeOfWork: json['scope_of_work'] ?? '',
      estimatedBudget: json['estimated_budget']?.toString(),
      status: json['status'] ?? 'assigned',
      notes: json['notes'],
      completionNotes: json['completion_notes'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      completedAt: json['completed_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_number': assignmentNumber,
      'special_team_id': specialTeamId,
      'trouble_ticket_id': troubleTicketId,
      'assigned_by': assignedBy,
      'scope_of_work': scopeOfWork,
      'estimated_budget': estimatedBudget,
      'status': status,
      'notes': notes,
      'completion_notes': completionNotes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'completed_at': completedAt,
    };
  }

  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'assigned':
        return 'Ditugaskan';
      case 'in_progress':
        return 'Dalam Proses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
