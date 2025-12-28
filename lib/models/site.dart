class Site {
  final int id;
  final String siteId;
  final String siteName;
  final String? area;
  final String? region;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? status;
  final Engineer? picEngineer;
  final String? createdAt;
  final String? updatedAt;

  Site({
    required this.id,
    required this.siteId,
    required this.siteName,
    this.area,
    this.region,
    this.address,
    this.latitude,
    this.longitude,
    this.status,
    this.picEngineer,
    this.createdAt,
    this.updatedAt,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'],
      siteId: json['site_id'],
      siteName: json['site_name'] ?? json['name'],
      area: json['area'],
      region: json['region'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      status: json['status'],
      picEngineer: json['pic_engineer'] != null ? Engineer.fromJson(json['pic_engineer']) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Engineer {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? whatsapp;

  Engineer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.whatsapp,
  });

  factory Engineer.fromJson(Map<String, dynamic> json) {
    return Engineer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
    );
  }
}
