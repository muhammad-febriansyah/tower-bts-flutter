import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/trouble_ticket.dart';

class CreateBudgetRequestPage extends StatefulWidget {
  const CreateBudgetRequestPage({super.key});

  @override
  State<CreateBudgetRequestPage> createState() => _CreateBudgetRequestPageState();
}

class _CreateBudgetRequestPageState extends State<CreateBudgetRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _specificationController = TextEditingController();
  final _costController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _imagePicker = ImagePicker();

  // Request type: 'ticket', 'lumpsum', or 'shopping_list'
  String _requestType = 'ticket';

  // Ticket-based request
  List<TroubleTicket> _tickets = [];
  TroubleTicket? _selectedTicket;

  // Lumpsum request
  List<Map<String, dynamic>> _lumpsumItems = [];
  Map<String, dynamic>? _selectedLumpsumItem;

  // Shopping List request
  List<Map<String, dynamic>> _shoppingListItems = [];
  Map<String, dynamic>? _selectedShoppingItem;

  bool _isLoading = false;
  bool _isLoadingData = true;
  final List<File> _selectedPhotos = [];

  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  void _formatCurrency(String value) {
    if (value.isEmpty) return;

    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericValue.isEmpty) {
      _costController.clear();
      return;
    }

    final number = int.parse(numericValue);
    final formatted = _currencyFormatter.format(number);

    _costController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _specificationController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);
    await Future.wait([
      _loadTickets(),
      _loadLumpsumItems(),
      _loadShoppingListItems(),
    ]);
    setState(() => _isLoadingData = false);
  }

  Future<void> _loadTickets() async {
    try {
      final result = await ApiService.getTickets(status: 'in_progress');
      if (!mounted) return;

      if (!result['error']) {
        final List<dynamic> ticketsData = result['data']['tickets'] ?? [];
        setState(() {
          _tickets = ticketsData.map((json) => TroubleTicket.fromJson(json)).toList();
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _loadLumpsumItems() async {
    try {
      final result = await ApiService.get('/lumpsum-items');
      if (!mounted) return;

      if (!result['error']) {
        final List<dynamic> itemsData = result['data'] ?? [];
        setState(() {
          _lumpsumItems = itemsData.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        debugPrint('Error loading lumpsum items: ${result['message']}');
      }
    } catch (e) {
      debugPrint('Exception loading lumpsum items: $e');
    }
  }

  Future<void> _loadShoppingListItems() async {
    try {
      final result = await ApiService.get('/shopping-list-items');
      if (!mounted) return;

      if (!result['error']) {
        final List<dynamic> itemsData = result['data'] ?? [];
        setState(() {
          _shoppingListItems = itemsData.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        debugPrint('Error loading shopping list items: ${result['message']}');
      }
    } catch (e) {
      debugPrint('Exception loading shopping list items: $e');
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedPhotos.addAll(images.map((xFile) => File(xFile.path)));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memilih foto: ${e.toString()}')),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation based on request type
    if (_requestType == 'ticket' && _selectedTicket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tiket terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_requestType == 'lumpsum' && _selectedLumpsumItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih item lumpsum terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_requestType == 'shopping_list' && _selectedShoppingItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih item shopping list terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      late Map<String, dynamic> result;

      if (_requestType == 'ticket') {
        result = await ApiService.createBudgetRequest(
          troubleTicketId: _selectedTicket!.id,
          specification: _specificationController.text.trim(),
          estimatedCost: double.parse(_costController.text.replaceAll('.', '').replaceAll(',', '')),
          photos: _selectedPhotos.isNotEmpty ? _selectedPhotos : null,
        );
      } else if (_requestType == 'lumpsum') {
        result = await ApiService.createLumpsumBudgetRequest(
          lumpsumItemId: _selectedLumpsumItem!['id'],
          quantity: int.tryParse(_quantityController.text) ?? 1,
          specification: _specificationController.text.trim(),
          photos: _selectedPhotos.isNotEmpty ? _selectedPhotos : null,
        );
      } else {
        // shopping_list
        result = await ApiService.createShoppingListBudgetRequest(
          shoppingListItemId: _selectedShoppingItem!['id'],
          quantity: int.tryParse(_quantityController.text) ?? 1,
          specification: _specificationController.text.isNotEmpty ? _specificationController.text.trim() : null,
          photos: _selectedPhotos.isNotEmpty ? _selectedPhotos : null,
        );
      }

      if (!mounted) return;

      if (result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal membuat permintaan anggaran'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan anggaran berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Buat Permintaan Anggaran'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Request Type Selection
                    _buildRequestTypeSelector(),
                    SizedBox(height: 20.h),

                    // Dynamic form based on request type
                    if (_requestType == 'ticket') ..._buildTicketForm(),
                    if (_requestType == 'lumpsum') ..._buildLumpsumForm(),
                    if (_requestType == 'shopping_list') ..._buildShoppingListForm(),

                    SizedBox(height: 24.h),

                    // Photo Upload Section
                    _buildPhotoSection(),

                    SizedBox(height: 32.h),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Kirim Permintaan',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRequestTypeSelector() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipe Permintaan',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  'ticket',
                  'Dari Tiket',
                  Iconsax.ticket,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTypeButton(
                  'lumpsum',
                  'Lumpsum',
                  Iconsax.dollar_circle,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTypeButton(
                  'shopping_list',
                  'Shopping List',
                  Iconsax.shopping_cart,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, IconData icon, Color color) {
    final bool isSelected = _requestType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _requestType = type;
          // Reset selections
          _selectedTicket = null;
          _selectedLumpsumItem = null;
          _selectedShoppingItem = null;
          _specificationController.clear();
          _costController.clear();
          _quantityController.text = '1';
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 28.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Poppins',
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTicketForm() {
    return [
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Tiket',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            if (_tickets.isEmpty)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.orange.shade700, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Tidak ada tiket dalam proses',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<TroubleTicket>(
                value: _selectedTicket,
                decoration: InputDecoration(
                  hintText: 'Pilih tiket',
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
                items: _tickets.map((ticket) {
                  return DropdownMenuItem<TroubleTicket>(
                    value: ticket,
                    child: Text(
                      '${ticket.ticketNumber} - ${ticket.title}',
                      style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedTicket = value);
                },
              ),
            SizedBox(height: 20.h),

            // Specification
            Text(
              'Detail Spesifikasi',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _specificationController,
              maxLines: 4,
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'Jelaskan detail kebutuhan...',
                hintStyle: TextStyle(fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
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
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Spesifikasi tidak boleh kosong';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),

            // Estimated Cost
            Text(
              'Estimasi Biaya (Rp)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _costController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(Iconsax.dollar_circle, color: const Color(0xFF2E7D32), size: 20.sp),
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
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              onChanged: _formatCurrency,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Estimasi biaya tidak boleh kosong';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildLumpsumForm() {
    return [
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Item Lumpsum',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            if (_lumpsumItems.isEmpty)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.orange.shade700, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Tidak ada item lumpsum tersedia',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedLumpsumItem,
                decoration: InputDecoration(
                  hintText: 'Pilih item lumpsum',
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
                items: _lumpsumItems.map((item) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: item,
                    child: Text(
                      '${item['description']} - ${item['regional']}',
                      style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLumpsumItem = value;
                    // Auto-fill cost
                    if (value != null) {
                      final cost = (value['nilai_per_bulan'] ?? 0).toString();
                      _costController.text = _currencyFormatter.format(double.parse(cost));
                    }
                  });
                },
              ),
            if (_selectedLumpsumItem != null) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Info Item',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.green.shade900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Regional: ${_selectedLumpsumItem!['regional']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Colors.green.shade900,
                      ),
                    ),
                    Text(
                      'Nilai/Bulan: Rp ${_currencyFormatter.format(_selectedLumpsumItem!['nilai_per_bulan'] ?? 0)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 20.h),

            // Quantity
            Text(
              'Jumlah/Kuantitas',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '1',
                hintStyle: TextStyle(fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(Iconsax.math, color: const Color(0xFF2E7D32), size: 20.sp),
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
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kuantitas tidak boleh kosong';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),

            // Specification
            Text(
              'Keterangan/Catatan',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _specificationController,
              maxLines: 4,
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'Keterangan tambahan...',
                hintStyle: TextStyle(fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
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
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Keterangan tidak boleh kosong';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildShoppingListForm() {
    return [
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Item Shopping List',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            if (_shoppingListItems.isEmpty)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.orange.shade700, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Tidak ada item shopping list tersedia',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedShoppingItem,
                decoration: InputDecoration(
                  hintText: 'Pilih item shopping list',
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
                items: _shoppingListItems.map((item) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: item,
                    child: Text(
                      '${item['kode_cor']} - ${item['deskripsi_pekerjaan']}',
                      style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedShoppingItem = value;
                    // Auto-fill cost
                    if (value != null) {
                      final cost = (value['harga_total'] ?? 0).toString();
                      _costController.text = _currencyFormatter.format(double.parse(cost));
                    }
                  });
                },
              ),
            if (_selectedShoppingItem != null) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Info Item',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Kode: ${_selectedShoppingItem!['kode_cor']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Text(
                      'Regional: ${_selectedShoppingItem!['regional']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Text(
                      'Satuan: ${_selectedShoppingItem!['satuan']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Text(
                      'Harga Material: Rp ${_currencyFormatter.format(_selectedShoppingItem!['harga_material'] ?? 0)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Text(
                      'Harga Jasa: Rp ${_currencyFormatter.format(_selectedShoppingItem!['harga_jasa'] ?? 0)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Text(
                      'Harga Total: Rp ${_currencyFormatter.format(_selectedShoppingItem!['harga_total'] ?? 0)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 20.h),

            // Quantity
            Text(
              'Jumlah/Kuantitas',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '1',
                hintStyle: TextStyle(fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(Iconsax.math, color: const Color(0xFF2E7D32), size: 20.sp),
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
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kuantitas tidak boleh kosong';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),

            // Specification (optional for shopping list)
            Text(
              'Keterangan/Catatan (Opsional)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _specificationController,
              maxLines: 3,
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'Keterangan tambahan (opsional)...',
                hintStyle: TextStyle(fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
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
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foto Pendukung (Opsional)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),

          // Selected photos
          if (_selectedPhotos.isNotEmpty) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List.generate(_selectedPhotos.length, (index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        _selectedPhotos[index],
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => _removePhoto(index),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            SizedBox(height: 12.h),
          ],

          // Add photo button
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: Icon(Iconsax.gallery_add, size: 20.sp),
            label: Text(
              _selectedPhotos.isEmpty ? 'Tambah Foto' : 'Tambah Foto Lainnya',
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
              side: const BorderSide(color: Color(0xFF2E7D32)),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
