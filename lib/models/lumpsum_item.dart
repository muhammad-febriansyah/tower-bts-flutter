class LumpsumItem {
  final int id;
  final String description;
  final String regional;
  final double nilaiPerBulan;
  final double nilaiPerTahun;
  final bool isActive;
  final String? createdAt;

  LumpsumItem({
    required this.id,
    required this.description,
    required this.regional,
    required this.nilaiPerBulan,
    required this.nilaiPerTahun,
    required this.isActive,
    this.createdAt,
  });

  factory LumpsumItem.fromJson(Map<String, dynamic> json) {
    return LumpsumItem(
      id: json['id'],
      description: json['description'],
      regional: json['regional'],
      nilaiPerBulan: double.tryParse(json['nilai_per_bulan']?.toString() ?? '0') ?? 0.0,
      nilaiPerTahun: double.tryParse(json['nilai_per_tahun']?.toString() ?? '0') ?? 0.0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'regional': regional,
      'nilai_per_bulan': nilaiPerBulan,
      'nilai_per_tahun': nilaiPerTahun,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }
}
