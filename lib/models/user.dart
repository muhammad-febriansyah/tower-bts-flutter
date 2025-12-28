class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? noHp;
  final String? whatsapp;
  final String? alamat;
  final String? areaKerja;
  final bool isActive;
  final double budgetBalance;
  final String? companyName;
  final String? contractNumber;
  final String? contractStart;
  final String? contractEnd;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.noHp,
    this.whatsapp,
    this.alamat,
    this.areaKerja,
    required this.isActive,
    this.budgetBalance = 0.0,
    this.companyName,
    this.contractNumber,
    this.contractStart,
    this.contractEnd,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      noHp: json['no_hp'],
      whatsapp: json['whatsapp'],
      alamat: json['alamat'],
      areaKerja: json['area_kerja'],
      isActive: json['is_active'] ?? true,
      budgetBalance: double.tryParse(json['budget_balance']?.toString() ?? '0') ?? 0.0,
      companyName: json['company_name'],
      contractNumber: json['contract_number'],
      contractStart: json['contract_start'],
      contractEnd: json['contract_end'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'no_hp': noHp,
      'whatsapp': whatsapp,
      'alamat': alamat,
      'area_kerja': areaKerja,
      'is_active': isActive,
      'budget_balance': budgetBalance,
      'company_name': companyName,
      'contract_number': contractNumber,
      'contract_start': contractStart,
      'contract_end': contractEnd,
      'created_at': createdAt,
    };
  }
}
