class BudgetRealisasi {
  final int id;
  final String realizationNumber;
  final int budgetOperasionalId;
  final String? transferNumber;
  final int engineerId;
  final String? engineerName;
  final String category; // fuel, materials, transport, other
  final String amount;
  final String description;
  final double latitude; // GPS REQUIRED
  final double longitude; // GPS REQUIRED
  final String? fotoBukti;
  final String? createdAt;
  final String? updatedAt;

  BudgetRealisasi({
    required this.id,
    required this.realizationNumber,
    required this.budgetOperasionalId,
    this.transferNumber,
    required this.engineerId,
    this.engineerName,
    required this.category,
    required this.amount,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.fotoBukti,
    this.createdAt,
    this.updatedAt,
  });

  factory BudgetRealisasi.fromJson(Map<String, dynamic> json) {
    return BudgetRealisasi(
      id: json['id'] ?? 0,
      realizationNumber: json['realization_number'] ?? '',
      budgetOperasionalId: json['budget_operasional_id'] ?? 0,
      transferNumber: json['transfer_number'] ?? json['budget_operasional']?['transfer_number'],
      engineerId: json['engineer_id'] ?? 0,
      engineerName: json['engineer_name'] ?? json['engineer']?['name'],
      category: json['category'] ?? 'other',
      amount: json['amount']?.toString() ?? '0',
      description: json['description'] ?? '',
      latitude: _parseDouble(json['latitude']) ?? 0.0,
      longitude: _parseDouble(json['longitude']) ?? 0.0,
      fotoBukti: json['foto_bukti'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'realization_number': realizationNumber,
      'budget_operasional_id': budgetOperasionalId,
      'engineer_id': engineerId,
      'category': category,
      'amount': amount,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'foto_bukti': fotoBukti,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String getCategoryLabel() {
    switch (category.toLowerCase()) {
      case 'fuel':
        return 'BBM';
      case 'materials':
        return 'Material';
      case 'transport':
        return 'Transport';
      case 'other':
        return 'Lainnya';
      default:
        return category;
    }
  }

  bool hasValidGPS() {
    return latitude != 0.0 &&
           longitude != 0.0 &&
           latitude >= -90 &&
           latitude <= 90 &&
           longitude >= -180 &&
           longitude <= 180;
  }
}
