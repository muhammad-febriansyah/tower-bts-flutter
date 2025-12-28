import 'package:flutter/material.dart';

class MbpRequest {
  final int id;
  final String mbpNumber;
  final Map<String, dynamic>? site;
  final String? keteranganGangguan;
  final String status;
  final Map<String, dynamic>? engineer;
  final Map<String, dynamic>? hdRss;
  final String? latitudeSetup;
  final String? longitudeSetup;
  final List<String>? fotoInstalasi;
  final String? catatanEngineer;
  final String? submittedAt;
  final String? assignedAt;
  final String? setupAt;
  final String? completedAt;
  final String createdAt;
  final String updatedAt;

  MbpRequest({
    required this.id,
    required this.mbpNumber,
    this.site,
    this.keteranganGangguan,
    required this.status,
    this.engineer,
    this.hdRss,
    this.latitudeSetup,
    this.longitudeSetup,
    this.fotoInstalasi,
    this.catatanEngineer,
    this.submittedAt,
    this.assignedAt,
    this.setupAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MbpRequest.fromJson(Map<String, dynamic> json) {
    return MbpRequest(
      id: json['id'] ?? 0,
      mbpNumber: json['mbp_number'] ?? '',
      site: json['site'],
      keteranganGangguan: json['keterangan_gangguan'],
      status: json['status'] ?? 'requested',
      engineer: json['engineer'],
      hdRss: json['hd_rss'],
      latitudeSetup: json['latitude_setup']?.toString(),
      longitudeSetup: json['longitude_setup']?.toString(),
      fotoInstalasi: json['foto_instalasi'] != null
          ? List<String>.from(json['foto_instalasi'])
          : null,
      catatanEngineer: json['catatan_engineer'],
      submittedAt: json['submitted_at'],
      assignedAt: json['assigned_at'],
      setupAt: json['setup_at'],
      completedAt: json['completed_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  String getStatusLabel() {
    switch (status) {
      case 'requested':
        return 'Diminta';
      case 'assigned':
        return 'Ditugaskan';
      case 'on_progress':
        return 'Dalam Proses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color getStatusColor() {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'on_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
