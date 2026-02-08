import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/maintenance_order.dart';

class MaintenanceSowPage extends StatefulWidget {
  final MaintenanceOrder order;
  final MaintenanceSowItem sowItem;

  const MaintenanceSowPage({
    super.key,
    required this.order,
    required this.sowItem,
  });

  @override
  State<MaintenanceSowPage> createState() => _MaintenanceSowPageState();
}

class _MaintenanceSowPageState extends State<MaintenanceSowPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<MaintenanceEvidence> _evidences = [];

  @override
  void initState() {
    super.initState();
    _evidences = widget.sowItem.evidences ?? [];
  }

  Future<void> _pickAndUploadImage(String evidenceType) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      await _uploadEvidence(image.path, evidenceType);
    }
  }

  Future<void> _uploadEvidence(String filePath, String evidenceType) async {
    setState(() => _isUploading = true);

    try {
      final result = await ApiService.uploadMaintenanceEvidence(
        widget.order.id,
        widget.sowItem.id,
        evidenceType,
        File(filePath),
      );

      if (!mounted) return;

      if (result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to upload evidence'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evidence uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload evidences
        final evidence = MaintenanceEvidence.fromJson(result['data']['evidence']);
        setState(() {
          _evidences.add(evidence);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _markAsComplete() async {
    try {
      final result = await ApiService.updateSowItemStatus(
        widget.order.id,
        widget.sowItem.id,
        true,
      );

      if (!mounted) return;

      if (result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOW item marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Laporan Pekerjaan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SOW Item Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Iconsax.document,
                          color: Color(0xFF2E7D32),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.sowItem.getCategoryLabel(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.sowItem.itemName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Evidence sections based on SOW item
            _buildEvidenceSections(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildEvidenceSections() {
    // Define evidence types based on item code
    List<EvidenceSection> sections = _getEvidenceSectionsForItem();

    return Column(
      children: sections.map((section) {
        final evidencesForType = _evidences.where((e) => e.evidenceType == section.type).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  if (evidencesForType.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconsax.tick_circle5,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${evidencesForType.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Show uploaded evidences
              if (evidencesForType.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: evidencesForType.map((evidence) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        image: DecorationImage(
                          image: NetworkImage(evidence.fileUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Upload button
              InkWell(
                onTap: _isUploading ? null : () => _pickAndUploadImage(section.type),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.camera,
                        color: Colors.grey[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        evidencesForType.isEmpty ? 'Upload Foto' : 'Tambah Foto',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<EvidenceSection> _getEvidenceSectionsForItem() {
    // Based on PDF, different items have different evidence requirements
    // For simplicity, we'll use common ones. You can expand this based on your needs.

    if (widget.sowItem.category == 'mo_site') {
      switch (widget.sowItem.itemCode) {
        case 'proteksi':
          return [
            EvidenceSection('kabel_sambungan_splitzen', 'Evidence kabel sambungan splitzen'),
            EvidenceSection('kondisi_splitzen', 'Evidence Kondisi splitzen'),
          ];
        case 'penerangan':
          return [
            EvidenceSection('pengukuran_sumur_grounding', 'Evidence pengukuran sumur grounding'),
            EvidenceSection('pengecekan_koneksi_grounding', 'Evidence pengecekan Koneksi antar titik Grounding'),
          ];
        default:
          return [
            EvidenceSection('general_evidence', 'Evidence ${widget.sowItem.itemName}'),
          ];
      }
    } else {
      // MO Tenant
      switch (widget.sowItem.itemCode) {
        case 'antena_mw':
        case 'antena_rf':
        case 'antena_rru':
          return [
            EvidenceSection('antena_evidence', 'Evidence Antena'),
          ];
        default:
          return [
            EvidenceSection('general_evidence', 'Evidence ${widget.sowItem.itemName}'),
          ];
      }
    }
  }

  Widget _buildBottomActions() {
    final hasEvidence = _evidences.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: (_isUploading || !hasEvidence || widget.sowItem.isCompleted)
            ? null
            : _markAsComplete,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.sowItem.isCompleted ? 'Sudah Selesai' : 'Simpan',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class EvidenceSection {
  final String type;
  final String title;

  EvidenceSection(this.type, this.title);
}
