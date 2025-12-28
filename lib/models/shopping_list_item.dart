class ShoppingListItem {
  final int id;
  final String kodeCor;
  final String deskripsiPekerjaan;
  final String satuan;
  final String regional;
  final double hargaMaterial;
  final double hargaJasa;
  final double hargaTotal;
  final bool isActive;
  final String? createdAt;

  ShoppingListItem({
    required this.id,
    required this.kodeCor,
    required this.deskripsiPekerjaan,
    required this.satuan,
    required this.regional,
    required this.hargaMaterial,
    required this.hargaJasa,
    required this.hargaTotal,
    required this.isActive,
    this.createdAt,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'],
      kodeCor: json['kode_cor'],
      deskripsiPekerjaan: json['deskripsi_pekerjaan'],
      satuan: json['satuan'],
      regional: json['regional'],
      hargaMaterial: double.tryParse(json['harga_material']?.toString() ?? '0') ?? 0.0,
      hargaJasa: double.tryParse(json['harga_jasa']?.toString() ?? '0') ?? 0.0,
      hargaTotal: double.tryParse(json['harga_total']?.toString() ?? '0') ?? 0.0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_cor': kodeCor,
      'deskripsi_pekerjaan': deskripsiPekerjaan,
      'satuan': satuan,
      'regional': regional,
      'harga_material': hargaMaterial,
      'harga_jasa': hargaJasa,
      'harga_total': hargaTotal,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }
}
