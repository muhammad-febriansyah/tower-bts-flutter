class MaintenanceOrder {
  final int id;
  final String orderNumber;
  final String siteId;
  final String siteName;
  final String? tenantName;
  final String status;
  final String geofencingStatus;
  final DateTime startDate;
  final DateTime endDate;
  final Engineer? engineer;
  final Site? site;
  final String? workStartTime;
  final String? workEndTime;
  final double? distanceFromSite;
  final String? notes;
  final int sowItemsTotal;
  final int sowItemsCompleted;
  final int evidencesCount;
  final List<MaintenanceSowItem>? sowItems;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  MaintenanceOrder({
    required this.id,
    required this.orderNumber,
    required this.siteId,
    required this.siteName,
    this.tenantName,
    required this.status,
    required this.geofencingStatus,
    required this.startDate,
    required this.endDate,
    this.engineer,
    this.site,
    this.workStartTime,
    this.workEndTime,
    this.distanceFromSite,
    this.notes,
    required this.sowItemsTotal,
    required this.sowItemsCompleted,
    required this.evidencesCount,
    this.sowItems,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
  });

  factory MaintenanceOrder.fromJson(Map<String, dynamic> json) {
    return MaintenanceOrder(
      id: json['id'],
      orderNumber: json['order_number'],
      siteId: json['site_id'] ?? json['site']?['site_id'] ?? '',
      siteName: json['site_name'] ?? json['site']?['site_name'] ?? '',
      tenantName: json['tenant_name'],
      status: json['status'],
      geofencingStatus: json['geofencing_status'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      engineer: json['engineer'] != null ? Engineer.fromJson(json['engineer']) : null,
      site: json['site'] != null ? Site.fromJson(json['site']) : null,
      workStartTime: json['work_start_time'],
      workEndTime: json['work_end_time'],
      distanceFromSite: json['distance_from_site'] != null ? double.parse(json['distance_from_site'].toString()) : null,
      notes: json['notes'],
      sowItemsTotal: json['sow_items_total'] ?? json['sow_items']?.length ?? 0,
      sowItemsCompleted: json['sow_items_completed'] ?? 0,
      evidencesCount: json['evidences_count'] ?? 0,
      sowItems: json['sow_items'] != null
          ? (json['sow_items'] as List).map((item) => MaintenanceSowItem.fromJson(item)).toList()
          : null,
      assignedAt: json['assigned_at'] != null ? DateTime.parse(json['assigned_at']) : null,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'site_id': siteId,
      'site_name': siteName,
      'tenant_name': tenantName,
      'status': status,
      'geofencing_status': geofencingStatus,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'work_start_time': workStartTime,
      'work_end_time': workEndTime,
      'distance_from_site': distanceFromSite,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper methods
  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'done':
        return 'Done';
      default:
        return status;
    }
  }

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isDone => status.toLowerCase() == 'done';
  bool get isGeofencingInactive => geofencingStatus.toLowerCase() == 'inactive';

  double get completionPercentage {
    if (sowItemsTotal == 0) return 0;
    return (sowItemsCompleted / sowItemsTotal) * 100;
  }
}

class MaintenanceSowItem {
  final int id;
  final int maintenanceOrderId;
  final String category;
  final String itemCode;
  final String itemName;
  final String? itemIcon;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<MaintenanceEvidence>? evidences;

  MaintenanceSowItem({
    required this.id,
    required this.maintenanceOrderId,
    required this.category,
    required this.itemCode,
    required this.itemName,
    this.itemIcon,
    required this.isCompleted,
    this.completedAt,
    this.evidences,
  });

  factory MaintenanceSowItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceSowItem(
      id: json['id'],
      maintenanceOrderId: json['maintenance_order_id'],
      category: json['category'],
      itemCode: json['item_code'],
      itemName: json['item_name'],
      itemIcon: json['item_icon'],
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      evidences: json['evidences'] != null
          ? (json['evidences'] as List).map((e) => MaintenanceEvidence.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maintenance_order_id': maintenanceOrderId,
      'category': category,
      'item_code': itemCode,
      'item_name': itemName,
      'item_icon': itemIcon,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  String getCategoryLabel() {
    switch (category) {
      case 'mo_site':
        return 'MO Site';
      case 'mo_tenant':
        return 'MO Tenant';
      default:
        return category;
    }
  }
}

class MaintenanceEvidence {
  final int id;
  final int maintenanceOrderId;
  final int sowItemId;
  final String evidenceType;
  final String fileUrl;
  final String fileType;
  final bool isDraft;
  final DateTime? syncedAt;
  final String? description;

  MaintenanceEvidence({
    required this.id,
    required this.maintenanceOrderId,
    required this.sowItemId,
    required this.evidenceType,
    required this.fileUrl,
    required this.fileType,
    required this.isDraft,
    this.syncedAt,
    this.description,
  });

  factory MaintenanceEvidence.fromJson(Map<String, dynamic> json) {
    return MaintenanceEvidence(
      id: json['id'],
      maintenanceOrderId: json['maintenance_order_id'],
      sowItemId: json['sow_item_id'],
      evidenceType: json['evidence_type'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      isDraft: json['is_draft'] ?? false,
      syncedAt: json['synced_at'] != null ? DateTime.parse(json['synced_at']) : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maintenance_order_id': maintenanceOrderId,
      'sow_item_id': sowItemId,
      'evidence_type': evidenceType,
      'file_url': fileUrl,
      'file_type': fileType,
      'is_draft': isDraft,
      'synced_at': syncedAt?.toIso8601String(),
      'description': description,
    };
  }
}

// Helper classes for nested data
class Engineer {
  final int id;
  final String name;
  final String email;
  final String? phone;

  Engineer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory Engineer.fromJson(Map<String, dynamic> json) {
    return Engineer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class Site {
  final int id;
  final String siteId;
  final String siteName;
  final String? area;
  final String? region;
  final String? address;
  final double? latitude;
  final double? longitude;

  Site({
    required this.id,
    required this.siteId,
    required this.siteName,
    this.area,
    this.region,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'],
      siteId: json['site_id'],
      siteName: json['site_name'],
      area: json['area'],
      region: json['region'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
    );
  }
}
