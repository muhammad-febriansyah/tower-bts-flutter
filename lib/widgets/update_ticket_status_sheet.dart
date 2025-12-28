import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';

class UpdateTicketStatusSheet extends StatefulWidget {
  final int ticketId;
  final String currentStatus;

  const UpdateTicketStatusSheet({
    super.key,
    required this.ticketId,
    required this.currentStatus,
  });

  @override
  State<UpdateTicketStatusSheet> createState() => _UpdateTicketStatusSheetState();
}

class _UpdateTicketStatusSheetState extends State<UpdateTicketStatusSheet> {
  String? _selectedStatus;
  final TextEditingController _notesController = TextEditingController();
  bool _isUpdating = false;

  final Map<String, Map<String, dynamic>> _statusOptions = {
    'assigned': {
      'label': 'Assigned',
      'labelId': 'Ditugaskan',
      'icon': Iconsax.user_square,
      'color': Colors.blue,
      'description': 'Ticket telah ditugaskan',
    },
    'in_progress': {
      'label': 'In Progress',
      'labelId': 'Sedang Dikerjakan',
      'icon': Iconsax.timer_1,
      'color': Colors.orange,
      'description': 'Sedang dalam proses perbaikan',
    },
    'pending': {
      'label': 'Pending',
      'labelId': 'Tertunda',
      'icon': Iconsax.pause_circle,
      'color': Colors.amber,
      'description': 'Pekerjaan tertunda sementara',
    },
    'completed': {
      'label': 'Completed',
      'labelId': 'Selesai',
      'icon': Iconsax.tick_circle,
      'color': Colors.green,
      'description': 'Pekerjaan telah selesai',
    },
    'cancelled': {
      'label': 'Cancelled',
      'labelId': 'Dibatalkan',
      'icon': Iconsax.close_circle,
      'color': Colors.red,
      'description': 'Ticket dibatalkan',
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih status terlebih dahulu')),
      );
      return;
    }

    if (_selectedStatus == widget.currentStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status tidak berubah')),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final result = await ApiService.updateTicketStatus(
        widget.ticketId,
        _selectedStatus!,
        catatanEngineer: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      if (result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal update status'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
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
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Iconsax.note_text,
                    color: const Color(0xFF2E7D32),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Update Status Ticket',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Iconsax.close_circle, size: 24.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Current Status
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    color: Colors.blue.shade700,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Status saat ini: ',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _statusOptions[widget.currentStatus]?['color'],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      _statusOptions[widget.currentStatus]?['labelId'] ?? widget.currentStatus,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Status Options
            Text(
              'Pilih Status Baru',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),

            ..._statusOptions.entries.map((entry) {
              final status = entry.key;
              final data = entry.value;
              final isSelected = _selectedStatus == status;
              final isCurrent = status == widget.currentStatus;

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: InkWell(
                  onTap: isCurrent ? null : () {
                    setState(() => _selectedStatus = status);
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? data['color'].withValues(alpha: 0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? data['color']
                            : Colors.grey.shade300,
                        width: isSelected ? 2.w : 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: data['color'].withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            data['icon'],
                            color: data['color'],
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['labelId'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: isCurrent ? Colors.grey : Colors.black87,
                                ),
                              ),
                              Text(
                                data['description'],
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Iconsax.tick_circle,
                            color: data['color'],
                            size: 24.sp,
                          ),
                        if (isCurrent)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Aktif',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: 20.h),

            // Notes Field
            Text(
              'Catatan (Opsional)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan mengenai status update...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.all(12.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: const Color(0xFF2E7D32), width: 2.w),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Update Button
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateStatus,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
              ),
              child: _isUpdating
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Update Status',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
