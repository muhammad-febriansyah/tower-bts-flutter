class AsetLumpsum {
  final int id;
  final String assetNumber;
  final int siteId;
  final String? siteName;
  final String brand;
  final String type;
  final String? serialNumber;
  final String status; // good, damaged, needs_replacement
  final String? notes;
  final String? fotoAwal;
  final String? createdAt;
  final String? updatedAt;
  final int? engineerId;
  final String? engineerName;

  AsetLumpsum({
    required this.id,
    required this.assetNumber,
    required this.siteId,
    this.siteName,
    required this.brand,
    required this.type,
    this.serialNumber,
    required this.status,
    this.notes,
    this.fotoAwal,
    this.createdAt,
    this.updatedAt,
    this.engineerId,
    this.engineerName,
  });

  factory AsetLumpsum.fromJson(Map<String, dynamic> json) {
    return AsetLumpsum(
      id: json['id'] ?? 0,
      assetNumber: json['asset_number'] ?? '',
      siteId: json['site_id'] ?? 0,
      siteName: json['site_name'] ?? json['site']?['site_name'],
      brand: json['brand'] ?? '',
      type: json['type'] ?? '',
      serialNumber: json['serial_number'],
      status: json['status'] ?? 'good',
      notes: json['notes'],
      fotoAwal: json['foto_awal'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      engineerId: json['engineer_id'],
      engineerName: json['engineer_name'] ?? json['engineer']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_number': assetNumber,
      'site_id': siteId,
      'brand': brand,
      'type': type,
      'serial_number': serialNumber,
      'status': status,
      'notes': notes,
      'foto_awal': fotoAwal,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'engineer_id': engineerId,
    };
  }

  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'good':
        return 'Baik';
      case 'damaged':
        return 'Rusak';
      case 'needs_replacement':
        return 'Perlu Penggantian';
      default:
        return status;
    }
  }
}
