import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/shopping_list_item.dart';

class ShoppingListRequestPage extends StatefulWidget {
  const ShoppingListRequestPage({super.key});

  @override
  State<ShoppingListRequestPage> createState() => _ShoppingListRequestPageState();
}

class _ShoppingListRequestPageState extends State<ShoppingListRequestPage> {
  List<ShoppingListItem> _items = [];
  List<ShoppingListItem> _filteredItems = [];
  List<String> _regionals = [];
  bool _isLoading = true;
  String? _selectedRegional;
  String _searchQuery = '';
  ShoppingListItem? _selectedItem;
  final _searchController = TextEditingController();
  final _specificationController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  List<File> _selectedPhotos = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadRegionals();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _specificationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadRegionals() async {
    try {
      final result = await ApiService.getShoppingListRegionals();

      if (!mounted) return;

      if (result['error'] != true) {
        setState(() {
          _regionals = (result['data'] as List).map((e) => e.toString()).toList();
        });
      }
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getShoppingListItems(
        regional: _selectedRegional,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (!mounted) return;

      if (result['error'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal memuat data')),
        );
      } else {
        setState(() {
          _items = (result['data'] as List)
              .map((json) => ShoppingListItem.fromJson(json))
              .toList();
          _filteredItems = _items;
        });
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

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredItems = _items;
      } else {
        _filteredItems = _items.where((item) {
          return item.kodeCor.toLowerCase().contains(query.toLowerCase()) ||
                 item.deskripsiPekerjaan.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedPhotos = images.map((xFile) => File(xFile.path)).toList();
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _submitRequest() async {
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih item terlebih dahulu')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (quantity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah minimal 1')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService.createShoppingListBudgetRequest(
        shoppingListItemId: _selectedItem!.id,
        quantity: quantity,
        specification: _specificationController.text.trim().isNotEmpty
            ? _specificationController.text.trim()
            : null,
        photos: _selectedPhotos.isNotEmpty ? _selectedPhotos : null,
      );

      if (!mounted) return;

      if (result['error'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal membuat permintaan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permintaan anggaran berhasil dibuat')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shopping List Maintenance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Regional Filter
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Filter Regional',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRegional,
                  decoration: InputDecoration(
                    hintText: 'Semua Regional',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Semua Regional')),
                    ..._regionals.map((regional) => DropdownMenuItem(
                          value: regional,
                          child: Text(regional),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedRegional = value);
                    _loadItems();
                  },
                ),
                SizedBox(height: 16.h),

                // Search
                TextField(
                  controller: _searchController,
                  onChanged: _filterItems,
                  decoration: InputDecoration(
                    hintText: 'Cari kode COR atau deskripsi...',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: const Icon(Iconsax.search_normal),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.search_normal, size: 64.sp, color: Colors.grey),
                            SizedBox(height: 16.h),
                            Text(
                              'Tidak ada data',
                              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final isSelected = _selectedItem?.id == item.id;

                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedItem = item);
                              _showItemDetail(item);
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2E7D32)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                    color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.kodeCor,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2E7D32),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          item.deskripsiPekerjaan,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontFamily: 'Poppins',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Regional: ${item.regional}',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Rp ${_formatCurrency(item.hargaTotal)}/${item.satuan}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showItemDetail(ShoppingListItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Item Info
                      Text(
                        item.kodeCor,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        item.deskripsiPekerjaan,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 16.h),

                      // Price Detail (Harga Pembanding)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with badge
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Iconsax.chart_2, color: Colors.white, size: 14.sp),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'HARGA STANDAR DATABASE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Harga Material:'),
                                Text(
                                  'Rp ${_formatCurrency(item.hargaMaterial)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Harga Jasa:'),
                                Text(
                                  'Rp ${_formatCurrency(item.hargaJasa)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Divider(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total per ${item.satuan}:',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Rp ${_formatCurrency(item.hargaTotal)}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Quantity
                      Text(
                        'Jumlah',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Masukkan jumlah',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Specification (Optional)
                      Text(
                        'Spesifikasi Detail (Opsional)',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _specificationController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Tambahan spesifikasi jika diperlukan...',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Photos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Foto (Opsional)',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _pickImages();
                            },
                            icon: const Icon(Iconsax.gallery_add),
                            label: const Text('Pilih Foto'),
                          ),
                        ],
                      ),
                      if (_selectedPhotos.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 100.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedPhotos.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 100.w,
                                    height: 100.h,
                                    margin: EdgeInsets.only(right: 12.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      image: DecorationImage(
                                        image: FileImage(_selectedPhotos[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () {
                                        _removePhoto(index);
                                        Navigator.pop(context);
                                        Future.delayed(const Duration(milliseconds: 100), () {
                                          _showItemDetail(item);
                                        });
                                      },
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
                            },
                          ),
                        ),
                      ],

                      SizedBox(height: 24.h),

                      // Estimated Cost
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Estimasi Biaya',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Rp ${_formatCurrency(item.hargaTotal * (int.tryParse(_quantityController.text) ?? 1))}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _submitRequest();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Ajukan Permintaan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
